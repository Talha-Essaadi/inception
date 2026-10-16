*This project has been created as part of the 42 curriculum by tessaadi.*

# Inception

## Description

**Inception** is a System Administration project from the 42 curriculum. The goal of this project is to build a small, secure, and persistent web infrastructure using **Docker Compose** inside a Virtual Machine.

Instead of using ready-made application images, each service is built from a custom Dockerfile based on either Debian or Alpine. Each service runs in its own dedicated container and communicates with the other services through a dedicated Docker network.

The mandatory infrastructure consists of:

* **NGINX** as the only HTTPS entry point.
* **WordPress** with PHP-FPM.
* **MariaDB** as the database server.
* Two persistent Docker named volumes:

  * One for the MariaDB database.
  * One for WordPress website files.
* A dedicated Docker network connecting the services.

The project also includes several bonus services:

* **Redis** for WordPress object caching.
* **FTP** server for managing WordPress website files.
* **Static website** served through the infrastructure.

The complete infrastructure runs inside a Virtual Machine.

---

# Architecture

The main architecture is:

```text
                         Internet / Browser
                                |
                              HTTPS
                             Port 443
                                |
                                v
                         +--------------+
                         |    NGINX     |
                         | TLS 1.2/1.3  |
                         +------+-------+
                                |
                    +-----------+-----------+
                    |                       |
                    v                       v
             +-------------+        +--------------+
             |  WordPress  |        | Static Site  |
             |  PHP-FPM    |        | HTML/CSS/JS  |
             +------+------+        +--------------+
                    |
                    |
                    v
             +-------------+
             |   MariaDB   |
             +-------------+
                    |
                    v
             +-------------+
             | DB Volume   |
             +-------------+

             +-------------+
             | WordPress   |
             | Data Volume |
             +-------------+

             +-------------+
             |    Redis    |
             |    Cache    |
             +-------------+

             +-------------+
             |     FTP     |
             | WordPress   |
             | Files       |
             +-------------+
```

All containers communicate through the custom Docker network.

NGINX is the entry point for the mandatory web infrastructure and handles HTTPS connections.

---

# Services

## NGINX

NGINX is the public-facing web server and reverse proxy.

Responsibilities:

* HTTPS termination.
* TLS 1.2 / TLS 1.3.
* Serving requests from the web infrastructure.
* Forwarding PHP requests toward WordPress/PHP-FPM.
* Routing requests to the static website when configured.
* Acting as the only mandatory entry point on port `443`.

NGINX does not contain WordPress or PHP-FPM.

---

## WordPress

The WordPress container contains:

* WordPress.
* PHP-FPM.
* Required PHP extensions.

PHP-FPM processes PHP requests received from NGINX.

The WordPress container does not contain NGINX.

The WordPress files are stored in the persistent `wordpress_data` named volume.

---

## MariaDB

MariaDB is the database server used by WordPress.

The database is stored in a persistent named volume so that the database survives container recreation.

The WordPress database contains at least two users, including an administrator account whose username does not contain `admin` or `administrator`.

---

# Bonus Services

## Redis

Redis is used as an object cache for WordPress.

The WordPress Redis cache plugin communicates with the Redis service through the Docker network.

This reduces the need to repeatedly retrieve the same data from MariaDB and can improve application performance.

---

## FTP

The FTP service uses `vsftpd`.

It provides access to the WordPress website files through FTP.

The FTP container shares the WordPress named volume with the WordPress service:

```text
wordpress_data
       |
       +----> WordPress container
       |
       +----> FTP container
```

This allows files uploaded or modified through FTP to be available to WordPress.

The FTP service uses passive-mode ports in addition to the FTP control port.

---

## Static Website

A separate static website is included as a bonus service.

The website is implemented without PHP and consists of static web technologies such as:

* HTML
* CSS
* JavaScript

The static website runs in its own container and can be exposed through NGINX routing.

---

# Project Structure

The project follows the structure required by the 42 subject:

