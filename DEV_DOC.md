# 🛠️ Inception - Developer Documentation

This guide provides technical information for developers who want to set up, build, modify, or extend the Inception project.

---

## Table of Contents

1. [Environment Setup](#1-environment-setup)
2. [Building and Launching](#2-building-and-launching)
3. [Container and Volume Management](#3-container-and-volume-management)
4. [Data Storage and Persistence](#4-data-storage-and-persistence)

---

## 1. Environment Setup

### 1.1 Prerequisites

#### Required Software

| Software | Minimum Version | Check Command |
|----------|-----------------|---------------|
| Docker Engine | 20.10+ | docs.docker.com/engine/install |
| Docker Compose | v2.0+ | `docker-compose-plugin` |
| GNU Make | 4.0+ | `sudo apt install make` |
| Git | 2.0+ | `sudo apt install git` |

Verify installations:
```
docker --version
docker compose version
make --version
```

#### Optional Tools

| Tool | Purpose | Installation |
|------|---------|--------------|
| `hostsed` | Manage `/etc/hosts` entries | `sudo apt install hostsed` or build from source |
| `curl` | Test HTTP endpoints | Usually pre-installed |
| `openssl` | Verify SSL certificates | Usually pre-installed |

#### System Requirements

- **OS:** Linux (Debian/Ubuntu recommended) or macOS
- **RAM:** Minimum 4GB (8GB recommended for all bonus services)
- **Disk:** Minimum 5GB free space
- **Network:** Ports 443, 600, 3001, 8080, 8081, 9443, 21, 20, 6379 available

#### Project Structure

```
inception/
├── Makefile                    # Build automation
├── README.md                   # Project overview
├── USER_DOC.md                 # User documentation
├── DEV_DOC.md                  # This file
├── EVALUATION_GUIDE.md         # Evaluation testing guide
└── srcs/
    ├── .env                    # Environment variables (secrets)
    ├── docker-compose.yml      # Service definitions
    └── requirements/
        ├── mariadb/
        ├── nginx/
        ├── wordpress/
        └── bonus/
            ├── adminer/
            ├── cadvisor/
            ├── cron/
            ├── ftp/
            ├── kuma/
            ├── portainer/
            ├── redis/
            └── website/
```

### 1.2 Configuration Files

#### Environment Variables

This file contains all secrets and configuration values. Never commit real credentials to version control.

Location: `srcs/.env`

```bash
# Create from example (if available)
cp srcs/.env.example srcs/.env

# Or create manually
nano srcs/.env
```

**Required Variables:**

```bash
# ─────────────── DATABASE ───────────────
DB_NAME=thedatabase          # MariaDB database name
DB_USER=theuser              # MariaDB user
DB_PASSWORD=abc              # MariaDB user password
DB_PASS_ROOT=123             # MariaDB root password
DB_HOST=mariadb              # Database hostname (container name)

# ─────────────── WORDPRESS ───────────────
WP_URL=mmiguelo.42.fr        # WordPress site URL (without https://)
WP_TITLE=Inception           # Site title
WP_ADMIN_USER=theroot        # Admin username (must NOT contain 'admin')
WP_ADMIN_PASSWORD=123        # Admin password
WP_ADMIN_EMAIL=theroot@123.com
WP_USER=theuser              # Regular user
WP_PASSWORD=abc              # Regular user password
WP_EMAIL=theuser@123.com
WP_ROLE=editor               # Regular user role
WP_FULL_URL=https://mmiguelo.42.fr

# ─────────────── SSL CERTIFICATE ───────────────
CERT_FOLDER=/etc/nginx/certs/
CERTIFICATE=/etc/nginx/certs/certificate.crt
KEY=/etc/nginx/certs/certificate.key
COUNTRY=BR
STATE=BA
LOCALITY=Salvador
ORGANIZATION=42
UNIT=42
COMMON_NAME=mmiguelo.42.fr

# ─────────────── BONUS: FTP ───────────────
FTP_USER=ftpuser
FTP_PASSWORD=ftpuser123
```

#### Docker Compose Configuration

Location: `srcs/docker-compose.yml`

Key sections:

```yaml
services:
  # Mandatory services (no profile)
  mariadb:
  wordpress:
  nginx:
  
  # Bonus services (profile: bonus)
  adminer:
    profiles:
      - bonus
  # ... other bonus services

networks:
  all:
    driver: bridge

volumes:
  database:
    driver_opts:
      device: /home/${USER}/data/database
      type: none
      o: bind
```

#### Service-Specific Configurations

| Service | Config Location | Purpose |
|---------|-----------------|---------|
| MariaDB | `requirements/mariadb/conf/50-server.cnf` | Database server settings |
| NGINX | `requirements/nginx/conf/nginx.conf` | Main NGINX config |
| NGINX | `requirements/nginx/conf/server.conf` | Virtual host config |
| WordPress | `requirements/wordpress/conf/wp-config.php` | WordPress configuration |
| WordPress | `requirements/wordpress/conf/www.conf` | PHP-FPM pool config |
| Redis | `requirements/bonus/redis/conf/redis.conf` | Cache settings |
| FTP | `requirements/bonus/ftp/conf/vsftpd.conf` | FTP server settings |
| Website | `requirements/bonus/website/conf/website.conf` | Static site config |

### 1.4 Host Configuration

Add the domain to `/etc/hosts`:

```bash
# Using hostsed (recommended)
sudo hostsed add 127.0.0.1 mmiguelo.42.fr

# Or manually
echo "127.0.0.1 mmiguelo.42.fr" | sudo tee -a /etc/hosts
```

Verify:
```bash
grep mmiguelo /etc/hosts
# Expected: 127.0.0.1 mmiguelo.42.fr
```

### 1.5 Directory Setup

Create data directories:

```bash
mkdir -p ~/data/database
mkdir -p ~/data/wordpress_files
mkdir -p ~/data/portainer_data
mkdir -p ~/data/backups
```

> **Note:** The Makefile's `create_dir` target handles this automatically.

---

## 2. Building and Launching

### 2.1 Makefile Targets

#### Core Targets

| Target | Command | Description |
|--------|---------|-------------|
| `all` | `make` | Build and start mandatory services |
| `up` | `make up` | Same as `all` |
| `down` | `make down` | Stop and remove containers |
| `bonus` | `make bonus` | Build and start all services (mandatory + bonus) |
| `bonus-down` | `make bonus-down` | Stop all services |

#### Maintenance Targets

| Target | Command | Description |
|--------|---------|-------------|
| `status` | `make status` | Display containers, images, volumes, networks |
| `clean` | `make clean` | Stop containers and remove volumes |
| `fclean` | `make fclean` | Full cleanup with backup |
| `prepare` | `make prepare` | Remove ALL Docker resources (nuclear option) |
| `re` | `make re` | `fclean` + `all` |
| `backup` | `make backup` | Create tarball of data directory |

#### Makefile Variables

```makefile
NAME = inception                    # Project name (used as compose project)
SRCS = ./srcs                       # Source directory
COMPOSE = $(SRCS)/docker-compose.yml
HOST_URL = mmiguelo.42.fr           # Domain name
```

### 2.2 Build Process

#### Standard Build (Mandatory Only)

```bash
make
```

This executes:
1. `create_dir` - Creates data directories
2. `hostsed add` - Adds domain to `/etc/hosts`
3. `docker compose up --build -d` - Builds images and starts containers

#### Full Build (With Bonus)

```bash
make bonus
```

This executes the same steps but with `--profile bonus` flag.

### 2.3 Docker Compose Commands

#### Direct Docker Compose Usage

```bash
# Navigate to project root
cd /path/to/inception

# Build without starting
docker compose -f srcs/docker-compose.yml build

# Start in foreground (see logs)
docker compose -f srcs/docker-compose.yml up

# Start in background
docker compose -f srcs/docker-compose.yml up -d

# Start with bonus services
docker compose -f srcs/docker-compose.yml --profile bonus up -d

# Rebuild specific service
docker compose -f srcs/docker-compose.yml build nginx

# View logs
docker compose -f srcs/docker-compose.yml logs -f

# Stop services
docker compose -f srcs/docker-compose.yml down

# Stop and remove volumes
docker compose -f srcs/docker-compose.yml down -v
```

### 2.4 Build Verification

After building, verify everything is running:

```bash
# Check containers
docker ps

# Expected output (mandatory):
# CONTAINER ID   IMAGE                STATUS         NAMES
# xxxxxxxxxxxx   inception-nginx      Up X minutes   nginx
# xxxxxxxxxxxx   inception-wordpress  Up X minutes   wordpress
# xxxxxxxxxxxx   inception-mariadb    Up X minutes   mariadb

# Test website
curl -k https://mmiguelo.42.fr

# Check logs for errors
docker logs nginx
docker logs wordpress
docker logs mariadb
```

---

## 3. Container and Volume Management

### 3.1 Container Commands

#### Listing Containers

```bash
# All running containers
docker ps

# All containers (including stopped)
docker ps -a

# Filter by project
docker ps --filter "name=inception"
```

#### Container Lifecycle

```bash
# Stop a container
docker stop <container_name>

# Start a stopped container
docker start <container_name>

# Restart a container
docker restart <container_name>

# Remove a container (must be stopped first)
docker rm <container_name>

# Force remove running container
docker rm -f <container_name>
```

#### Container Inspection

```bash
# View container details
docker inspect <container_name>

# View container logs
docker logs <container_name>

# Follow logs in real-time
docker logs -f <container_name>

# Last 100 lines
docker logs --tail 100 <container_name>

# View resource usage
docker stats
```

#### Executing Commands in Containers

```bash
# Open shell in container
docker exec -it <container_name> bash

# Run single command
docker exec <container_name> ls -la /var/www/

# Examples:
docker exec -it mariadb mariadb -u root -p123
docker exec -it wordpress wp --info
docker exec redis redis-cli ping
```

### 3.2 Image Commands

```bash
# List images
docker images

# List project images
docker images | grep inception

# Remove image
docker rmi <image_name>

# Remove all unused images
docker image prune

# Rebuild image without cache
docker compose -f srcs/docker-compose.yml build --no-cache <service>
```

### 3.3 Volume Commands

#### Listing Volumes

```bash
# List all volumes
docker volume ls

# List project volumes
docker volume ls | grep inception

# Expected:
# local     inception_database
# local     inception_wordpress_files
# local     inception_portainer_data   (bonus)
# local     inception_backups          (bonus)
```

#### Volume Inspection

```bash
# View volume details
docker volume inspect inception_database

# Key fields:
# - Mountpoint: Where data is stored on host
# - Options.device: Bind mount path
```

#### Volume Management

```bash
# Remove a volume (data will be lost!)
docker volume rm inception_database

# Remove all unused volumes
docker volume prune

# Remove all project volumes
docker volume rm $(docker volume ls -q | grep inception)
```

### 3.4 Network Commands

```bash
# List networks
docker network ls

# View network details
docker network inspect inception_all

# See connected containers
docker network inspect inception_all --format '{{range .Containers}}{{.Name}} {{end}}'
```

### 3.5 Cleanup Commands

#### Selective Cleanup

```bash
# Stop all project containers
docker compose -f srcs/docker-compose.yml down

# Remove project containers, networks, volumes
docker compose -f srcs/docker-compose.yml down -v

# Remove project images
docker rmi $(docker images -q | grep inception)
```

#### Full System Cleanup

```bash
# Using Makefile
make prepare

# Or manually (WARNING: affects ALL Docker resources)
docker stop $(docker ps -qa)
docker rm $(docker ps -qa)
docker rmi -f $(docker images -qa)
docker volume rm $(docker volume ls -q)
docker network rm $(docker network ls -q) 2>/dev/null
```

---

## 4. Data Storage and Persistence

### 4.1 Data Directory Structure

All persistent data is stored in `~/data/`:

```
~/data/
├── database/           # MariaDB data files
│   ├── mysql/
│   ├── performance_schema/
│   └── <database_name>/
├── wordpress_files/    # WordPress installation
│   ├── wp-admin/
│   ├── wp-content/
│   │   ├── themes/
│   │   ├── plugins/
│   │   └── uploads/
│   ├── wp-includes/
│   └── wp-config.php
├── portainer_data/     # Portainer configuration (bonus)
└── backups/            # Cron backup storage (bonus)
    ├── db_backup_YYYYMMDD_HHMMSS.sql
    └── files_backup_YYYYMMDD_HHMMSS.tar.gz
```

### 4.2 Volume Mapping

| Volume Name | Container Path | Host Path |
|-------------|----------------|-----------|
| `database` | `/var/lib/mysql/` | `~/data/database/` |
| `wordpress_files` | `/var/www/inception/` | `~/data/wordpress_files/` |
| `portainer_data` | `/data` | `~/data/portainer_data/` |
| `backups` | `/backups` | `~/data/backups/` |

### 4.3 How Persistence Works

#### Volume Configuration (docker-compose.yml)

```yaml
volumes:
  database:
    driver: local
    driver_opts:
      device: /home/mmiguelo/data/database
      type: none
      o: bind
```

This creates a **bind mount** that:
1. Maps host directory to container path
2. Data persists even when container is removed
3. Data survives `docker compose down`
4. Data is removed only by `docker compose down -v` or manual deletion

#### Persistence Verification

```bash
# 1. Create test data
docker exec wordpress touch /var/www/inception/test_file.txt

# 2. Stop containers
make down

# 3. Verify file exists on host
ls ~/data/wordpress_files/test_file.txt

# 4. Restart containers
make up

# 5. Verify file still exists in container
docker exec wordpress ls /var/www/inception/test_file.txt
```

### 4.4 Backup and Restore

#### Manual Backup

```bash
# Database backup
docker exec mariadb mariadb-dump -u root -p123 thedatabase > backup.sql

# WordPress files backup
tar -czvf wordpress_backup.tar.gz ~/data/wordpress_files/

# Full data backup
tar -czvf full_backup.tar.gz ~/data/
```

#### Manual Restore

```bash
# Restore database
docker exec -i mariadb mariadb -u root -p123 thedatabase < backup.sql

# Restore WordPress files
tar -xzvf wordpress_backup.tar.gz -C ~/

# Restore full data
tar -xzvf full_backup.tar.gz -C ~/
```

#### Automated Backups (Cron Service)

The cron container automatically creates backups:

- **Schedule:** Daily at 3:00 AM
- **Location:** `~/data/backups/`
- **Files created:**
  - `db_backup_YYYYMMDD_HHMMSS.sql` - Database dump
  - `files_backup_YYYYMMDD_HHMMSS.tar.gz` - WordPress files

**Manual trigger:**
```bash
docker exec cron /usr/local/bin/backup.sh
```

**View backups:**
```bash
ls -la ~/data/backups/
# Or
docker exec cron ls -la /backups/
```

### 4.5 Data Migration

#### Export Data for Migration

```bash
# Stop services
make down

# Create migration archive
tar -czvf inception_migration.tar.gz \
    ~/data/database \
    ~/data/wordpress_files \
    srcs/.env
```

#### Import Data on New System

```bash
# Extract archive
tar -xzvf inception_migration.tar.gz -C ~/

# Update .env if needed (paths, URLs)
nano srcs/.env

# Start services
make up
```

### 4.6 Troubleshooting Data Issues

#### Permission Issues

```bash
# Fix WordPress files permissions
sudo chown -R 33:33 ~/data/wordpress_files/

# Fix database permissions
sudo chown -R 999:999 ~/data/database/
```

#### Corrupted Database

```bash
# Stop MariaDB
docker stop mariadb

# Check database files
sudo ls -la ~/data/database/

# Remove and reinitialize (DATA LOSS)
sudo rm -rf ~/data/database/*
make up
```

#### Volume Not Mounting

```bash
# Check if directory exists
ls -la ~/data/

# Check volume configuration
docker volume inspect inception_database

# Recreate volumes
docker compose -f srcs/docker-compose.yml down -v
make up
```

---

## Quick Reference

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    DEVELOPER QUICK REFERENCE                            │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  SETUP                                                                  │
│  ─────                                                                  │
│  1. Clone repo                                                          │
│  2. Create srcs/.env with credentials                                   │
│  3. Run: make                                                           │
│                                                                         │
│  BUILD COMMANDS                                                         │
│  ──────────────                                                         │
│  make              Build & start mandatory services                     │
│  make bonus        Build & start all services                           │
│  make down         Stop services                                        │
│  make re           Rebuild from scratch                                 │
│                                                                         │
│  DEBUG COMMANDS                                                         │
│  ──────────────                                                         │
│  docker ps                          List containers                     │
│  docker logs <container>            View logs                           │
│  docker exec -it <container> bash   Shell access                        │
│  make status                        Full status overview                │
│                                                                         │
│  DATA LOCATIONS                                                         │
│  ──────────────                                                         │
│  ~/data/database/         MariaDB data                                  │
│  ~/data/wordpress_files/  WordPress installation                        │
│  ~/data/backups/          Automated backups                             │
│  srcs/.env                Credentials & configuration                   │
│                                                                         │
│  KEY FILES                                                              │
│  ─────────                                                              │
│  srcs/docker-compose.yml           Service definitions                  │
│  srcs/requirements/*/Dockerfile    Container builds                     │
│  srcs/requirements/*/conf/         Service configurations               │
│  srcs/requirements/*/tools/        Setup scripts                        │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

---

*For user-facing documentation, see [USER_DOC.md](USER_DOC.md)*

*For project overview and architecture, see [README.md](README.md)*
