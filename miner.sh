#!/bin/bash

# Warna untuk output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
RESET='\033[0m'

# Script untuk memeriksa versi Linux, memilih, dan mengunduh file XMRig yang cocok

# Periksa apakah file /etc/os-release ada
if [ -f /etc/os-release ]; then
    echo -e "${CYAN}--- Informasi Sistem Operasi ---${RESET}"
    source /etc/os-release
    echo -e "${YELLOW}Nama OS: ${RESET}$NAME"
    echo -e "${YELLOW}Versi OS: ${RESET}$VERSION"
    echo -e "${YELLOW}ID OS: ${RESET}$ID"
    echo -e "${YELLOW}ID Versi: ${RESET}$VERSION_ID"
    echo -e "${CYAN}---${RESET}"
fi

# Periksa versi kernel
echo -e "${CYAN}--- Informasi Kernel ---${RESET}"
uname -r

# Arsitektur sistem
echo -e "${CYAN}--- Arsitektur Sistem ---${RESET}"
ARCH=$(uname -m)
echo -e "${YELLOW}$ARCH${RESET}"

# Periksa jika distribusi berbasis CentOS/RHEL
if [ -f /etc/centos-release ]; then
    echo -e "${CYAN}--- Informasi CentOS/RHEL ---${RESET}"
    cat /etc/centos-release
    DISTRO="CentOS"
fi

# Periksa jika distribusi berbasis Ubuntu/Debian
if [ -f /etc/lsb-release ]; then
    echo -e "${CYAN}--- Informasi Ubuntu/Debian ---${RESET}"
    cat /etc/lsb-release
    DISTRO="Ubuntu"
    if grep -q "20.04" /etc/lsb-release; then
        UBUNTU_VERSION="focal"
    elif grep -q "22.04" /etc/lsb-release; then
        UBUNTU_VERSION="jammy"
    elif grep -q "24.04" /etc/lsb-release; then
        UBUNTU_VERSION="noble"
    fi
fi

# Pilih file XMRig yang cocok dan URL unduhan
echo -e "${CYAN}--- Pemilihan File XMRig ---${RESET}"
BASE_URL="https://github.com/xmrig/xmrig/releases/download/v6.22.2/"
FILE=""

if [ "$DISTRO" == "Ubuntu" ]; then
    if [ "$UBUNTU_VERSION" == "focal" ]; then
        FILE="xmrig-6.22.2-focal-x64.tar.gz"
    elif [ "$UBUNTU_VERSION" == "jammy" ]; then
        FILE="xmrig-6.22.2-jammy-x64.tar.gz"
    elif [ "$UBUNTU_VERSION" == "noble" ]; then
        FILE="xmrig-6.22.2-noble-x64.tar.gz"
    else
        FILE="xmrig-6.22.2-linux-static-x64.tar.gz"
    fi
elif [ "$DISTRO" == "CentOS" ]; then
    FILE="xmrig-6.22.2-linux-static-x64.tar.gz"
else
    FILE="xmrig-6.22.2-linux-static-x64.tar.gz"
fi

# Unduh file jika ditemukan
if [ -n "$FILE" ]; then
    echo -e "${GREEN}Mengunduh $FILE dari $BASE_URL${RESET}"
    curl -LO "$BASE_URL$FILE"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Unduhan selesai: $FILE${RESET}"
        echo -e "${CYAN}Mengekstrak file: $FILE${RESET}"
        tar -xzf "$FILE"
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Ekstraksi selesai.${RESET}"
            FOLDER_NAME=$(tar -tf "$FILE" | head -1 | cut -f1 -d"/")
            mv "$FOLDER_NAME" daemon
            echo -e "${GREEN}Folder telah diubah namanya menjadi 'daemon'.${RESET}"
            cd daemon || exit
            echo -e "${CYAN}Mengganti file config.json dengan versi terbaru...${RESET}"
            curl -o config.json https://raw.githubusercontent.com/kliverz1337/autominer/refs/heads/main/config.json
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}File config.json berhasil diganti.${RESET}"
                echo -e "${CYAN}Menjalankan XMRig...${RESET}"
                nice ./xmrig "$@"
            else
                echo -e "${RED}Gagal mengganti file config.json.${RESET}"
                exit 1
            fi
        else
            echo -e "${RED}Gagal mengekstrak $FILE${RESET}"
            exit 1
        fi
    else
        echo -e "${RED}Gagal mengunduh $FILE${RESET}"
        exit 1
    fi
else
    echo -e "${RED}Tidak dapat menentukan file XMRig yang sesuai.${RESET}"
    exit 1
fi
