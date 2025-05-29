#!/usr/bin/env bash
Red='\033[1;31m'
Green='\033[1;32m'
Blue='\033[1;34m'
Purple='\033[1;35m'
Nc='\033[0m' # No Color

PHPV='8.3'
isPHPv=$(php -v | grep -q "PHP ${PHPV}")
nocache=''
nocache='--no-cache'

apt-get update

# Detect if running on WSL or macOS
if grep -q Microsoft /proc/version; then
    HOSTFILE="/mnt/c/Windows/System32/drivers/etc/hosts"
else
    HOSTFILE="/etc/hosts"
fi
DOMAIN="local.host"

# Check if we have permission to write to hosts file
if [ ! -w "$HOSTFILE" ]; then
    echo -e "${Red}Error: Need sudo privileges to modify $HOSTFILE${Nc}"
    echo "Please run this script with sudo"
    exit 1
fi

# Check if the string exists in the file
if grep -Fq "$DOMAIN" "$HOSTFILE"; then
    echo -e "${Blue}The string '$DOMAIN' already exists in $HOSTFILE.${Nc}"
else
    # Append the string to the file
    echo "127.0.0.1 $DOMAIN" >> "$HOSTFILE"
    echo -e "${Green}Added '$DOMAIN' to $HOSTFILE.${Nc}"
fi

apt-get install -y php${PHPV} wget unzip php${PHPV}-curl php${PHPV}-cli php${PHPV}-zip

printf "${Purple}docker compose.${Nc}\n"
docker compose --file ./docker-compose.yaml down
docker compose --file ./docker-compose.yaml build ${nocache}
docker compose --file ./docker-compose.yaml up -d --force-recreate

docker compose --file ./docker-compose.yaml logs --follow
