#!/bin/bash

if [ "$USER" != "root" ]; then
    echo "[ERROR] Please run as root"
    exit 1
fi

function read_user() {
    username=$(cat /home/$USER/.config/.sysdata/user.info)
}

function start() {
    echo "[INFO] Starting Xmrig..."
    cd /home/$username/xmrig/build
    ./xmrig -c /home/$username/xmrig/build/config.json
    echo "[INFO] Xmrig started successfully"
}
    
