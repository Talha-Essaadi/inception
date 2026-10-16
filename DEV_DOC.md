# Developer Documentation — Inception

### Configuration

Before starting the project, create the required local configuration files.

#### 1. Create the `.env` file

Create:

```text
srcs/.env
```

Example:

```env
MYSQL_DATABASE=YOUR_DATABASE_NAME
MYSQL_USER=tessaadi
MYSQL_HOST=YOUR_HOST

WP_URL=https://tessaadi.42.fr
WP_TITLE=inception
WP_ADMIN_USER=tessaadi
WP_EDITOR_USER=talha
WP_ADMIN_EMAIL=YOUR_EMAIL@gmail.com
WP_EDITOR_EMAIL=YOUR_EDITOR_EMAIL@gmail.com

WP_REDIS_HOST=redis
WP_REDIS_PORT=6379
```

Do not commit this file to Git.

#### 2. Create the Docker secrets

Create the following files:

```text
secrets/
├── db_password.txt
├── db_root_password.txt
├── wp_admin_password.txt
├── wp_user_password.txt
└── ftp_password.txt
```

Each file should contain only the corresponding password.

For example:

```bash
mkdir -p secrets

echo "your_database_password" > secrets/db_password.txt
echo "your_root_password" > secrets/db_root_password.txt
echo "your_ftp_password" > secrets/ftp_password.txt
echo "your_wordpress_admin_password" > secrets/wp_admin_password.txt
echo "your_wordpress_user_password" > secrets/wp_user_password.txt
```

These files contain sensitive credentials and must not be committed to the Git repository.

#### 3. Start the project

After creating the configuration and secret files:

```bash
make
```

or use the Docker Compose commands described in the **Instructions** section.


## 1. Overview

This document explains how to set up, build, run, configure, and maintain the Inception infrastructure from a developer perspective.

The project runs inside a Virtual Machine and uses Docker Compose to create a small multi-container infrastructure.

The mandatory infrastructure consists of:

* **NGINX** — HTTPS entrypoint using TLS.
* **WordPress + PHP-FPM** — web application.
* **MariaDB** — WordPress database.
* **WordPress database volume** — persistent database storage.
* **WordPress files volume** — persistent WordPress files.
* **Custom Docker network** — communication between services.

The project also contains the following bonus services:

* **Redis** — WordPress object cache.
* **FTP** — access to the WordPress files volume.
* **Static website** — a separate non-PHP website service.

---

# 2. Prerequisites

The project must be run inside a Virtual Machine.

Recommended environment:

* Debian-based Linux Virtual Machine
* Docker Engine
* Docker Compose
* Make
* Git
* Sufficient disk space for Docker images and persistent volumes

Check the installed tools:

```bash
docker --version
docker compose version
make --version
git --version
```

If the system uses the legacy Compose command, use:

```bash
docker-compose --version
```

instead of:

```bash
docker compose version
```

The exact Compose command should match the configuration of the development environment.

---

# 3. Project Structure

The project follows the required Inception structure.

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
└── srcs/
    ├── .env
    ├── docker-compose.yml
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile
        │   ├── conf/
        │   │   └── 50-server.cnf
        │   └── tools/
        │       └── init.sh
        │
        ├── nginx/
        │   ├── Dockerfile
        │   ├── conf/
        │   └── tools/
        │
        ├── wordpress/
        │   ├── Dockerfile
        │   ├── conf/
        │   │   └── www.conf
        │   └── tools/
        │       └── init.sh
        │
        └── bonus/
            ├── redis/
            ├── ftp/
            └── static/
```

The exact files inside each service directory may evolve during development.

---

# 4. Configuration

## 4.1 Environment Variables

Non-confidential configuration is stored in:

```text
srcs/.env
```

For example:

```env
DOMAIN_NAME=tessaadi.42.fr

MYSQL_DATABASE=wordpress
MYSQL_USER=wpuser

