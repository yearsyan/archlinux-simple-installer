#!/bin/bash

set -e

EFI_SIZE="512M"
EFI_TYPE="ef00"   # EFI System partition
ROOT_TYPE="8304"  # Linux x86-64 root (GUID)
TARGET_MOUNT="/mnt"

function usage() {
    echo "Usage: $0 [--disk /dev/sdX]"
    exit 1
}

function list_disks() {
    echo "Available disks:"
    lsblk -d -e7 -o NAME,SIZE,MODEL
    echo
}

function confirm() {
    read -p "Are you sure you want to partition and erase all data on $1? [yes/NO]: " confirm
    if [[ "$confirm" != "yes" ]]; then
        echo "Aborted."
        exit 1
    fi
}

function get_partition_name() {
    local disk=$1
    local number=$2

    if [[ "$disk" =~ nvme ]]; then
        echo "${disk}p${number}"
    else
        echo "${disk}${number}"
    fi
}


function format_partitions() {
    local disk=$1
    local efi_part="$(get_partition_name "$disk" 1)"
    local root_part="$(get_partition_name "$disk" 2)"

    echo "Formatting $efi_part as FAT32..."
    mkfs.fat -F32 "$efi_part"

    echo "Formatting $root_part as EXT4..."
    mkfs.ext4 "$root_part"
}

function partition_disk() {
    local disk=$1

    echo "Wiping existing partitions on $disk..."
    sgdisk --zap-all "$disk"

    echo "Creating new GPT partition table on $disk..."
    sgdisk -og "$disk"

    echo "Creating EFI partition (512M)..."
    sgdisk -n 1:0:+$EFI_SIZE -t 1:$EFI_TYPE -c 1:"EFI System" "$disk"

    echo "Creating root partition (rest of the disk)..."
    sgdisk -n 2:0:0 -t 2:$ROOT_TYPE -c 2:"Linux root x86-64" "$disk"

    partprobe "$disk"
    sleep 2
    format_partitions "$disk"

    echo "Partitioning complete."
}

function mount_partitions() {
    local disk=$1
    local efi_part="$(get_partition_name "$disk" 1)"
    local root_part="$(get_partition_name "$disk" 2)"

    echo "Mounting root partition $root_part to $TARGET_MOUNT..."
    mkdir -p $TARGET_MOUNT
    mount "$root_part" $TARGET_MOUNT

    echo "Mounting EFI partition $efi_part to $TARGET_MOUNT/boot..."
    mkdir -p $TARGET_MOUNT/boot
    mount "$efi_part" $TARGET_MOUNT/boot

    echo "Partitions successfully mounted:"
    lsblk -o NAME,MOUNTPOINT | grep -E "${disk##*/}[12]"
}

function init_pacman() {
    pacman-key --init
    pacman-key --populate
    pacman -Sy archlinux-keyring
}

# Parse arguments
DISK=""

while [[ "$#" -gt 0 ]]; do
    case "$1" in
        --disk)
            DISK="$2"
            shift 2
            ;;
        *)
            usage
            ;;
    esac
done

if [ -z "$DISK" ]; then
    list_disks
    read -p "Enter the disk to partition (e.g., /dev/sda): " DISK
fi

if [ ! -b "$DISK" ]; then
    echo "Error: $DISK is not a valid block device."
    exit 1
fi

confirm "$DISK"
partition_disk "$DISK"
mount_partitions "$DISK"

reflector -p https -c China --delay 3 --completion-percent 95 --sort rate --save /etc/pacman.d/mirrorlist

init_pacman
pacstrap -K $TARGET_MOUNT base linux linux-firmware nvim grub openssh networkmanager zsh git curl sudo

genfstab -U $TARGET_MOUNT >> $TARGET_MOUNT/etc/fstab


cp ./chroot_setup.sh $TARGET_MOUNT/root/
cp ./user_script.sh $TARGET_MOUNT/root/
chmod +x $TARGET_MOUNT/root/chroot_setup.sh
chmod +x $TARGET_MOUNT/root/user_script.sh
arch-chroot $TARGET_MOUNT /bin/bash /root/chroot_setup.sh

reboot
