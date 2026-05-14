**This project has been created as part of the 42 curriculum by yopeng**

# Inception
This is a system administration exercise that involves virtualizing a small infrastructure using Docker. The goal is to set up a multi-container architecture containing Nginx (TLS v1.2/v1.3), WordPress (PHP-FPM), and MariaDB, all running on Debian Bullseye.

> :bulb: **NOTICE**: For a detailed guide on how to setup such an infrastructure, please refer to the [developer documentation](DEV_DOC.md) and [user documentation](USER_DOC.md) for understanding services.

## Features
Security:           Nginx is the only entry point, configured with TLS v1.2/v1.3
Persistence:        Data is stored in Named Volume mapped to `/home/[login]/data`
Automation:         WordPress is fully configured through `wp-cli` during the first container startup
Process Management: Every container runs its main process as PID1 for proper signal handling (SIGTERM)
No Latest Tags:     All base images use specific version - Debian Bullseye for its security, small footprint and   compatibility with PHP-FPM 7.4.

The communication flow between containers is strictly controlled within a private bridge network:
    `Browser` --(443)--> `Nginx` --(9000)--> `WordPress` --(3306)--> `MariaDB`

## Structure
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

## Design Choices
1. Virtual Machine vs Docker
    Virtual Machine (VM) virtualize the hardware. Each VM includes a full Guest OS, making it heavy (GBs), slow to boot, and resource-intensive.

    Docker (Container) virtualize the OS. Containers share the host kernel but remain isolated. Tehy are lightweight (MBs), start in seconds, and have near-native performance.

    Choice: Docker is chosen to ensure protability and high resource efficiency.

2. Secrets vs Environment Variables
    Secrects (file) encrypted at rest and only mounted into the container's memory during runtime.
    
    Environment Variables (.env) are stored in plain text within the container's environment. They are easy to use but can be leaked through `docker inspect` or process logs.
    
    Choice: While the 42 subject allows Environment Variables (.env), Secrets (file) is the best practice for production environments to prevent credential leakage.

3. Docker Network vs Host Network
    Host Network allows container share host's IP and port space directly. There is no isolation between the container and the host's network stack.

    Docker Network (bridge) creates a private virtual network. Containers can communicate with each other using internal DNS, and only specific ports (443) goes through to the host.

    Choice: Docker Network is used to ensure the database remains hidden from the public internet.

4. Docker Volume vs Bind Mounts
    Bind Mounts link a specific path on the host to a path in the container. They depend on the host's file system structure.
    
    Docker Volume manages entirely by docker. They are indenpendent of the host's directory structure and are the preferred way to persist data in production.
    
    Choice: Data Named Volume are used to comply with the requirement for managed data persistence while stilling mapping them to `/home/[login]/data`. 

## Usage
1. Domain Setup         
        `sudo nano /etc/hosts`, and add this line `127.0.0.1 [login].42.fr`
2. Environment Variables
        create a `.env` file in the `srcs/` directory
```bash
DOMAIN_NAME=[login].42.fr
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
WP_USER_PASSWORD=[your-password]
```
4. Build and Run
        `make` create directories, build images and start containers 
        `make stop` stop all services
        `make clean` Stop and remove containers
        `make fclean` remove everything (containers, networks, volumes, and local data)
5. Access the site
        Open a browser and navigate to `https://[login].42.fr`
        (Advance -> still continue)
6. Inspect Volumes
        `docker volume inspect mariadb_data`

