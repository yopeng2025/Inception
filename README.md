# Inception
- This is a system administration exercise that involves virtualizing a small infrastructure using Docker. The goal is to set up a multi-container architecture containing Nginx (TLS v1.2/v1.3), WordPress (PHP-FPM), and MariaDB, all running on Debian Bullseye.

- The communication flow between containers is strictly controlled within a private bridge network:
- `Browser` --(443)--> `Nginx` --(9000)--> `WordPress` --(3306)--> `MariaDB`

## Features
- **Security:**           Nginx is the only entry point, configured with TLS v1.2/v1.3
- **Persistence:**        Data is stored in Named Volume mapped to `/home/yopeng/data`
- **Automation:**         WordPress is fully configured through `wp-cli` during the first container startup
- **Process Management:** Every container runs its main process as PID1 for proper signal handling (SIGTERM)
- **No Latest Tags:**     All base images use specific version - Debian Bullseye for its security, small footprint and   compatibility with PHP-FPM 7.4.

## Design Choices
### 1. Virtual Machine vs Docker
- **Virtual Machine (VM)** virtualize the hardware. Each VM includes a full Guest OS, making it heavy (GBs), slow to boot, and resource-intensive.
- **Docker (Container)** virtualize the OS. Containers share the host kernel but remain isolated. Tehy are lightweight (MBs), start in seconds, and have near-native performance.
- **Choice:** Docker is chosen to ensure protability and high resource efficiency.
### 2. Secrets vs Environment Variables
- **Secrects (file)** encrypted at rest and only mounted into the container's memory during runtime.
- **Environment Variables (.env)** are stored in plain text within the container's environment. They are easy to use but can be leaked through `docker inspect` or process logs.
- **Choice:** While the 42 subject allows Environment Variables (.env), Secrets (file) is the best practice for production environments to prevent credential leakage.
### 3. Docker Network vs Host Network
- **Host Network** allows container share host's IP and port space directly. There is no isolation between the container and the host's network stack.
- **Docker Network (bridge)** creates a private virtual network. Containers can communicate with each other using internal DNS, and only specific ports (443) goes through to the host.
- **Choice:** Docker Network is used to ensure the database remains hidden from the public internet.
### 4.Docker Volume vs Bind Mounts
- **Bind Mounts** link a specific path on the host to a path in the container. They depend on the host's file system structure.
- **Docker Volume** manages entirely by docker. They are indenpendent of the host's directory structure and are the preferred way to persist data in production.
- **Choice:** Data Named Volume are used to comply with the requirement for managed data persistence while stilling mapping them to `/home/yopeng/data`. 

## Usage
### 1. Domain Setup         
  `nano /etc/hosts`, and add this line `127.0.0.1 yopeng.42.fr`
### 2. Environment Variables
  create a `.env` file in the `srcs/` directory
  ```
        DOMAIN_NAME=yopeng.42.fr
        DATA_PATH=/home/yopeng/data
        SQL_DATABASE=inception
        SQL_USER=yopeng
        SQL_PASSWORD=[your-password]
        SQL_ROOT_PASSWORD=[your-password]
        WP_URL=yopeng.42.fr
        WP_TITLE=Inception_Blog
        WP_ADMIN_USER=wp_yopeng_master
        WP_ADMIN_PASSWORD=[your-password]
        WP_USER=wp_yopeng
        WP_USER_PASSWORD=[your-password]
  ```
### 3. Build and Run
  ```bash
  make         #create directories, build images and start containers 
  make stop    #stop all services
  make fclean  #remove everything (containers, networks, volumes, and local data)
  ```
### 4. Access the site
  Open a browser and navigate to `https://yopeng.42.fr`
  (Advance -> still continue)
### 5. Inspect Volumes
 `docker volume inspect mariadb_data`

