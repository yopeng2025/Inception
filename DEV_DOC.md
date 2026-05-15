**This project has been created as part of the 42 curriculum by yopeng**

# This document provides technical instructions for developers to set up, build, and manage the Inception infrastructure.

> :bulb: **NOTICE**: For understanding services, please refer to the [user documentation](USER_DOC.md).

## 1. Vitrual Machine Setup
 1. download a linux image ([here](https://www.debian.org/distrib/) is a link for the official debian website), for the purposes of installing your Virtual Machine. Click `64-bit PC netinst iso` and download.

 2. then follow for [this](https://github.com/Bakr-1/inceptionVm-guide) very helpful and detailed guide. 

 3. during software installation, I personally chose [Xfce], [SSH server] and [standard system utilities] for GUI installation.

 4. if you skip stpe3, you can still download GUI by using
```bash
    sudo apt update && sudo apt upgrade -y
    sudo apt install task-xfce-desktop -y
```
 5. install docker packages (docker compose)
```bash
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

 ## 2. Configuration
 1. write the configuration files according to the requirements of the subjet.
 ### Structure
```bash
├── Makefile
├── README.md
├── DEV_DOC.md
├── USER_DOC.md
├── srcs
│   ├── .env
│   ├── docker-compose.yml
│   └── requirements
│       ├── mariadb
│       │   ├── conf
│       │   │   └── 50-server.cnf
│       │   ├── Dockerfile
│       │   └── tools
│       │       └── setup.sh
│       ├── nginx
│       │   ├── conf
│       │   │   └── nginx.conf
│       │   ├── Dockerfile
│       │   └── tools
│       │       └── setup.sh
│       └── wordpress
│           ├── conf
│           │   └── www.conf
│           ├── Dockerfile
│           └── tools
└──             └── setup.sh
```
2.  domain Setup         
        `sudo nano /etc/hosts`, and add this line `127.0.0.1 [login].42.fr`
3.  create a `.env` file in the `srcs/` directory, and put credentials inside.
        `DOMAIN_NAME=[login].42.fr
        DATA_PATH=/home/[login]/data
        SQL_DATABASE=inception
        SQL_USER=[login]
        SQL_PASSWORD=[your-password]
        SQL_ROOT_PASSWORD=[your-password]
        WP_URL=[login].42.fr
        WP_TITLE=Inception_Blog
        WP_ADMIN_USER=wp_master
        WP_ADMIN_PASSWORD=[your-password]
        WP_USER=wp_user
        WP_USER_PASSWORD=[your-password]`

## 3. Validate Website

1. run dockers: `docker compose -f ./srcs/docker-compose.yml up -d --build`

2. check if containers are running: `docker ps`
   start/stop container: `docker start <name>`, `docker stop <name>`
   show config files: `docker exec -it <name> /bin/sh`
   check if network is working: `docker network ls`, `docker network inspect nginx`, `docker network inspect wordpress`, `docker network inspect mariadb`
   check if volumes: `docker volume ls`, `docker volume inspect <name>`
   check if website is ready: `curl -k http://localhost`

3. try to access `https://[username].42.fr`, it should show a warning sign of self signed certificate, click `advanced` and `continue`

4. if anything goes wrong, try to check logs first: `docker logs nginx`, `docker logs wordpress`, `docker logs mariadb`
   manual clean broken volume: `docker volume rm <volume_name>`

5. restart containers: `docker-compose down` and then `docker-compose up -d --build`

6. try to access admin page `https://[login].42.fr/wp-admin` by using admin credentials in `.env`
 
 ## 4. Data
 1. The data is stored on the Host Machine (VM) in the paths defined in .env and docker-compose.yml 
 `/home/[login]/data`
    MariaDB Database: /home/[login]/data/mariadb
    WordPress Files: /home/[login]/data/wordpress
2. Bind Mount helps data persistence.
    **Decoupling:** By default, container data is stored in a "writable layer" that is deleted when the container is removed (docker rm). To prevent this, we decouple the data from the container's lifecycle.
    **Mounting** binds a directory on the host machine (VM) to a directory inside the container.
    Example: `/home/[login]/data/mariadb` is mounted to `/var/lib/mysql` inside the MariaDB container.
    **Real-time Sync** when MariaDB/WordPress writes a database record, it is physically written to the host's hard drive instandtly
    **Inheritance** when runs `make` again, the new container mounts the same host directory and inherits all the previous data