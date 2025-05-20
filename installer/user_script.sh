#!/bin/bash

set -e

install_ohmyzsh() {
    if [ -d "$HOME/.oh-my-zsh" ]; then
        echo "Oh My Zsh is already installed"
    else
        echo "Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        echo "Oh My Zsh installation completed"
    fi
}

install_plugins() {
    # Install zsh-autosuggestions
    if [ -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
        echo "zsh-autosuggestions is already installed"
    else
        echo "Installing zsh-autosuggestions..."
        git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
        echo "zsh-autosuggestions installation completed"
    fi
    
    # Install zsh-syntax-highlighting
    if [ -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]; then
        echo "zsh-syntax-highlighting is already installed"
    else
        echo "Installing zsh-syntax-highlighting..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
        echo "zsh-syntax-highlighting installation completed"
    fi
}

configure_zshrc() {
    echo "Configuring .zshrc file..."
    
    # Backup original .zshrc file
    if [ -f "$HOME/.zshrc" ]; then
        cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d%H%M%S)"
    fi
    
    # Check and add plugins
    if grep -q "plugins=(git)" "$HOME/.zshrc"; then
        sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/g' "$HOME/.zshrc"
    else
        # If default plugin line not found, try to find any plugin configuration line
        if grep -q "plugins=(" "$HOME/.zshrc"; then
            # Ensure plugins are not added twice
            if ! grep -q "zsh-autosuggestions" "$HOME/.zshrc"; then
                sed -i 's/plugins=(/plugins=(zsh-autosuggestions /g' "$HOME/.zshrc"
            fi
            if ! grep -q "zsh-syntax-highlighting" "$HOME/.zshrc"; then
                sed -i 's/plugins=(/plugins=(zsh-syntax-highlighting /g' "$HOME/.zshrc"
            fi
        else
            # If no plugin configuration found, add a new line
            echo 'plugins=(git zsh-autosuggestions zsh-syntax-highlighting)' >> "$HOME/.zshrc"
        fi
    fi
    
    echo ".zshrc configuration completed"
}

install_ohmyzsh
install_plugins
configure_zshrc
