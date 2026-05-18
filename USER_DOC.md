**This project has been created as part of the 42 curriculum by yopeng**

# This document explains how to manage, access, and verify the Inception infrastructure.

> :bulb: **NOTICE**: For a detailed guide on how to setup such an infrastructure, please refer to the [developer documentation](DEV_DOC.md)

## Virtual Machine (Infrastructure)
VM is an independent OS (Guest VM) running on top of physical machine (Host), to ensure a fully isolated and clean environment, preventing any configuration conflicts with personal computer.

## Docker (Containerization)
Docker is a platform that packages code together with its entire runtime environment, which guarantees consistency across any machine. It solves the classic problem: "It works on my machine, but not on yours."

Key Components:
-   **Container:** A lightweight, standalone package that includes everything needed to run an application (code, runtime, system tools, libraries).
-   **Dockerfile (The Blueprint)**: A text document containing all the commands to assemble an image. Crucial: We specify exact versions (e.g., debian:bullseye) and avoid the latest tag to ensure stability.
-   **Docker Compose (The Orchestrator):** A tool used to define and manage multi-container applications (NGINX, MariaDB, etc.). It allows us to launch and link the entire architecture with a single command.

## The Services (The Architecture)
The stack provides the following services as a unified infrastructure:
- **Nginx**: Acts as the Reverse Proxy and TLS gateway (HTTPS), handling encrypted requests and serving static assets.
- **WordPress**: A PHP-based CMS (Content Management System) that processes dynamic content via PHP-FPM.
PHP-FPM (FastCGI Process Manager): Handles the processing of PHP code. It generates the HTML content and sends it back to NGINX to be displayed to the user.
- **MariaDB**: The relational database used to store WordPress posts, users, and configuration settings.

## Connectivity & Persistence
- **Volumes (Persistent Storage)**
    Concept: Since containers are ephemeral (data is lost when the container is deleted), a Volume acts like an External Hard Drive.
    Implementation: It maps a directory inside the container to a path on the Host VM (/home/[login]/data). This ensures that even if we delete the containers, our database and website files remain safe.
- **Network (Internal Communication)**
    Purpose: Allows isolated containers to "talk" to each other securely.
    Example: WordPress needs to communicate with MariaDB to fetch posts. We use a Docker Bridge Network so they can find each other using their container names as hostnames.

## Managing the Project (Start & Stop)

All operations are automated via the `Makefile` in the root directory.

### Start the project
    ```bash
    make        # To create the local data directories and launch all containers
    make stop   # To stop the running containers without removing them
    make clean  # to stop and remove containers, networks
    make fclean # To stop containers and delete all networks, images, and all persistent data
    ```
### Access website
1. map domain to local machine in `sudo nano /etc/hosts`: add line `127.0.0.1 [login].42.fr`
2. create a `.env` file in the `srcs/` directory, and put credentials inside.
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
3. URL: `https://[login].42.fr`, accept the self-signed certificate warning in browser(Advanced->Proceed)
4. URL: `https://[login].42.fr/wp-admin` to manage the WordPress site, using the admin credentials defined in `/inception/srcs/.env` file`

### Verify Service
    ```bash
    docker ps           # Check container status: should show "UP" status

    docker logs nginx   # Check logs for errors
    docker logs wordpress
    docker logs mariadb

    ls -la /home/[login]/data/wordpress  # Check WordPress and MariaDB are written to the host
    ls -la /home/[login]/data/mariadb
    ```