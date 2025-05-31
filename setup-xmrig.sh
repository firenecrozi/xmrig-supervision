#!/bin/bash

if [ "$USER" != "root" ]; then
    echo "[ERROR] Please run as root"
    exit 1
fi

if [ -z "$SUDO_USER" ]; then
    echo "[ERROR] This script must be run with sudo"
    exit 1
fi

username="$SUDO_USER"
echo -e "[INFO] Detected system username: $username"
echo -e "\n"

hidden_dir="/home/$username/.config/.sysdata"
hidden_file="$hidden_dir/user.info"

mkdir -p $hidden_dir
echo "$username" > $hidden_file
chmod 600 $hidden_file


function enable_1gb_pages() {
    echo "[INFO] Enabling 1GB pages..."
    if [ -f "/home/$username/xmrig-supervision/src/enable_1gb_pages.sh" ]; then
        chmod +x /home/$username/xmrig-supervision/src/enable_1gb_pages.sh
        cd /home/$username/xmrig-supervision/src
        ./enable_1gb_pages.sh
        echo "[INFO] 1GB pages enabled successfully"
    else
        echo "[ERROR] enable_1gb_pages.sh script not found"
    fi
}

function sudoer() {
    echo "[INFO] Enabling sudoer permission for xmrig script..."
    sleep 2
    echo "$username ALL=(ALL) NOPASSWD: /home/$username/xmrig/build/xmrig" >> /etc/sudoers.d/xmrig
    chmod 440 /etc/sudoers.d/xmrig
    echo "[INFO] Sudoer permission enabled"
}
function randomx_boost() {
    echo "[INFO] Enabling randomx_boost..."
    if [ -f "/home/$username/xmrig-supervision/src/randomx_boost.sh" ]; then
        chmod +x /home/$username/xmrig-supervision/src/randomx_boost.sh
        cd /home/$username/xmrig-supervision/src
        ./randomx_boost.sh
        echo "[INFO] RandomX boost enabled successfully"
    else
        echo "[ERROR] randomx_boost.sh script not found"
    fi
}

function read_user() {
    username="$SUDO_USER"
    echo "[INFO] Detected system username: $username"
}

function reboot_now() {
    echo "[INFO] everthing is done..."
    echo "[INFO] Do you want to reboot now? [Enter for now/strg+c for later]"
    read reboot
    if [ "$reboot" = "" ]; then
        sleep 2
        reboot
    else
        echo "[INFO] Reboot skipped"
        exit 0
    fi
}

function swapoff_on() {
    echo "[INFO] Swapoff..."
    sleep 2
    swapoff -a
    if awk '$3 == "swap" || $1 ~ /swapfile|swap.img|zram/ {found=1; exit} END {exit !found}' /etc/fstab; then
        awk '$3 == "swap" || $1 ~ /swapfile|swap.img|zram/ {exit} {print}' /etc/fstab > temp && mv temp /etc/fstab
    else
        echo "Keine Swap-Zeile gefunden – /etc/fstab bleibt unverändert."
    fi
}

function info() {
    echo "[INFO] Setup-Xmrig Start"
    echo -e "\n"
    echo -e "Dependencies\n (Debian/Ubuntu packages / automatic install)"
    echo "
    - Python 3.10+, Git, CMake, libhwloc-dev, libssl-dev, libuv1-dev, build-essential, python3-pip, msr-tools
    - Python packages: apscheduler, pathlib, subprocess, time, logger(self-made modul)
    "
    echo -e "Needed Repositories (download automatically)"
    echo "
    - https://github.com/xmrig/xmrig.git (all)
    - https://github.com/firenecrozi/xmrig-supervision.git (logger.py, main.py, enable_1gb_pages.sh, randomx_boost.sh, infos.txt)
    "
    echo -e "User Input [WICHTIG]"
    echo "
    - Dein SYSTEM-USERNAME wird automatisch erkannt: $username
    - Du muss selber entscheiden ob du optimierungen auf deinem System aktivieren willst (z.B. enable_1gb_pages.sh, randomx_boost.sh, andere Optimierungen in Bios)
    - dieses Skript soll in deinem Home Ordner landen (z.B. /home/$username)
    - Du bist gerade hier:$(pwd)"
    echo -e "\n"
    echo -e "[INFO] Wollen Sie die Installation starten? [Enter to continue/strg+c to exit]"
    read 
    echo -e "Installation wird gestartet..."
    echo -e "\n"
}

