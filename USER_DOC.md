# Inception — User Documentation

## 1. Overview

This project provides a containerized WordPress infrastructure running inside a Virtual Machine.

The infrastructure provides the following services:

* **NGINX** — secure HTTPS entry point.
* **WordPress** — website and administration interface.
* **MariaDB** — database used by WordPress.
* **Redis** — object cache for WordPress.
* **FTP** — access to WordPress website files.
* **Static Website** — additional static web content.

The services communicate through a private Docker network.

The main website is accessed through:

```text
https://tessaadi.42.fr
```

---

# 2. Services

## NGINX

NGINX is the entry point for the web infrastructure.

It handles HTTPS connections and forwards requests to the appropriate internal service.

The main HTTPS port is:

```text
443
```

Users normally do not need to connect directly to WordPress, PHP-FPM, MariaDB, or Redis.

---

## WordPress

WordPress is the main content management system.

The public website is available at:

```text
https://tessaadi.42.fr
```

The WordPress administration panel is available at:

```text
https://tessaadi.42.fr/wp-admin/
```

From the administration panel, an administrator can:

* Create and edit pages.
* Create and edit posts.
* Manage users.
* Manage themes.
* Manage plugins.
* Configure WordPress settings.

---

## MariaDB

MariaDB stores WordPress data such as:

* Users.
* Posts.
* Pages.
* Comments.
* WordPress settings.
* Plugin data.
* Theme data.

MariaDB is an internal service and should not normally be accessed directly by an end user.

The database data is stored persistently so that it survives container restarts and recreation.

---

## Redis

Redis provides object caching for WordPress.

It is an internal service and normally does not need to be accessed directly by the user.

Its purpose is to reduce repeated database operations and improve WordPress performance.

---

## FTP

The FTP service allows an administrator to manage files stored in the WordPress website volume.

The FTP server can be accessed through:

```text
FTP server: tessaadi.42.fr
Port: 21
```

For example, using the Linux FTP client:

```bash
ftp tessaadi.42.fr
```

After authentication, files can be uploaded with:

```ftp
put file.txt
```

Files uploaded through FTP are stored in the shared WordPress website storage.

---

## Static Website

The project also provides a static website as a bonus service.

The static website is composed of static files such as:

* HTML
* CSS
* JavaScript

It does not use PHP.

Its exact URL depends on the NGINX routing configuration.

---

# 3. Starting the Project

The project should be started from the root of the repository inside the Virtual Machine.

Run:

```bash
make
```

The Makefile builds the required Docker images and starts the infrastructure.

After startup, check the running services:

```bash
docker ps
```

You should see the project's containers running.

You can also use:

```bash
docker compose -f srcs/docker-compose.yml ps
```

---

# 4. Accessing the Website

Open a web browser and visit:

```text
https://tessaadi.42.fr
```

Because the project uses HTTPS, the browser may display a warning if the TLS certificate is self-signed or not trusted by the local system.

This is expected in a local development environment.

---

# 5. Accessing the WordPress Administration Panel

The WordPress administration interface is available at:

```text
https://tessaadi.42.fr/wp-admin/
```

Log in using the WordPress administrator credentials configured for the project.

The administrator account is created during the initial WordPress setup.

---

# 6. Stopping the Project

To stop the infrastructure:

```bash
make down
```

Alternatively:

```bash
docker compose -f srcs/docker-compose.yml down
```

Stopping the containers does **not** remove the persistent database and WordPress data volumes.

---

# 7. Restarting the Project

After stopping the project, start it again with:

```bash
make
```

or, depending on the Makefile:

```bash
make up
```

The persistent data will be reused.

---

# 8. Checking That the Services Are Running

## Check containers

Run:

```bash
docker ps
```

All required containers should have a status similar to:

```text
Up ...
```

For a more detailed Compose view:

```bash
docker compose -f srcs/docker-compose.yml ps
```

---

## Check NGINX

Check the NGINX logs:

```bash
docker compose -f srcs/docker-compose.yml logs nginx
```

The website should respond through:

```text
https://tessaadi.42.fr
```

---

## Check WordPress

Check the WordPress container:

```bash
docker compose -f srcs/docker-compose.yml logs wordpress
```

The WordPress service should remain running without continuous errors.

---

## Check MariaDB

Check the database logs:

```bash
docker compose -f srcs/docker-compose.yml logs mariadb
```

MariaDB should be running before WordPress attempts to use the database.

---

## Check Redis

Check Redis logs:

```bash
docker compose -f srcs/docker-compose.yml logs redis
```

Redis should be running and available to WordPress through the Docker network.

---

## Check FTP

Check the FTP logs:

```bash
docker compose -f srcs/docker-compose.yml logs ftp
```

You can also test the FTP connection:

```bash
ftp tessaadi.42.fr
```

---

# 9. Viewing Service Logs

To view all service logs:

```bash
docker compose -f srcs/docker-compose.yml logs
```

To continuously follow the logs:

```bash
docker compose -f srcs/docker-compose.yml logs -f
```

To follow one service:

```bash
docker compose -f srcs/docker-compose.yml logs -f nginx
```

Replace `nginx` with:

```text
wordpress
mariadb
redis
ftp
static
```

when necessary.

---

# 10. Credentials

Sensitive credentials are stored separately from the public project configuration.

Credentials may include:

* WordPress administrator credentials.
* WordPress database credentials.
* MariaDB root credentials.
* FTP credentials.

