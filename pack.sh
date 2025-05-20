#!/bin/bash

set -e
tar -czvf installer.tar.gz -C $(dirname $(readlink -f ./installer)) $(basename $(readlink -f ./installer))

