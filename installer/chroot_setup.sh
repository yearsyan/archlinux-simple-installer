#!/bin/bash

set -e

source config.sh
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
hwclock --systohc


sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen

echo 'LANG=en_US.UTF-8' > /etc/locale.conf
echo 'KEYMAP=us' > /etc/vconsole.conf

echo "$HOSTNAME" > /etc/hostname


# hosts
cat > /etc/hosts << EOF
127.0.0.1    localhost
::1          localhost
127.0.1.1    $HOSTNAME.localdomain    $HOSTNAME
EOF


echo "Setup GRUB"
grub-install --target=x86_64-efi --efi-directory=/boot --removable
grub-mkconfig -o /boot/grub/grub.cfg


systemctl enable NetworkManager
systemctl enable sshd

useradd -m -s /bin/zsh "USERNAME"
echo "$USERNAME ALL=(ALL) NOPASSWD: ALL" | tee /etc/sudoers.d/$USERNAME && chmod 440 /etc/sudoers.d/$USERNAME

echo "Set password for root"
passwd

echo "Set password for $USERNAME"
passwd $USERNAME
su - $USERNAME -c "/root/user_script.sh"