WP_TITLE=Inception
WP_ADMIN_USER=...
WP_ADMIN_EMAIL=...
WP_USER=...
WP_USER_EMAIL=...
```

The `.env` file is used for configuration values that do not need to be treated as secrets.

Passwords and other confidential information must not be stored directly in the Dockerfiles or committed to the Git repository.

---

# 5. Docker Secrets

Sensitive values are stored locally in the `secrets/` directory.

Example:

```text
secrets/
├── db_password.txt
├── db_root_password.txt
└── ftp_password.txt
```

The files contain only the corresponding secret values.

For example:

```text
secrets/db_password.txt
```

contains the WordPress database user's password.

Docker Compose exposes these values to containers through:

```text
/run/secrets/
```

For example:

```text
/run/secrets/db_password
```

and:

```text
/run/secrets/db_root_password
```

The secrets directory must not be committed to the Git repository.

A suitable `.gitignore` should include:

```gitignore
secrets/
```

Sensitive files must never be pushed to a public repository.

---

# 6. Domain Configuration

The required domain follows the 42 convention:

```text
tessaadi.42.fr
```

The domain must resolve to the local IP address of the Virtual Machine.

For local development, the `/etc/hosts` file can be configured with the VM's IP address.

Example:

```text
192.168.X.X    tessaadi.42.fr
```

Verify the resolution:

```bash
getent hosts tessaadi.42.fr
```

or:

```bash
ping tessaadi.42.fr
```

The actual VM IP address should be used instead of `192.168.X.X`.

---

# 7. Building the Infrastructure

The project is controlled through the root `Makefile`.

From the project root:

```bash
make
```

The Makefile is responsible for starting the infrastructure and building the required Docker images through Docker Compose.

The build process creates the project images from the custom Dockerfiles.

No application image should be pulled from DockerHub as a replacement for the required custom-built services.

---

# 8. Docker Compose

The main Compose configuration is located at:

```text
srcs/docker-compose.yml
```

It defines:

* Services
* Dockerfiles/build contexts
* Environment variables
* Secrets
* Named volumes
* Custom network
* Port mappings
* Restart policies
* Service dependencies

The mandatory services are:

```text
nginx
wordpress
mariadb
```

The bonus services are:

```text
redis
ftp
static
```

The actual service names should match their corresponding Docker image names as required by the subject.

---

# 9. Building Manually with Docker Compose

If direct Docker Compose commands are needed, run them from the `srcs` directory:

```bash
cd srcs
```

Build all images:

```bash
docker compose build
```

Start the infrastructure:

```bash
docker compose up -d
```

Build and start:

```bash
docker compose up -d --build
```

Stop the containers:

```bash
docker compose down
```

Follow logs:

```bash
docker compose logs -f
```

Follow the logs of a specific service:

```bash
docker compose logs -f nginx
```

For example:

```bash
docker compose logs -f wordpress
docker compose logs -f mariadb
docker compose logs -f redis
```

---

# 10. Makefile

The Makefile is located at the root:

```text
Makefile
```

The Makefile should provide convenient commands for managing the infrastructure.

Typical targets include:

```bash
make
make build
make up
make down
make clean
make fclean
make re
```

The exact available targets depend on the implementation of the project's Makefile.

To inspect them:

```bash
cat Makefile
```

or:

```bash
make help
```

if a `help` target is implemented.

---

# 11. Container Management

List running containers:

```bash
docker ps
```

List all containers:

```bash
docker ps -a
```

Inspect a container:

```bash
docker inspect nginx
```

Execute a shell inside a running container:

```bash
docker exec -it nginx bash
```

For Alpine-based containers, use:

```bash
docker exec -it nginx sh
```

The same approach can be used for other services.

Examples:

```bash
docker exec -it wordpress sh
docker exec -it mariadb sh
docker exec -it redis sh
docker exec -it ftp sh
```

---

# 12. Docker Network

The services communicate through a custom Docker network.

For example:

```text
inception
```

Inspect available networks:

```bash
docker network ls
```

Inspect the project network:

```bash
docker network inspect inception
```

Containers on the same Docker network can communicate using their service names.

For example, WordPress can reach MariaDB through:

```text
mariadb
```

and Redis through:

```text
redis
```

The application does not need to know the container's dynamically assigned IP address.

---

# 13. WordPress and PHP-FPM

The WordPress container contains:

* WordPress
* PHP
* PHP-FPM
* Required PHP extensions
* MariaDB client functionality where required

NGINX and PHP-FPM are intentionally separated.

The architecture is:

```text
Browser
   |
   | HTTPS :443
   v
 NGINX
   |
   | FastCGI
   v
