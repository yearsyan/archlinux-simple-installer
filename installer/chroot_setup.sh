#!/bin/bash

set -e

source /root/config.sh
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
hwclock --systohc

# Password setting function with retry mechanism
set_password() {
    local user=$1
    local max_attempts=5
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        echo "Set password for $user (Attempt $attempt/$max_attempts)"
        if passwd $user; then
            echo "Password set successfully"
            return 0
        else
            echo "Password setting failed, please try again"
            attempt=$((attempt + 1))
        fi
    done
    
    echo "Error: Failed to set password after $max_attempts attempts"
    return 1
}

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

useradd -m -s /bin/zsh "$USERNAME"
echo "$USERNAME ALL=(ALL) NOPASSWD: ALL" | tee /etc/sudoers.d/$USERNAME && chmod 440 /etc/sudoers.d/$USERNAME

echo "Set root password"
set_password root

echo "Set password for $USERNAME"
set_password $USERNAME

# Copy user script to user's home directory and set proper permissions
cp /root/user_script.sh /home/$USERNAME/
chown $USERNAME:$USERNAME /home/$USERNAME/user_script.sh
chmod 755 /home/$USERNAME/user_script.sh

# Execute as user
su - $USERNAME -c "~/user_script.sh"

# Clean user_script.sh
rm -f /home/$USERNAME/user_script.sh