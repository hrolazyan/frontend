## Prepare the `docker-compose.yaml` file configurations.
Change the `DEFAULT_EMAIL` value to your email address.
```yaml
services:
    ...
    letsencrypt: 
        environment:
            DEFAULT_EMAIL: your_email_address
```

## 1. Log in to the remote `host`
```sh
ssh root@host
```

## 2. Install docker
```sh
apt-get update
apt-get install -y git docker-compose
```

## 3. Setup remote git `bare` repo 
```sh
mkdir /frontend
mkdir /var/repo/

mkdir /var/repo/frontend.git
cd /var/repo/frontend.git/
git init --bare
cd hooks
sudo nano post-receive
```
Create a `post-receive` hook 
```sh
#!/bin/sh
git --work-tree=/frontend --git-dir=/var/repo/frontend.git checkout -f
```
make the hook executable
```sh
chmod +x post-receive
```

## 4. Add a `live` remote to the local git repo
```sh
git remote add live ssh://root@host/var/repo/frontend.git
```
push changes to the `live` remote
```sh
git push live master
```

## 5. Go to the source directory on the `host` and build with `docker-compose`
```sh
cd /frontend
docker-compose up -d --build
```

## 6. Review the build
```sh
docker ps
docker network ls
```