PHP-FPM / WordPress
   |
   v
MariaDB
```

PHP-FPM listens on its configured FastCGI port, for example:

```text
9000
```

NGINX communicates with PHP-FPM through the Docker network.

---

# 14. WordPress Initialization

The WordPress initialization script is responsible for preparing WordPress when the container starts.

Typical operations include:

1. Wait for MariaDB to become available.
2. Prepare the WordPress directory.
3. Generate `wp-config.php` when necessary.
4. Configure the database connection.
5. Install WordPress if it has not already been installed.
6. Create the administrator account.
7. Create the normal WordPress user.
8. Configure the WordPress site.

The WordPress database credentials are obtained from environment variables and/or Docker secrets rather than being hard-coded into the Dockerfile.

---

# 15. MariaDB

MariaDB runs in its own dedicated container.

Its responsibilities include:

* Initializing the database.
* Creating the WordPress database.
* Creating the WordPress database user.
* Creating the administrator/root database credentials.
* Persisting database data in the MariaDB named volume.

The MariaDB data directory is:

```text
/var/lib/mysql
```

inside the container.

The corresponding Docker volume provides persistence.

---

# 16. MariaDB Database Persistence

List Docker volumes:

```bash
docker volume ls
```

Inspect the MariaDB volume:

```bash
docker volume inspect <mariadb_volume>
```

The project must store persistent data under:

```text
/home/tessaadi/data
```

on the host machine.

The database must survive container recreation.

For example:

```bash
docker compose down
docker compose up -d
```

should not remove the database contents.

Removing containers is different from removing volumes.

Avoid deleting the database volume unless a complete database reset is intentionally required.

---

# 17. WordPress Files Volume

WordPress website files are stored in a second named Docker volume.

Inside the containers, the volume is mounted at:

```text
/var/www/html
```

Both WordPress and the FTP service can access this volume.

Conceptually:

```text
                  wordpress container
                         |
                         v
                 /var/www/html
                         |
                         v
                wordpress_data
                         ^
                         |
                         |
                    FTP container
```

This allows files uploaded through FTP to become available to WordPress.

---

# 18. Volume Management

List volumes:

```bash
docker volume ls
```

Inspect a volume:

```bash
docker volume inspect wordpress_data
```

Inspect the database volume:

```bash
docker volume inspect mariadb_data
```

Do not remove persistent volumes during normal development.

A command such as:

```bash
docker compose down -v
```

removes the Compose-managed volumes and therefore can delete persistent project data.

Use it only when intentionally resetting the entire infrastructure.

---

# 19. NGINX

NGINX is the HTTPS entrypoint of the infrastructure.

The mandatory public port is:

```text
443
```

The server must use TLSv1.2 and/or TLSv1.3.

The architecture is:

```text
Client
  |
  | HTTPS :443
  v
NGINX
  |
  +----> WordPress / PHP-FPM
  |
  +----> Static website
