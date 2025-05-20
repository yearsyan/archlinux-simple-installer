#!/bin/bash

set -e

# Check network connection
echo "Checking network connection..."
if ! ping -c 1 api.github.com > /dev/null 2>&1; then
    echo "Error: Unable to connect to network. Please check your internet connection."
    exit 1
fi

echo "Network connection OK, starting download..."

curl -s https://api.github.com/repos/yearsyan/archlinux-simple-installer/releases/latest \
| grep "browser_download_url" \
| grep "installer.tar.gz" \
| cut -d '"' -f 4 \
| xargs curl -LO

# Check if download was successful
if [ ! -f "installer.tar.gz" ]; then
    echo "Error: Failed to download installer"
    exit 1
fi

echo "Download complete, extracting..."
tar -xvf ./installer.tar.gz
cd installer
./install.sh
