#!/bin/bash

if [ "$USER" != "root" ]; then
    echo "[ERROR] Please run as root"
    exit 1
fi

function read_user() {
    echo "[INFO] Please enter your system username (in terminal -> USERNAME@hostname:~$)"
    read username
    echo -e "\n"
    echo -e "[INFO] Your system username is: $username"
    echo -e "is this correct? [Enter to continue/strg+c to exit]"
    read
}

function start() {
    echo "[INFO] Starting Xmrig..."
    cd /home/$username/xmrig/build
    ./xmrig -c /home/$USER/xmrig/build/config.json
    echo "[INFO] Xmrig started successfully"
}
    