```

NGINX is responsible for:

* TLS termination.
* Serving/proxying the required website resources.
* Forwarding PHP requests to PHP-FPM.
* Routing requests to the appropriate service.

The NGINX container should be the only mandatory entrypoint to the main infrastructure.

---

# 20. TLS Testing

The HTTPS endpoint can be tested with:

```bash
curl -k https://tessaadi.42.fr
```

Verbose TLS information:

```bash
curl -vk https://tessaadi.42.fr
```

OpenSSL can also be used:

```bash
openssl s_client -connect tessaadi.42.fr:443
```

The TLS configuration should be checked to ensure that prohibited older protocols are not enabled.

---

# 21. Redis Bonus Service

Redis is used as a WordPress object cache.

The architecture becomes:

```text
WordPress
    |
    +----> MariaDB
    |
    +----> Redis
```

The Redis service runs in its own container.

WordPress communicates with Redis through the Docker network using the service name:

```text
redis
```

If the Redis WordPress plugin is installed, its configuration should point to the Redis service rather than `localhost`.

Inside the WordPress container, for example:

```bash
getent hosts redis
```

can verify that Docker DNS resolves the Redis service.

Check Redis:

```bash
docker exec -it redis redis-cli ping
```

A healthy Redis instance should return:

```text
PONG
```

---

# 22. FTP Bonus Service

The FTP server runs in its own container.

It is configured to access the WordPress named volume:

```text
wordpress_data
```

The volume is mounted at:

```text
/var/www/html
```

The FTP user can therefore manipulate WordPress files stored in the shared volume.

The FTP service uses a Docker secret for the FTP password.

The secret is available inside the container at:

```text
/run/secrets/ftp_password
```

The FTP user is configured with:

```text
/var/www/html
```

as its home directory when the service is initialized.

---

# 23. FTP Testing

Connect locally:

```bash
ftp localhost
```

Or, when using the VM/domain configuration:

```bash
ftp tessaadi.42.fr
```

The FTP control connection uses port:

```text
21
```

Passive FTP requires an additional passive port range configured in the FTP server and exposed by Docker.

For example:

```text
21000-21010
```

To upload a file:

```bash
echo "Hello from FTP" > test.txt
```

Then inside the FTP client:

```text
put test.txt
```

Verify the file:

```text
ls
```

The uploaded file should become visible in the WordPress volume.

---

# 24. Static Website Bonus Service

The static website is implemented as an additional service in its own container.

It must not use PHP.

The static service can contain:

* HTML
* CSS
* JavaScript
* Images
* Other static assets

The service is connected to the same Docker network as NGINX.

NGINX can route requests to the static website according to the project's NGINX configuration.

The static service has its own:

```text
Dockerfile
```

and runs in its own container.

---

# 25. Checking Service Status

List all containers:

```bash
docker ps
```

Check Compose services:

```bash
docker compose ps
```

Check logs:

```bash
docker compose logs
```

Check an individual service:

```bash
docker compose logs nginx
docker compose logs wordpress
docker compose logs mariadb
docker compose logs redis
docker compose logs ftp
docker compose logs static
```

Follow logs in real time:

```bash
docker compose logs -f
```

---

# 26. Checking Connectivity

Check the Docker network:

```bash
docker network inspect inception
```

Check DNS resolution from WordPress:

```bash
docker exec wordpress getent hosts mariadb
```

Check Redis resolution:

```bash
docker exec wordpress getent hosts redis
```

Check FTP resolution if needed:

```bash
docker exec wordpress getent hosts ftp
```

The service names are resolved through Docker's internal DNS.

---

# 27. Checking MariaDB

Enter the MariaDB container:

```bash
docker exec -it mariadb sh
```

Depending on the installed client and configuration:

```bash
mariadb -u root -p
```

List databases:

```sql
SHOW DATABASES;
```

Select the WordPress database:

```sql
USE wordpress;
```

List users:

```sql
SELECT User, Host FROM mysql.user;
```

The WordPress database must contain the required database users, including the database administrator account.

---

# 28. Checking WordPress

Check that WordPress is running:

```bash
docker compose ps wordpress
```

Check PHP-FPM:

```bash
docker exec wordpress ps
```

Check the WordPress files:

```bash
docker exec wordpress ls -la /var/www/html
```

Check the WordPress configuration:

```bash
docker exec wordpress ls -la /var/www/html/wp-config.php
```

The WordPress configuration must contain the correct database hostname.

The database hostname should normally be the Compose service name:

```text
mariadb
```

not:

```text
localhost
```

because MariaDB runs in a different container.

---

# 29. Rebuilding a Service

When modifying a Dockerfile or service configuration, rebuild the relevant image.

For example:

```bash
docker compose build wordpress
```

Then recreate the service:

```bash
docker compose up -d wordpress
```

For all services:

```bash
docker compose up -d --build
```

If configuration changes are not reflected, recreate the containers:

```bash
docker compose down
docker compose up -d --build
```

Persistent named volumes should remain intact unless explicitly removed.

---

# 30. Full Reset

When a complete reset is intentionally required:

```bash
docker compose down -v
```

This removes the Compose containers and associated volumes.

Then rebuild:

```bash
docker compose up -d --build
```

**Warning:** removing volumes can delete the persistent MariaDB database and WordPress files.

Before using destructive commands, verify which volumes are attached:

```bash
docker volume ls
```

and:

```bash
docker volume inspect <volume_name>
```

---

# 31. Cleaning Docker Resources

List images:

```bash
docker images
```

List containers:

```bash
docker ps -a
```

List volumes:

```bash
docker volume ls
```

List networks:

```bash
docker network ls
```

Unused resources can be inspected before removal.

Avoid broad destructive commands such as:

```bash
docker system prune -a --volumes
```

unless a complete Docker cleanup is intentionally required, because this can remove unrelated resources and persistent data.

---

# 32. Data Persistence

The project uses two separate named Docker volumes.

### MariaDB volume

Contains:

```text
/var/lib/mysql
```

Purpose:

```text
Persistent WordPress database
```

### WordPress volume

Contains:

```text
/var/www/html
```

Purpose:

```text
Persistent WordPress website files
```

The host-side persistent storage is located under:

```text
/home/tessaadi/data
```

The important distinction is that these are **Docker named volumes**, not ordinary bind mounts configured directly from the project source directory.

---

# 33. Configuration vs Persistent Data

Project configuration is stored in the Git repository:

```text
srcs/docker-compose.yml
srcs/.env
srcs/requirements/
Makefile
```

Sensitive credentials are stored locally:

```text
secrets/
```

Persistent application data is stored through Docker volumes:

```text
/home/tessaadi/data/
```

This separates:

```text
Configuration
    |
    +---- Docker Compose
    +---- Dockerfiles
    +---- Environment variables

