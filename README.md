## 1. Log in to the remote `host`
```
ssh root@host
```

## 2. Install docker
```
apt-get update
apt-get install -y git docker-compose
```

## 3. Setup remote git `bare` repo 
```
mkdir /frontend
mkdir /var/repo/

mkdir /var/repo/frontend.git
cd /var/repo/frontend.git/
git init --bare
cd hooks
sudo nano post-receive
```
Create a `post-receive` hook 
```
#!/bin/sh
git --work-tree=/frontend --git-dir=/var/repo/frontend.git checkout -f
```
make the hook executable
```
chmod +x post-receive
```

## 4. Add a `live` remote to the local git repo
```
git remote add live ssh://root@host/var/repo/frontend.git
```
push changes to the `live` remote
```
git push live master
```

## 5. Go to the source directory on the `host` and build with `docker-compose`
```
cd /frontend
docker-compose up -d --build
```

## 6. Review the build
```
docker ps
docker network ls
```