```text
.
├── Makefile
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
├── secrets/
│   ├── db_password.txt
│   ├── db_root_password.txt
│   └── ftp_password.txt
│
└── srcs/
    ├── .env
    ├── docker-compose.yml
    │
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile
        │   ├── conf/
        │   └── tools/
        │
        ├── nginx/
        │   ├── Dockerfile
        │   ├── conf/
        │   └── tools/
        │
        ├── wordpress/
        │   ├── Dockerfile
        │   ├── conf/
        │   └── tools/
        │
        └── bonus/
            ├── redis/
            ├── ftp/
            └── static/
```

The exact contents of the bonus directories may vary depending on the implementation.

---

# Docker Design

## Why Docker?

Docker provides process-level isolation for each service while allowing the services to communicate through a virtual network.

Each service has its own:

* Filesystem layer.
* Processes.
* Dependencies.
* Configuration.
* Network identity.

This makes the infrastructure modular and reproducible.

The project uses Docker Compose to define how the services, networks, volumes, environment variables, secrets, and dependencies are connected.

---

# Virtual Machines vs Docker

## Virtual Machine

A Virtual Machine emulates a complete computer environment.

It normally includes:

* Virtual hardware.
* A complete operating system.
* Kernel.
* System libraries.
* Applications.

Advantages:

* Strong isolation.
* Can run a completely different operating system.
* Complete OS environment.

Disadvantages:

* Higher memory and CPU overhead.
* Each VM requires its own operating system.
* Slower startup compared with containers.

## Docker

Docker containers share the host kernel while isolating applications and their dependencies.

Advantages:

* Lightweight.
* Fast startup.
* Efficient resource usage.
* Easy service isolation.
* Reproducible environments.

Disadvantages:

* Containers share the host kernel.
* Isolation is different from full hardware virtualization.

In this project, the required Virtual Machine provides the isolated environment in which the Docker infrastructure runs.

---

# Secrets vs Environment Variables

## Environment Variables

Environment variables are useful for configuration values such as:

```text
DOMAIN_NAME=tessaadi.42.fr
MYSQL_DATABASE=wordpress
MYSQL_USER=wordpress
```

They are appropriate for configuration that does not need to be treated as a secret.

The project uses a `.env` file for environment configuration as required by the subject.

## Docker Secrets

Sensitive information such as passwords should not be stored directly inside Dockerfiles or committed to Git.

For example:

```text
secrets/
├── db_password.txt
├── db_root_password.txt
└── ftp_password.txt
```

The services can access these secrets through:

```text
/run/secrets/
```

This separates sensitive credentials from normal configuration.

---

# Docker Network vs Host Network

## Docker Network

The project uses a custom Docker network.

For example:

```text
inception
```

Containers communicate with each other through service names.

For example:

```text
wordpress
mariadb
redis
ftp
```

A container can reach another service using its Docker DNS name instead of using the host network.

This provides network isolation and makes the infrastructure easier to manage.

## Host Network

With host networking, a container uses the host's network namespace.

This provides less network isolation and can create port conflicts with services running directly on the host.

The Inception subject explicitly prohibits using host networking.

Therefore, this project uses a dedicated Docker bridge network.

---

# Docker Volumes vs Bind Mounts

## Docker Named Volumes

Docker named volumes are managed by Docker and are designed for persistent container data.

This project uses named volumes for:

```text
wordpress_data
mariadb_data
```

The volumes are mapped to:

```text
/home/tessaadi/data/
```

on the host as required by the subject.

The WordPress volume is mounted into the relevant containers at:

```text
/var/www/html
```

This allows the WordPress and FTP containers to access the same persistent website files.

## Bind Mounts

A bind mount directly maps a host filesystem path into a container.

For example:

```text
/home/user/project:/app
```

Bind mounts are useful during development, but the Inception subject explicitly requires Docker named volumes for the WordPress and MariaDB persistent storage.

Therefore, named volumes are used for the mandatory persistent data.

---

# Persistence

