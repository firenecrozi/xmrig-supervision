#!/bin/bash
if [ "$USER" == "root" ]; then
    echo "[ERROR] Please dont run as root"
    exit 1
fi



function update() {
    echo "[INFO] Xmrig Supervision..."
    cd /home/$USER/xmrig-supervision
    git pull
    echo "[INFO] Update finished"
}

function init() {}
    
    