Secrets
    |
    +---- Docker secrets

Persistent data
    |
    +---- Named Docker volumes
```

---

# 34. Development Workflow

A typical development workflow is:

### Step 1 — Enter the project

```bash
cd ~/inception
```

### Step 2 — Check configuration

```bash
cat srcs/.env
```

Do not display or commit secret files publicly.

### Step 3 — Build

```bash
make
```

or:

```bash
docker compose -f srcs/docker-compose.yml build
```

### Step 4 — Start

```bash
docker compose -f srcs/docker-compose.yml up -d
```

### Step 5 — Check services

```bash
docker compose -f srcs/docker-compose.yml ps
```

### Step 6 — Check logs

```bash
docker compose -f srcs/docker-compose.yml logs -f
```

### Step 7 — Test the website

```bash
curl -vk https://tessaadi.42.fr
```

### Step 8 — Stop

```bash
docker compose -f srcs/docker-compose.yml down
```

---

# 35. Troubleshooting

## NGINX is not starting

Check:

```bash
docker compose logs nginx
```

Validate the NGINX configuration:

```bash
docker exec nginx nginx -t
```

Check whether port 443 is already in use:

```bash
ss -lntp | grep :443
```

---

## WordPress cannot connect to MariaDB

Check that both containers are running:

```bash
docker compose ps
```

Check Docker DNS:

```bash
docker exec wordpress getent hosts mariadb
```

Check MariaDB logs:

```bash
docker compose logs mariadb
```

Check WordPress logs:

```bash
docker compose logs wordpress
```

Make sure WordPress uses:

```text
mariadb
```

as the database host.

---

## Redis cannot be reached

Check Redis:

```bash
docker compose ps redis
```

Check logs:

```bash
docker compose logs redis
```

Test DNS:

```bash
docker exec wordpress getent hosts redis
```

Test Redis directly:

```bash
docker exec redis redis-cli ping
```

Expected response:

```text
PONG
```

---

## FTP login fails

Check FTP logs:

```bash
docker compose logs ftp
```

Check the secret:

```bash
docker exec ftp ls -l /run/secrets/
```

Verify that:

```text
ftp_password
```

exists.

Check the FTP user:

```bash
docker exec ftp id ftpuser
```

Check the user's home directory:

```bash
docker exec ftp getent passwd ftpuser
```

The FTP service should have access to:

```text
/var/www/html
```

---

## FTP passive mode fails

Check the configured passive port range.

For example:

```text
21000-21010
```

Check that these ports are exposed by Docker and allowed by the environment.

Inspect the container ports:

```bash
docker ps
```

---

## WordPress files disappear

Check the WordPress volume:

```bash
docker volume ls
```

Inspect it:

```bash
docker volume inspect wordpress_data
```

Check whether the volume is mounted:

```bash
docker inspect wordpress
```

Do not use:

```bash
docker compose down -v
```

unless deleting persistent data is intentional.

---

# 36. Docker PID 1 and Container Processes

Each container should run its actual service as its main process.

The project must not use artificial infinite loops such as:

```bash
tail -f
```

```bash
sleep infinity
```

```bash
while true
do
    ...