The project has two mandatory persistent storage areas.

## MariaDB volume

Contains the WordPress database.

```text
mariadb_data
        |
        v
/var/lib/mysql
```

## WordPress volume

Contains the WordPress website files.

```text
wordpress_data
        |
        v
/var/www/html
```

The data remains available even when the corresponding containers are removed and recreated.

---

# Security

Several security requirements are implemented according to the Inception subject.

## HTTPS

NGINX uses TLS and only enables:

* TLS 1.2
* TLS 1.3

The mandatory web infrastructure is accessed through HTTPS on:

```text
443
```

## Credentials

Passwords are not hardcoded into Dockerfiles.

Sensitive credentials are stored separately and provided to containers using Docker secrets.

The `secrets/` directory must not be committed to the Git repository.

For example:

```text
secrets/
```

should be included in `.gitignore`.

## No `latest` tag

The project does not use the Docker `latest` tag.

## Dedicated containers

Each service runs in its own container.

The services are not combined into a single container.

## No infinite-loop container processes

The containers use their actual foreground service processes instead of artificial commands such as:

```text
tail -f
sleep infinity
while true
```

This follows Docker PID 1 and container best practices.

---

# Domain Name

The project uses the 42-required domain:

```text
tessaadi.42.fr
```

The domain must resolve to the local IP address of the Virtual Machine.

For local testing, the `/etc/hosts` file can be configured so that:

```text
<VM_IP>    tessaadi.42.fr
```

The website can then be accessed through:

```text
https://tessaadi.42.fr
```

---

# Instructions

## Prerequisites

The project requires:

* A Virtual Machine.
* Debian or another supported Linux environment.
* Docker.
* Docker Compose.
* Git.
* Sufficient permissions to run Docker.
* Network access for installing required packages during image construction.

The project should be executed from the root of the repository.

---

# Configuration

The main Docker Compose configuration is located at:

```text
srcs/docker-compose.yml
```

Environment variables are stored in:

```text
srcs/.env
```

Sensitive credentials are stored separately under:

```text
secrets/
```

Example configuration:

```text
DOMAIN_NAME=tessaadi.42.fr
```

The actual credentials should never be committed to Git.

---

# Build and Start

From the project root:

```bash
make
```

The Makefile builds the Docker images and starts the infrastructure using Docker Compose.

Depending on the Makefile implementation, the equivalent Docker Compose command is:

```bash
docker compose -f srcs/docker-compose.yml up -d --build
```

To see the running containers:

```bash
docker compose -f srcs/docker-compose.yml ps
```

---

# Stop the Project

To stop the containers:

```bash
make down
```

or:

```bash
docker compose -f srcs/docker-compose.yml down
```

Stopping the containers does not remove the persistent named volumes.

---

# Rebuild the Project

To rebuild the images:

```bash
make re
```

The exact behavior depends on the Makefile implementation.

A manual rebuild can be performed with:

```bash
docker compose -f srcs/docker-compose.yml build --no-cache
```

Then:

```bash
docker compose -f srcs/docker-compose.yml up -d
```

---

# Checking the Infrastructure

List running containers:

```bash
docker ps
```

Check Compose services:

```bash
docker compose -f srcs/docker-compose.yml ps
```

View logs:

```bash
docker compose -f srcs/docker-compose.yml logs
```

View logs for one service:

```bash
docker compose -f srcs/docker-compose.yml logs nginx
```

Follow logs:

```bash
docker compose -f srcs/docker-compose.yml logs -f wordpress
```

Inspect the Docker network:

```bash
docker network ls
```

Inspect the Inception network:

```bash
docker network inspect inception
```

---

# Checking Volumes

List Docker volumes:

```bash
docker volume ls
```

Inspect a volume:

```bash
docker volume inspect wordpress_data
```

and:

```bash
docker volume inspect mariadb_data
```

The persistent data is stored under the required host directory:

```text
/home/tessaadi/data/
```

---

# Accessing WordPress

