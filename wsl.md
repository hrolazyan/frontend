
# INITIAL SETUP
https://stackoverflow.com/questions/21488845/how-can-i-generate-a-self-signed-certificate-with-subjectaltname-using-openssl


```sh
nano /etc/ssl/openssl.cnf
```

```conf
[ CA_default ]

# Extension copying option: use with caution.
copy_extensions = copy


[ v3_req ]

# Extensions to add to a certificate request

basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment


[ v3_ca ]

subjectAltName      = @alternate_names


[ alternate_names ]

DNS.1        = local.host
DNS.2        = *.local.host
DNS.3        = *.vin.local.host
DNS.4        = *.com.local.host
DNS.5        = *.org.local.host
```
---

```sh
openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout def.key -out def.crt
```

- Country Name (2 letter code) [AU]:am
- State or Province Name (full name) [Some-State]:yerevan
- Locality Name (eg, city) []:yerevan
- Organization Name (eg, company) [Internet Widgits Pty Ltd]:local.host
- Organizational Unit Name (eg, section) []:local
- Common Name (e.g. server FQDN or YOUR name) []:local.host
- Email Address []:hrolazyan@gmail.com

```sh
openssl x509 -in def.crt -text -noout
```
- X509v3 Subject Alternative Name:
- DNS:local.host, DNS:*.local.host
    
```sh
# printf "%s.crt" $vhost.cert
# /var/docker/nginx/certs:/etc/nginx/certs/
```

```sh
cp def.key /var/docker/nginx/certs/def.key
cp def.crt /var/docker/nginx/certs/def.crt
```


### Add def cert to Trusted Root Certificates

"C:/Windows/System32/drivers/etc/hosts" properties > security > advanced > Users - Full control


---

## FOR EACH VHOST DOMAIN

```sh
nano /mnt/c/Windows/System32/drivers/etc/hosts
```

```sh
#getvin
127.0.0.1 get-vin.local.host
127.0.0.1 api-get-vin.local.host
127.0.0.1 static-get-vin.local.host
127.0.0.1 db-get-vin.local.host
```


in docker-compose.yaml

```yaml
version: "3"
name: getvin
services:
  webserver:
    environment:
        VIRTUAL_HOST: get-vin.local.host
        CERT_NAME: def
  api:
    environment:
        VIRTUAL_HOST: api-get-vin.local.host
        CERT_NAME: def
  static:
    environment:
        VIRTUAL_HOST: static-get-vin.local.host
        CERT_NAME: def
  db:
    environment:
        VIRTUAL_HOST: db-get-vin.local.host
        CERT_NAME: def

```