function download_all() {
    cd /home/$username
    echo "[INFO] Installing System dependencies..."
    apt update && apt install -y git build-essential python3-pip python3-dev libssl-dev libhwloc-dev libuv1-dev cmake msr-tools
    
    echo -e "\n[INFO] Installing Python packages..."
    su $username -c "pip install APScheduler"
    
    echo -e "\n[INFO] Downloading repositories..."
    if [ ! -d "/home/$username/xmrig" ]; then
        git clone https://github.com/xmrig/xmrig.git
        echo "[INFO] Xmrig repository downloaded"
    else
        echo "[INFO] Xmrig repository already exists"
    fi
    
    if [ ! -d "/home/$username/xmrig-supervision" ]; then
        git clone https://github.com/firenecrozi/xmrig-supervision.git
        echo "[INFO] Xmrig-supervision repository downloaded"
    else
        echo "[INFO] Xmrig-supervision repository already exists"
    fi
}

function optimierungen() {
    echo -e "\n"
    echo -e "[INFO] Wollen Sie die Optimierungen starten? [Enter to continue/strg+c to exit]"
    read
    
    echo -e "\n"
    echo "[INFO] Optimierungen..."
    
    while true; do
        echo -e "\n"
        echo -e "Welche Optimierungen willst du durchführen?"
        echo -e "1. Enable 1GB Pages"
        echo -e "2. RandomX Boost"
        echo -e "3. Swapoff"
        echo -e "4. Xmrig Sudoerpermission"
        echo -e "5. Alle Optimierungen"
        echo -e "6. Keine Optimierungen (Fertig)"
        echo -e "7. Infos zu den Optimierungen"
        echo -e "\n"
        
        read -p "Wähle eine Option (1-7): " option
        
        case "$option" in
            1)
                echo "[INFO] Aktiviere 1GB Pages..."
                enable_1gb_pages
                ;;
            2)
                echo "[INFO] Aktiviere RandomX Boost..."
                randomx_boost
                ;;
            3)
                echo "[INFO] Deaktiviere Swap..."
                swapoff_on
                ;;
            4)
                echo "[INFO] Setze Sudoer Berechtigungen..."
                sudoer
                ;;
            5)
                echo "[INFO] Führe alle Optimierungen durch..."
                enable_1gb_pages
                randomx_boost
                swapoff_on
                sudoer
                echo "[INFO] Alle Optimierungen abgeschlossen"
                sleep 1
                return
                ;;
            6)
                echo "[INFO] Keine weiteren Optimierungen, Setup abgeschlossen."
                sleep 1
                return
                ;;
            7)
                echo "[INFO] Infos zu den Optimierungen..."
                if [ -f "/home/$username/xmrig-supervision/infos.txt" ]; then
                    cat /home/$username/xmrig-supervision/infos.txt
                else
                    echo "[ERROR] Infodatei nicht gefunden."
                fi
                ;;
            *)
                echo "[ERROR] Ungültige Option. Bitte wähle 1-7."
                ;;
        esac
    done
}

function install_xmrig() {
    echo -e "\n"
    echo "[INFO] Installing Xmrig..."
    sleep 4
    mkdir /home/$username/xmrig/build
    cd /home/$username/xmrig/build
    cmake ..
    make -j$(nproc)
    echo "[INFO] Xmrig installed successfully"
}

function install_xmrig_supervision() {
    echo -e "\n"
    echo "[INFO] Installing Xmrig Supervision..."
    sleep 2
    cp -r /home/$username/xmrig-supervision/src/* /home/$username/xmrig/build/
    chmod +x /home/$username/xmrig-supervision/scripts/*
    cp /home/$username/xmrig-supervision/config/config.json /home/$username/xmrig/build/config.json
    cp /home/$username/xmrig-supervision/scripts/* /home/$username/
    echo "[INFO] Xmrig Supervision installed successfully"
}

function shorter() {
    echo "[INFO] Checking existing installation..."
    
    if [[ -d "/home/$username/xmrig" && -d "/home/$username/xmrig/build" ]]; then
        cd /home/$username/xmrig/build
        xmrig_installed=$(find . -type f -name "xmrig" | wc -l)
        supervision_installed=$(find . -type f -name "ident.txt" | wc -l)
        
        if [[ $xmrig_installed -gt 0 && $supervision_installed -gt 0 ]]; then
            echo "[INFO] Xmrig and Xmrig Supervision are already installed"
            info
            optimierungen
            reboot_now
            return
        elif [[ $xmrig_installed -gt 0 ]]; then
            echo "[INFO] Xmrig is installed but Xmrig Supervision is missing"
            install_xmrig_supervision
            optimierungen
            reboot_now
            return
        elif [[ $supervision_installed -gt 0 ]]; then
            echo "[INFO] Xmrig Supervision is installed but Xmrig is missing"
            install_xmrig
            optimierungen
            reboot_now
            return
        fi
    fi
    
    echo "[INFO] No complete installation found, proceeding with full setup"
    main
}

function main() {
    info
    download_all
    install_xmrig   
    install_xmrig_supervision
    echo "[INFO] Installation finished"
    optimierungen
    reboot_now
}

shorter
