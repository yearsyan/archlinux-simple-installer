# Arch Linux Simple Installer

A streamlined and user-friendly installer for Arch Linux that simplifies the installation process while maintaining the flexibility and power of Arch Linux.

## Features

- Simple one-command installation process
- Pre-installed essential packages:
  - NetworkManager for network management
  - sudo for privilege management
  - openssh for remote access
  - nvim as the default editor
  - zsh as the default shell
  - git for version control
  - curl for network operations

## Quick Start

To start the installation process, simply run:

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/yearsyan/archlinux-simple-installer/main/bootstrap-installer.sh)"
```

This will:
1. Download the latest release of the installer
2. Extract the installation files
3. Start the installation process

## Configuration

The installer can be configured by modifying the `config.sh` file before running the installation script. This allows you to customize various aspects of the installation process.