done
```

These techniques are prohibited by the Inception subject.

The container should remain alive because its actual daemon/service is running.

For example:

```text
NGINX container
    |
    +---- nginx foreground process

MariaDB container
    |
    +---- MariaDB foreground process

WordPress container
    |
    +---- PHP-FPM foreground process
```

Running the service in the foreground also allows Docker to correctly monitor the main process.

---

# 37. Restart Policy

The services must restart after a crash.

The Compose configuration therefore uses a restart policy such as:

```yaml
restart: always
```

Check the configured restart policy:

```bash
docker inspect <container_name>
```

This is different from manually running a command that keeps the container alive.

The service itself remains the main process.

---

# 38. Security Considerations

The project follows several security principles:

* Do not hard-code passwords in Dockerfiles.
* Do not commit passwords to Git.
* Use Docker secrets for confidential values.
* Keep `.env` for non-secret configuration.
* Use HTTPS through NGINX.
* Restrict TLS to the required protocol versions.
* Avoid unnecessary exposed ports.
* Use a dedicated Docker network.
* Do not use host networking.
* Do not use deprecated Docker links.
* Keep persistent data in Docker named volumes.
* Do not expose the MariaDB service directly to the host unless specifically required.
* Do not expose internal services unnecessarily.

---

# 39. Useful Docker Commands

### Containers

```bash
docker ps
docker ps -a
docker start <container>
docker stop <container>
docker restart <container>
docker rm <container>
```

### Images

```bash
docker images
docker image inspect <image>
docker image rm <image>
```

### Volumes

```bash
docker volume ls
docker volume inspect <volume>
```

### Networks

```bash
docker network ls
docker network inspect <network>
```

### Logs

```bash
docker logs <container>
docker logs -f <container>
```

### Execute commands

```bash
docker exec -it <container> sh
```

---

# 40. Useful Docker Compose Commands

From the directory containing `docker-compose.yml`:

```bash
docker compose up -d
docker compose up -d --build
docker compose down
docker compose ps
docker compose logs
docker compose logs -f
docker compose build
docker compose restart
```

For one service:

```bash
docker compose restart nginx
```

or:

```bash
docker compose build nginx
docker compose up -d nginx
```

---

# 41. Validation Checklist

Before submitting the project, verify:

### Virtual Machine

* [ ] Project runs inside the required Virtual Machine.
* [ ] Docker is installed and working.
* [ ] Docker Compose is available.

### Mandatory services

* [ ] NGINX has its own container.
* [ ] WordPress + PHP-FPM has its own container.
* [ ] MariaDB has its own container.
* [ ] Each service has its own Dockerfile.
* [ ] Images are built from the permitted Debian/Alpine base.
* [ ] No prohibited ready-made application images are used.
* [ ] `latest` is not used.

### NGINX

* [ ] HTTPS works.
* [ ] Port 443 is exposed.
* [ ] TLSv1.2/1.3 is configured.
* [ ] NGINX is the main HTTPS entrypoint.

### WordPress

* [ ] WordPress is installed.
* [ ] PHP-FPM is running.
* [ ] NGINX communicates with PHP-FPM.
* [ ] WordPress connects to MariaDB.

### MariaDB

* [ ] Database is created.
* [ ] Required users exist.
* [ ] Administrator username does not contain `admin` or `administrator`.
* [ ] Database data persists.

### Volumes

* [ ] WordPress uses a named Docker volume.
* [ ] MariaDB uses a named Docker volume.
* [ ] Bind mounts are not used for the two mandatory persistent volumes.
* [ ] Persistent data is stored under `/home/tessaadi/data`.

### Network

* [ ] A custom Docker network is used.
* [ ] Services communicate through the Docker network.
* [ ] Host networking is not used.
* [ ] Docker links are not used.

### Security

* [ ] Passwords are not in Dockerfiles.
* [ ] Credentials are not committed to Git.
* [ ] `.env` is used for environment configuration.
* [ ] Docker secrets are used for confidential values.
* [ ] `secrets/` is ignored by Git.

### Container processes

* [ ] No `tail -f` hack is used.
* [ ] No `sleep infinity` is used.
* [ ] No infinite loop is used to keep containers alive.
* [ ] Actual services run as the main container process.
* [ ] Containers restart after crashes.

### Documentation

* [ ] `README.md` exists.
* [ ] `USER_DOC.md` exists.
* [ ] `DEV_DOC.md` exists.
* [ ] Documentation is written in English.
* [ ] AI usage is documented in the README.

### Bonus

* [ ] Redis has its own Dockerfile/container.
* [ ] Redis is connected to WordPress.
* [ ] FTP has its own Dockerfile/container.
* [ ] FTP accesses the WordPress volume.
* [ ] Static website has its own Dockerfile/container.
* [ ] Static website does not use PHP.

---

# 42. Final Development Architecture

The resulting infrastructure can be represented as:

```text
                         INTERNET / HOST
                              |
                              |
                         HTTPS :443
                              |
                              v
                       +-------------+
                       |    NGINX    |
                       | TLS 1.2/1.3 |
                       +------+------+
                              |
                 +------------+------------+
                 |                         |
                 v                         v
        +----------------+        +----------------+
        |   WordPress    |        | Static Website |
        |   PHP-FPM      |        |    Service     |
        +-------+--------+        +----------------+
                |
          +-----+-----+
          |           |
          v           v
   +-------------+  +-------------+
   |   MariaDB   |  |    Redis    |
   +------+------+  +-------------+
          |
          v
   +----------------+
   | MariaDB Volume |
   +----------------+

                WordPress files
                       |
                       v
              +----------------+
              | WordPress      |
              | Named Volume   |
              +--------+-------+
                       ^
                       |
                +------+------+
                |     FTP     |
                +-------------+
```

All services communicate through the custom Docker network.

Persistent application data is stored through Docker named volumes, while configuration and secrets are managed separately.

The infrastructure is designed so that containers can be recreated without losing persistent WordPress or MariaDB data.
