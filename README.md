**This project has been created as part of the 42 curriculum by yopeng**

# Inception - Dockerized WordPress Infrastructure
This is a system administration exercise that involves virtualizing a small infrastructure using Docker. The goal is to set up a multi-container architecture containing Nginx (TLS v1.2/v1.3), WordPress (PHP-FPM), and MariaDB, all running on Debian Bullseye.


> :bulb: **NOTICE**: For a detailed guide on how to setup such an infrastructure, please refer to the [developer documentation](DEV_DOC.md) and [user documentation](USER_DOC.md) for understanding services.

## Features
Security:           Nginx is the only entry point, configured with TLS v1.2/v1.3
Automation:         WordPress is fully configured through `wp-cli` during the first container startup
Persistence:        Data is stored in Named Volume mapped to `/home/[login]/data`
Process Management: Every container runs its main process as PID1 for proper signal handling (SIGTERM)
No Latest Tags:     All base images use specific version - Debian Bullseye for its security, small footprint and   compatibility with PHP-FPM 7.4.

The communication flow between containers is strictly controlled within a private bridge network:
`Browser` <--(443)--> |`Nginx` <--(9000)--> `WordPress` <--(3306)--> `MariaDB`|

## Security

- TLS v1.2/v1.3 only
- No root process exposed to public network
- MariaDB isolated inside private Docker network
- FTP users jailed using `chroot`
- Passive FTP ports explicitly restricted
- No usage of `latest` tags
- Containers communicate only through internal bridge network
- Environment variables separated through `.env`

## Bonus
This project also includes several additional services integrated into the Docker infrastructure:

| Service | Purpose |
|----------|----------|
| FTP (vsftpd) | Secure file transfer for WordPress volume |
| Redis | WordPress object caching |
| Adminer | Lightweight database management interface |
| Static Website | Additional static Nginx website |
| Uptime Kuma | Infrastructure and service monitoring dashboard |

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
│       ├── bonus
│       │   ├── adminer
│       │   │   └── Dockerfile
│       │   ├── ftp
│       │   │   ├── conf
│       │   │   │   └── vsftpd.conf
│       │   │   ├── Dockerfile
│       │   │   └── tools
│       │   │       └── setup.sh
│       │   ├── redis
│       │   │   └── Dockerfile
│       │   ├── static_site
│       │   │   ├── Dockerfile
│       │   │   └── index.html
│       │   └── uptime_kuma
│       │       └── Dockerfile
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

    Choice: Docker is chosen to ensure portability and high resource efficiency.

2. Secrets vs Environment Variables
    Secrets (file) encrypted at rest and only mounted into the container's memory during runtime.
    
    Environment Variables (.env) are stored in plain text within the container's environment. They are easy to use but can be leaked through `docker inspect` or process logs.
    
    Choice: While the 42 subject allows Environment Variables (.env), Secrets (file) is the best practice for production environments to prevent credential leakage.

3. Docker Network vs Host Network
    Host Network allows container share host's IP and port space directly. There is no isolation between the container and the host's network stack.

    Docker Network (bridge) creates a private virtual network. Containers can communicate with each other using internal DNS, and only specific ports (443) are exposed to the host.

    Choice: Docker Network is used to ensure the database remains hidden from the public internet.

4. Docker Volume vs Bind Mounts
    Bind Mounts link a specific path on the host to a path in the container. They depend on the host's file system structure.
    
    Docker Volume manages entirely by Docker. They are independent of the host's directory structure and are the preferred way to persist data in production.
    
    Choice: Data Named Volume are used to comply with the requirement for managed data persistence while still mapping them to `/home/[login]/data`. 

5. Why Debian Bullseye?
- Long-term stability
- Strong package reliability
- Compatibility with PHP 7.4 required by the subject
- Smaller attack surface compared to full-featured distributions
- Excellent Docker ecosystem support

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
#bonus
REDIS_PASSWORD=[your-password]
FTP_USER=[login]
FTP_PASSWORD=[your-password]
```
3. Build and Run
        `make` create directories, build images and start containers 
        `make stop` stop all services
        `make clean` Stop and remove containers
        `make fclean` remove everything (containers, networks, volumes, and local data)
4. Access the site
        Open a browser and navigate to `https://[login].42.fr`
        (Advance -> still continue)
   
| Service | URL / Port |
|----------|-------------|
| WordPress | https://[login].42.fr |
| Adminer | https://[login].42.fr/adminer |
| Static Site | https://[login].42.fr/static |
| Uptime Kuma | http://localhost:3001 |
| FTP | Port 21 + PASV 21100-21110 |

5. Inspect Volumes
        `docker volume inspect mariadb_data`

## Lessons Learned

Through this project, I learned:

- Docker image layering and optimization
- PID1 signal handling inside containers
- Difference between bind mounts and named volumes
- TLS configuration with Nginx
- WordPress automation using wp-cli
- Linux permissions and FTP chroot isolation
- Docker networking and service discovery
- Importance of minimal containers and single-process design

## Resources
- [What is Docker? How Does it Work?](https://devopscube.com/what-is-docker/)<br>
- [Containers vs. Virtual Machines](https://blogs.umass.edu/Techbytes/2018/10/09/what-is-docker-and-how-does-it-work/)<br>
- [Docker Tutorial for Beginners](https://www.youtube.com/watch?v=zJ6WbK9zFpI&ab_channel=KodeKloud)<br>
- [Explaining Docker Networking Concepts](https://ostechnix.com/explaining-docker-networking-concepts/)<br>
- [ Dockerfile tutorial by example - basics and best practices](https://takacsmark.com/dockerfile-tutorial-by-example-dockerfile-best-practices-2018)
- [Docker networking is CRAZY!!!](https://www.youtube.com/watch?v=bKFMS5C4CG0&ab_channel=NetworkChuck)<br>
- [How To Communicate Between Docker Containers](https://www.tutorialworks.com/container-networking/)<br>
 - [WordPress Deployment with NGINX, PHP-FPM and MariaDB using Docker Compose](https://medium.com/swlh/wordpress-deployment-with-nginx-php-fpm-and-mariadb-using-docker-compose-55f59e5c1a)
 - [How To Configure Nginx to use TLS 1.2 / 1.3 only](https://www.cyberciti.biz/faq/configure-nginx-to-use-only-tls-1-2-and-1-3/)
 - [How To Install MariaDB](https://www.digitalocean.com/community/tutorials/how-to-install-mariadb-on-ubuntu-20-04)
 -  [How to install WordPress Using wp-cli](https://blog.sucuri.net/2022/11/wp-cli-how-to-install-wordpress-via-ssh.html)
 - [Learn CGI and FastCGI](https://www.howtoforge.com/install-adminer-database-management-tool-on-debian-10/)
 - [How To Set Up vsftpd](https://www.digitalocean.com/community/tutorials/how-to-set-up-vsftpd-for-a-user-s-directory-on-ubuntu-20-04)
 - [install adminer](https://www.howtoforge.com/install-adminer-database-management-tool-on-debian-10/)
