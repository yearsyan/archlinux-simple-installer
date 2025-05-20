#!/bin/bash

set -e

curl -s https://api.github.com/repos/yearsyan/archlinux-simple-installer/releases/latest \
| grep "browser_download_url" \
| grep "installer.tar.gz" \
| cut -d '"' -f 4 \
| xargs curl -LO


tar -xvf ./installer.tar.gz
cd installer
./install.sh