Once the infrastructure is running, open:

```text
https://tessaadi.42.fr
```

The WordPress administration interface is available at:

```text
https://tessaadi.42.fr/wp-admin/
```

The WordPress administrator credentials are stored separately from the public project configuration.

---

# FTP

The FTP service provides access to the WordPress files.

The FTP server uses:

```text
Port 21
```

and passive-mode ports configured by the project.

Example connection:

```bash
ftp tessaadi.42.fr
```

A file can be uploaded using:

```ftp
put file.txt
```

The uploaded file becomes available inside the shared WordPress volume.

---

# Redis

Redis communicates with WordPress through the Docker network.

The WordPress Redis cache configuration allows WordPress object data to be cached in Redis instead of repeatedly retrieving the same data from MariaDB.

The Redis service is not required to be publicly exposed because WordPress can communicate with it through the internal Docker network.

---

# Static Website

The static website is implemented without PHP.

It uses static web technologies such as:

```text
HTML
CSS
JavaScript
```

The static service runs in its own container.

NGINX can route requests to the static service according to the configured server rules.

---

# Makefile

The Makefile provides commands for managing the infrastructure.

Typical commands include:

```bash
make
make up
make down
make re
make clean
make fclean
```

The exact available commands depend on the implementation.

The Makefile is responsible for invoking Docker Compose and building the required Docker images.

---

# Container Management

List all containers:

```bash
docker ps -a
```

Enter a running container:

```bash
docker exec -it <container_name> bash
```

For example:

```bash
docker exec -it wordpress bash
```

Inspect a container:

```bash
docker inspect <container_name>
```

Restart a service:

```bash
docker restart <container_name>
```

---

# Data Management

The mandatory data is stored in Docker named volumes.

Removing containers does not remove the volumes unless explicitly requested.

To list volumes:

```bash
docker volume ls
```

To remove a specific volume:

```bash
docker volume rm <volume_name>
```

**Warning:** Removing a volume permanently deletes the data stored inside it.

---

# Technical Choices

## Debian

Debian was selected as the base distribution for the containers because it provides:

* Stable package management.
* Extensive documentation.
* Familiar Linux administration tools.
* A large package ecosystem.

## Docker Compose

Docker Compose is used to describe the multi-container infrastructure in a declarative configuration.

It defines:

* Services.
* Networks.
* Volumes.
* Secrets.
* Environment variables.
* Service dependencies.
* Port mappings.

## NGINX + PHP-FPM

NGINX handles HTTP/HTTPS communication while PHP-FPM processes PHP scripts.

This separation follows the requirement that WordPress and PHP-FPM run independently from NGINX.

## MariaDB

MariaDB provides relational database storage for WordPress.

## Redis

Redis provides an in-memory object cache for WordPress.

## FTP

FTP provides a separate method for managing WordPress website files.

---

# Resources

The following resources were used to understand and implement the project:

### Docker

* Docker Documentation
  https://docs.docker.com/

* Docker Compose Documentation
  https://docs.docker.com/compose/

* Docker Volumes
  https://docs.docker.com/engine/storage/volumes/

* Docker Networking
  https://docs.docker.com/engine/network/

### NGINX

* NGINX Documentation
  https://nginx.org/en/docs/

* NGINX Beginner's Guide
  https://nginx.org/en/docs/beginners_guide.html

### PHP-FPM

* PHP Documentation
  https://www.php.net/docs.php

* PHP-FPM Documentation
  https://www.php.net/manual/en/install.fpm.php

### MariaDB

* MariaDB Documentation
  https://mariadb.com/docs/

### Redis

* Redis Documentation
  https://redis.io/docs/

### WordPress

* WordPress Developer Documentation
  https://developer.wordpress.org/

### vsftpd

* vsftpd Documentation
  https://security.appspot.com/vsftpd.html

### Linux

* Linux `man` pages.
* Debian Documentation
  https://www.debian.org/doc/

---

# AI Usage

