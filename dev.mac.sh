#!/bin/bash
# Add these color definitions at the start
Blue='\033[0;34m'
Green='\033[0;32m'
Nc='\033[0m' # No Color

DOMAIN="local.host"
HOSTFILE="/etc/hosts"
EMAIL="hrolazyan@gmail.com"

printf "${Purple}docker compose.${Nc}\n"
docker compose --file ./docker-compose.yaml down
docker compose --file ./docker-compose.yaml build ${nocache}
docker compose --file ./docker-compose.yaml up -d --force-recreate

cd dev
# Create OpenSSL config
cat > openssl.cnf << EOL
[ req ]
default_bits = 2048
prompt = no
default_md = sha256
distinguished_name = dn
req_extensions = v3_req
x509_extensions = v3_ca

[ dn ]
C = AM
ST = Yerevan
L = Yerevan
O = $DOMAIN
OU = local
CN = $DOMAIN
emailAddress = $EMAIL

[ CA_default ]
copy_extensions = copy

[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment

[ v3_ca ]
subjectAltName = @alternate_names

[ alternate_names ]
DNS.1 = $DOMAIN
DNS.2 = *.$DOMAIN
EOL

# Backup existing certificates if they exist
if [ -f def.key ] && [ -f def.crt ]; then
    timestamp=$(date +%Y%m%d_%H%M%S)
    mv def.key "backup.$timestamp.def.key"
    mv def.crt "backup.$timestamp.def.crt"
fi

# Generate certificate
openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout def.key -out def.crt -config openssl.cnf \
-subj "/C=AM/ST=Yerevan/L=Yerevan/O=$DOMAIN/OU=local/CN=$DOMAIN/emailAddress=$EMAIL"

# Add after certificate generation
if [ ! -f def.crt ] || [ ! -f def.key ]; then
    echo "Error: Certificate generation failed"
    exit 1
fi

# Verify certificate
openssl x509 -in def.crt -text -noout


# Copy certificates to nginx certs volume
mv def.key ./../certs/def.key
mv def.crt ./../certs/def.crt

cd ./../certs
# Trust the certificate in macOS System Keychain
sudo security add-trusted-cert -d -r trustRoot -k "/Library/Keychains/System.keychain" def.crt

# Modify hosts file (requires sudo)
if grep -Fq "$DOMAIN" "$HOSTFILE"; then
    echo -e "${Blue}Domain '$DOMAIN' already exists in $HOSTFILE.${Nc}"
else
    echo "127.0.0.1 $DOMAIN" >> "$HOSTFILE"
    echo -e "${Green}Added '$DOMAIN' to $HOSTFILE${Nc}"
    # Flush DNS cache
    sudo dscacheutil -flushcache
    sudo killall -HUP mDNSResponder
fi

echo "Setup completed! Please check your browser again."