Sensitive files are stored locally in the project's `secrets/` directory.

Example:

```text
secrets/
├── db_password.txt
├── db_root_password.txt
└── ftp_password.txt
```

The exact files depend on the services enabled in the project.

### Important

Do not:

* Commit passwords to Git.
* Put passwords directly into Dockerfiles.
* Share secret files publicly.
* Upload secret files to GitHub or another public repository.

The `secrets/` directory should be excluded through `.gitignore`.

---

# 11. WordPress Data

The WordPress website files are stored in a persistent Docker named volume.

The volume contains files such as:

```text
wp-admin/
wp-content/
wp-includes/
wp-config.php
```

The website files are shared with the FTP service.

Therefore, modifying a website file through FTP modifies the file used by WordPress.

---

# 12. Database Data

MariaDB stores its data in a persistent Docker named volume.

The database volume contains the WordPress database files.

The data persists when containers are stopped or recreated.

---

# 13. Important Data Warning

Do not manually delete the Docker volumes unless you intentionally want to delete the stored data.

To see the available volumes:

```bash
docker volume ls
```

Removing a database volume can permanently delete the WordPress database.

Removing the WordPress volume can permanently delete the website files.

Always make a backup before deleting persistent data.

---

# 14. Basic Troubleshooting

## Website does not load

First check the containers:

```bash
docker ps
```

Then check NGINX:

```bash
docker compose -f srcs/docker-compose.yml logs nginx
```

Check WordPress:

```bash
docker compose -f srcs/docker-compose.yml logs wordpress
```

Check whether the domain resolves correctly:

```bash
getent hosts tessaadi.42.fr
```

---

## WordPress shows a database connection error

Check MariaDB:

```bash
docker compose -f srcs/docker-compose.yml logs mariadb
```

Then check WordPress:

```bash
docker compose -f srcs/docker-compose.yml logs wordpress
```

The database service must be running and reachable by the WordPress container.

---

## FTP login fails

Check the FTP container:

```bash
docker compose -f srcs/docker-compose.yml logs ftp
```

Then verify:

* FTP username.
* FTP password.
* Port `21`.
* FTP container status.
* FTP configuration.
* File permissions.

Test the connection:

```bash
ftp tessaadi.42.fr
```

---

## A container has stopped

Check:

```bash
docker ps -a
```

Then inspect its logs:

```bash
docker compose -f srcs/docker-compose.yml logs <service>
```

For example:

```bash
docker compose -f srcs/docker-compose.yml logs nginx
```

---

# 15. Normal Administration Workflow

A typical administrator workflow is:

```text
1. Start the infrastructure
        |
        v
   make / make up
        |
        v
2. Check containers
        |
        v
   docker ps
        |
        v
3. Open WordPress
        |
        v
   https://tessaadi.42.fr
        |
        v
4. Manage the website
        |
        +---- WordPress Admin
        |
        +---- FTP
        |
        v
5. Stop when necessary
        |
        v
   make down
```

Persistent WordPress and database data remain stored in their Docker volumes.

---

# 16. Security Recommendations

Administrators should:

* Use strong passwords.
* Keep secret files private.
* Never commit credentials to Git.
* Use HTTPS when accessing WordPress.
* Avoid deleting persistent volumes unless necessary.
* Regularly back up important WordPress and database data.
* Keep the Docker host and packages updated.
* Avoid exposing internal services unnecessarily.

The database and Redis services are intended to remain internal to the Docker network.

---

# 17. Quick Reference

| Task                   | Command                                                    |
| ---------------------- | ---------------------------------------------------------- |
| Start project          | `make`                                                     |
| Stop project           | `make down`                                                |
| Check containers       | `docker ps`                                                |
| Check Compose services | `docker compose -f srcs/docker-compose.yml ps`             |
| View all logs          | `docker compose -f srcs/docker-compose.yml logs`           |
| Follow logs            | `docker compose -f srcs/docker-compose.yml logs -f`        |
| NGINX logs             | `docker compose -f srcs/docker-compose.yml logs nginx`     |
| WordPress logs         | `docker compose -f srcs/docker-compose.yml logs wordpress` |
| MariaDB logs           | `docker compose -f srcs/docker-compose.yml logs mariadb`   |
| Redis logs             | `docker compose -f srcs/docker-compose.yml logs redis`     |
| FTP logs               | `docker compose -f srcs/docker-compose.yml logs ftp`       |
| List volumes           | `docker volume ls`                                         |
| List containers        | `docker ps -a`                                             |
| Website                | `https://tessaadi.42.fr`                                   |
| WordPress Admin        | `https://tessaadi.42.fr/wp-admin/`                         |
| FTP                    | `ftp tessaadi.42.fr`                                       |

---

# 18. Service Summary

| Service        | Purpose                       | User Access                  |
| -------------- | ----------------------------- | ---------------------------- |
| NGINX          | HTTPS entry point and routing | HTTPS / `443`                |
| WordPress      | Website and CMS               | Web browser                  |
| MariaDB        | WordPress database            | Internal                     |
| Redis          | WordPress object cache        | Internal                     |
| FTP            | WordPress file management     | FTP / `21`                   |
| Static Website | Static web content            | Through configured web route |

The infrastructure is designed so that the user interacts primarily with the web interface, while internal services such as MariaDB and Redis communicate through the private Docker network.