AI tools were used as a learning and productivity aid during the development of this project.

AI was used for:

* Explaining Docker concepts.
* Understanding Docker Compose configuration.
* Understanding Docker networks and DNS.
* Understanding Docker named volumes.
* Understanding bind mounts versus named volumes.
* Understanding Docker secrets and environment variables.
* Debugging service configuration.
* Understanding NGINX and reverse proxy configuration.
* Understanding PHP-FPM.
* Understanding MariaDB initialization.
* Understanding Redis integration.
* Understanding FTP and `vsftpd`.
* Reviewing shell scripts and Docker entrypoints.
* Explaining Linux commands and permissions.
* Helping investigate errors encountered during development.
* Improving project documentation.

AI-generated suggestions were tested and reviewed manually. The final implementation was adapted to the project's requirements and tested in the Virtual Machine.

The use of AI does not replace understanding of the implementation. Every part of the infrastructure should be explainable during the project defense.

---

# Learning Objectives

Through this project, the main objectives are to develop practical knowledge of:

* Linux system administration.
* Docker.
* Docker Compose.
* Containerization.
* Networking.
* DNS.
* TLS/HTTPS.
* NGINX.
* PHP-FPM.
* MariaDB.
* WordPress.
* Docker volumes.
* Docker secrets.
* Environment variables.
* Linux permissions.
* Process management.
* Service isolation.
* Persistent storage.
* Infrastructure configuration.

---

# Conclusion

Inception provides a practical introduction to containerized infrastructure.

The final infrastructure separates the main components of a WordPress application into independent services:

```text
NGINX
  |
  +---- WordPress / PHP-FPM
  |          |
  |          +---- MariaDB
  |          |
  |          +---- Redis
  |
  +---- Static Website

FTP
  |
  +---- WordPress Data Volume
```

Each component has a specific responsibility, while Docker Compose provides the infrastructure needed for communication, persistence, configuration, and service management.


# Steps:

```sh
1. Understand Dockerfile ✅
        ↓
2. Create simple Debian image ✅
        ↓
3. Create simple NGINX image ✅
        ↓
4. Create MariaDB Dockerfile ✅
        ↓
5. Make MariaDB container work ✅
        ↓
6. Add MariaDB volume ✅
        ↓
7. Create WordPress + PHP-FPM image ✅
        ↓
8. Connect WordPress → MariaDB ✅
        ↓
9. Create NGINX image ✅
        ↓
10. Configure NGINX + TLS ✅
        ↓
11. Connect NGINX → WordPress ✅
        ↓
12. Create docker-compose.yml ✅
        ↓
13. Add volumes/network/secrets ✅
        ↓
14. Configure tessaadi.42.fr ✅
        ↓
15. Test persistence / restart / failure cases ✅
        ↓
16. Makefile ✅
        ↓
17. README + USER_DOC + DEV_DOC ❌
        ↓
18. Bonus ✅
```

## STEPS:
```sh
STEP 1
│
├── Understand Docker fundamentals
│   ├── Images
│   ├── Containers
│   ├── Dockerfile
│   ├── Compose
│   ├── Networks
│   ├── Volumes
│   └── Secrets
│
▼
STEP 2
Create project structure
│
▼
STEP 3
Create docker-compose.yml
│
├── nginx
├── wordpress
├── mariadb
├── network
└── volumes
│
▼
STEP 4
Build MariaDB image
│
▼
STEP 5
Make MariaDB work
│
▼
STEP 6
Build WordPress + PHP-FPM image
│
▼
STEP 7
Connect WordPress → MariaDB
│
▼
STEP 8
Build NGINX image
│
▼
STEP 9
Configure TLS
│
▼
STEP 10
Connect NGINX → WordPress
│
▼
STEP 11
Configure volumes/persistence
│
▼
STEP 12
Configure domain
    tessaadi.42.fr
│
▼
STEP 13
Test everything
│
▼
STEP 14
Write documentation
│
▼
STEP 15
Only then consider BONUS
```