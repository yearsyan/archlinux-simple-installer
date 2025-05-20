#!/bin/bash

set -e

install_ohmyzsh() {
    if [ -d "$HOME/.oh-my-zsh" ]; then
        print_color "Oh My Zsh 已安装"
    else
        print_color "正在安装 Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        print_color "Oh My Zsh 安装完成"
    fi
}

install_plugins() {
    # 安装 zsh-autosuggestions
    if [ -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
        print_color "zsh-autosuggestions 已安装"
    else
        print_color "正在安装 zsh-autosuggestions..."
        git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
        print_color "zsh-autosuggestions 安装完成"
    fi
    
    # 安装 zsh-syntax-highlighting
    if [ -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]; then
        print_color "zsh-syntax-highlighting 已安装"
    else
        print_color "正在安装 zsh-syntax-highlighting..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
        print_color "zsh-syntax-highlighting 安装完成"
    fi
}

configure_zshrc() {
    print_color "配置 .zshrc 文件..."
    
    # 备份原始 .zshrc 文件
    if [ -f "$HOME/.zshrc" ]; then
        cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d%H%M%S)"
    fi
    
    # 检查并添加插件
    if grep -q "plugins=(git)" "$HOME/.zshrc"; then
        sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/g' "$HOME/.zshrc"
    else
        # 如果没有找到默认的插件行，则尝试查找任何插件配置行
        if grep -q "plugins=(" "$HOME/.zshrc"; then
            # 确保不重复添加插件
            if ! grep -q "zsh-autosuggestions" "$HOME/.zshrc"; then
                sed -i 's/plugins=(/plugins=(zsh-autosuggestions /g' "$HOME/.zshrc"
            fi
            if ! grep -q "zsh-syntax-highlighting" "$HOME/.zshrc"; then
                sed -i 's/plugins=(/plugins=(zsh-syntax-highlighting /g' "$HOME/.zshrc"
            fi
        else
            # 如果没有找到任何插件配置，则添加一个新行
            echo 'plugins=(git zsh-autosuggestions zsh-syntax-highlighting)' >> "$HOME/.zshrc"
        fi
    fi
    
    print_color ".zshrc 配置完成"
}

install_ohmyzsh
install_plugins
configure_zshrc
