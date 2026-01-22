*This project has been created as part of the 42 curriculum by mmiguelo.*

# 🐳 Inception

A Docker-based infrastructure project that sets up a complete web hosting environment with WordPress, MariaDB, and NGINX, plus several bonus services.

---

## 📋 Table of Contents

- [Description](#description)
- [Project Architecture](#project-architecture)
- [Services Overview](#services-overview)
- [Technical Comparisons](#technical-comparisons)
- [Instructions](#instructions)
- [Further Documentation](#further-documentation)
- [Resources](#resources)

---

## Description

**Inception** is a system administration project focused on Docker containerization. The goal is to set up a small infrastructure composed of different services running in dedicated Docker containers, all orchestrated with Docker Compose.

### Main Objectives:
- Build custom Docker images from Debian (no pre-built images from DockerHub)
- Configure a complete LEMP stack (Linux, NGINX, MariaDB, PHP)
- Implement SSL/TLS encryption with self-signed certificates
- Manage persistent data with Docker volumes
- Ensure container isolation with Docker networks

### Infrastructure Diagram (Mandatory):

```
                                    ┌─────────────────────────────────────────────────────────────┐
                                    │                    Docker Network (all)                     │
                                    │                                                             │
┌──────────┐    HTTPS (443)    ┌────┴────┐    FastCGI (9000)    ┌───────────┐    SQL (3306)    ┌──┴───────┐
│  Client  │ ───────────────▶ │  NGINX  │ ──────────────────▶ │ WordPress │ ───────────────▶│ MariaDB  │
│ Browser  │                   │   SSL   │                      │  PHP-FPM  │                  │ Database │
└──────────┘                   └─────────┘                      └───────────┘                  └──────────┘
                                    │                                 │                              │
                                    │                                 │                              │
                               ┌────┴────┐                       ┌────┴────┐                    ┌────┴────┐
                               │ Volume  │                       │ Volume  │                    │ Volume  │
                               │  certs  │                       │  files  │                    │   db    │
                               └─────────┘                       └─────────┘                    └─────────┘
```

### 🌟 Complete Infrastructure Diagram (with Bonus Services):

```
┌─────────────────────────────────────────────────────────────────────────┐
│                              CLIENT                                     │
│                             (Browser)                                   │
└───────────────────────────────────┬─────────────────────────────────────┘
                                    │
        ┌───────────────────────────┼───────────────────────────┐
        │                           │                           │
        ▼                           ▼                           ▼
   ┌─────────┐                 ┌─────────┐                 ┌─────────┐
   │ :443    │                 │ :8081   │                 │ :600    │
   │ HTTPS   │                 │ HTTP    │                 │ HTTP    │
   └────┬────┘                 └────┬────┘                 └────┬────┘
        │                           │                           │
════════╪═══════════════════════════╪═══════════════════════════╪═════════
        │           DOCKER NETWORK (all) - EXPOSED PORTS        │
════════╪═══════════════════════════╪═══════════════════════════╪═════════
        │                           │                           │
        ▼                           ▼                           ▼
  ┌───────────┐               ┌───────────┐               ┌───────────┐
  │   NGINX   │               │  WEBSITE  │               │  ADMINER  │
  │  (SSL)    │               │  (HTML)   │               │ (DB Admin)│
  └─────┬─────┘               └───────────┘               └─────┬─────┘
        │                                                       │
        │ FastCGI :9000                                         │
        ▼                                                       │
  ┌───────────┐                                                 │
  │ WORDPRESS │◄────── Cache :6379 ──────┐                      │
  │ (PHP-FPM) │                          │                      │
  └─────┬─────┘                    ┌─────┴─────┐                │
        │                          │   REDIS   │                │
        │ SQL :3306                │  (Cache)  │                │
        ▼                          └───────────┘                │
  ┌───────────┐                                                 │
  │  MARIADB  │◄────────────────────────────────────────────────┘
  │ (Database)│                     SQL :3306
  └───────────┘

════════════════════════════════════════════════════════════════════════
                    ADDITIONAL EXPOSED PORTS
════════════════════════════════════════════════════════════════════════

   :21/:20 FTP        :8080 cAdvisor      :9443 Portainer     :3001 Kuma
        │                   │                   │                  │
        ▼                   ▼                   ▼                  ▼
  ┌───────────┐       ┌───────────┐       ┌───────────┐      ┌───────────┐
  │    FTP    │       │ CADVISOR  │       │ PORTAINER │      │   KUMA    │
  │ (vsftpd)  │       │(Metrics)  │       │(Docker UI)│      │(Uptime)   │
  └─────┬─────┘       └─────┬─────┘       └─────┬─────┘      └─────┬─────┘
        │                   │                   │                  │
        ▼                   ▼                   ▼                  ▼
   [WP Files]          [Docker Sock]       [Docker Sock]      [HTTP Checks]
   Volume Access       Read Metrics        Manage All         All Services

════════════════════════════════════════════════════════════════════════
                    INTERNAL SERVICE (No exposed port)
════════════════════════════════════════════════════════════════════════

                          ┌───────────┐
                          │   CRON    │
                          │ (Backups) │
                          └─────┬─────┘
                                │
              ┌─────────────────┼─────────────────┐
              ▼                 ▼                 ▼
         [MariaDB]         [WP Files]        [Backups]
         SQL Dump          File Copy          Storage
```

### Port Exposure Summary:

```
┌──────────────────────────────────────────────────────────────────────────┐
│                        EXPOSED TO HOST                                   │
├────────────┬─────────────────────────────────────────────────────────────┤
│  SERVICE   │  PORT     PROTOCOL    PURPOSE                               │
├────────────┼─────────────────────────────────────────────────────────────┤
│  NGINX     │  443      HTTPS       Main WordPress site (SSL)             │
│  Website   │  8081     HTTP        Static HTML site                      │
│  Adminer   │  600      HTTP        Database management UI                │
│  FTP       │  21/20    FTP         File transfer (WordPress files)       │
│  Redis     │  6379     TCP         Cache (optional external access)      │
│  cAdvisor  │  8080     HTTP        Container metrics dashboard           │
│  Portainer │  9443     HTTPS       Docker management UI                  │
│  Kuma      │  3001     HTTP        Uptime monitoring dashboard           │
└────────────┴─────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────┐
│                        INTERNAL ONLY                                     │
├────────────┬─────────────────────────────────────────────────────────────┤
│  SERVICE   │  PORT     PROTOCOL    PURPOSE                               │
├────────────┼─────────────────────────────────────────────────────────────┤
│  WordPress │  9000     FastCGI     PHP processing (NGINX → WordPress)    │
│  MariaDB   │  3306     MySQL       Database (WordPress/Adminer → DB)     │
│  Cron      │  -        -           Scheduled backups (no network)        │
└────────────┴─────────────────────────────────────────────────────────────┘
```

### Data Flow Diagram:

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         REQUEST FLOW                                    │
└─────────────────────────────────────────────────────────────────────────┘

  User Request (HTTPS)
        │
        ▼
  ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
  │    NGINX    │───▶│  WORDPRESS  │───▶│   MARIADB   │
  │   :443      │     │   :9000     │     │   :3306     │
  │   (SSL)     │     │  (PHP-FPM)  │     │  (MySQL)    │
  └─────────────┘     └──────┬──────┘     └─────────────┘
                             │
                             ▼
                      ┌─────────────┐
                      │    REDIS    │
                      │   :6379     │
                      │   (Cache)   │
                      └─────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│                         BACKUP FLOW                                     │
└─────────────────────────────────────────────────────────────────────────┘

  ┌─────────────┐
  │    CRON     │ ─────── Scheduled: Daily 3AM
  │  (Backups)  │
  └──────┬──────┘
         │
         ├────────▶ MariaDB ────▶ SQL Dump ────────┐
         │                                           │
         │                                           ▼
         │                                   [BACKUPS VOLUME]
         │                                           ▲
         │                                           │
         └────────▶ WordPress ──▶ File Copy ───────┘
                     Files

┌─────────────────────────────────────────────────────────────────────────┐
│                       MONITORING FLOW                                   │
└─────────────────────────────────────────────────────────────────────────┘

  ┌─────────────┐                    ┌─────────────────────────────────┐
  │  CADVISOR   │───Docker Socket───▶│  Reads: CPU, Memory, Network,   │
  │   :8080     │                    │         Disk for ALL containers │
  └─────────────┘                    └─────────────────────────────────┘

  ┌─────────────┐                    ┌─────────────────────────────────┐
  │  PORTAINER  │───Docker Socket───▶│  Manages: Start, Stop, Logs,    │
  │   :9443     │                    │           Shell, ALL containers │
  └─────────────┘                    └─────────────────────────────────┘

  ┌─────────────┐                    ┌─────────────────────────────────┐
  │ UPTIME KUMA │───HTTP/TCP Checks─▶│  Monitors: Service availability │
  │   :3001     │                    │            Response times        │
  └─────────────┘                    └─────────────────────────────────┘
```

### Volumes:

```
┌─────────────────────────────────────────────────────────────────────────┐
│  VOLUME NAME       │  MOUNT PATH                    │  USED BY          │
├────────────────────┼────────────────────────────────┼───────────────────┤
│  database          │  /home/mmiguelo/data/database  │  MariaDB          │
│  wordpress_files   │  /home/mmiguelo/data/wordpress │  WordPress, NGINX │
│                    │                                │  FTP, Cron        │
│  portainer_data    │  /home/mmiguelo/data/portainer │  Portainer        │
│  backups           │  /home/mmiguelo/data/backups   │  Cron             │
└────────────────────┴────────────────────────────────┴───────────────────┘
```

---

## Project Architecture

```
inception/
├── Makefile                    # Automation commands
├── README.md                   # Project documentation
└── srcs/
    ├── .env                    # Environment variables (secrets)
    ├── docker-compose.yml      # Service orchestration
    └── requirements/
        ├── mariadb/            # Database service
        │   ├── Dockerfile
        │   ├── conf/
        │   │   └── 50-server.cnf
        │   └── tools/
        │       └── setup.sh
        ├── nginx/              # Web server + SSL
        │   ├── Dockerfile
        │   └── conf/
        │       ├── nginx.conf
        │       └── server.conf
        ├── wordpress/          # PHP-FPM + WordPress
        │   ├── Dockerfile
        │   ├── conf/
        │   │   ├── wp-config.php
        │   │   └── www.conf
        │   └── tools/
        │       └── setup.sh
        └── bonus/              # Bonus services
            ├── adminer/        # Database management UI
            ├── cadvisor/       # Container monitoring
            ├── cron/           # Scheduled backups
            ├── ftp/            # FTP server (vsftpd)
            ├── kuma/           # Uptime monitoring
            ├── portainer/      # Docker management UI
            ├── redis/          # Cache server
            └── website/        # Static website
```

---

## Services Overview

### Mandatory Services

| Service | Description | Port | Image Base |
|---------|-------------|------|------------|
| **NGINX** | Web server with SSL/TLS termination | 443 | debian:bookworm |
| **WordPress** | CMS with PHP-FPM | 9000 (internal) | debian:bookworm |
| **MariaDB** | Relational database | 3306 (internal) | debian:bookworm |

### Bonus Services

| Service | Description | Port | Purpose |
|---------|-------------|------|---------|
| **Adminer** | Lightweight database management | 600 | Manage MariaDB via web UI |
| **Redis** | In-memory cache | 6379 | WordPress object caching |
| **FTP (vsftpd)** | File transfer server | 21, 20 | Manage WordPress files |
| **cAdvisor** | Container metrics | 8080 | Monitor resource usage |
| **Portainer** | Docker management UI | 9443 | Visual container management |
| **Uptime Kuma** | Status monitoring | 3001 | Service health checks |
| **Cron** | Scheduled tasks | - | Automated backups |
| **Static Website** | Custom HTML site | 8081 | Additional web content |

### ⭐ Bonus Services - Detailed Description

#### 🗄️ Adminer (Database Management)
A lightweight, single-file PHP database management tool. Unlike phpMyAdmin, Adminer is contained in one PHP file, making it perfect for Docker deployments.
- **Why useful?** Provides a web interface to browse tables, run SQL queries, import/export data without command-line access.
- **Access:** `http://localhost:600`

#### ⚡ Redis (Object Cache)
An in-memory data structure store used as a cache for WordPress. Stores frequently accessed data in RAM.
- **Why useful?** Dramatically reduces database queries, improving page load times by 2-5x for dynamic content.
- **Integration:** WordPress connects to Redis for object caching (wp_options, transients, sessions).

#### 📁 FTP Server (vsftpd)
A secure FTP server providing file transfer access to WordPress files.
- **Why useful?** Allows uploading themes, plugins, and media files without SSH access. Useful for clients who need file access.
- **Access:** `ftp://localhost:21` (user: `ftpuser`)

#### 📊 cAdvisor (Container Monitoring)
Google's Container Advisor provides real-time monitoring of container resource usage.
- **Why useful?** Visualizes CPU, memory, network, and filesystem usage per container. Essential for identifying performance bottlenecks.
- **Access:** `http://localhost:8080`

#### 🐳 Portainer (Docker Management UI)
A web-based Docker management interface for managing containers, images, volumes, and networks.
- **Why useful?** Provides visual management of the entire Docker environment without command-line knowledge. Great for demonstrations.
- **Access:** `https://localhost:9443`

#### 🔔 Uptime Kuma (Monitoring & Alerts)
A self-hosted monitoring tool that checks if services are online and sends alerts.
- **Why useful?** Monitors all services' health, sends notifications (email, Slack, Discord) when services go down.
- **Access:** `http://localhost:3001`

#### ⏰ Cron (Scheduled Backups)
A container dedicated to running scheduled tasks, specifically automated backups.
- **Why useful?** Automatically backs up the MariaDB database and WordPress files daily at 3 AM. Critical for disaster recovery.
- **Backup location:** `/backups` volume

#### 🌐 Static Website
A separate Nginx container serving a custom static HTML website.
- **Why useful?** Demonstrates the ability to host multiple websites. Can serve as a portfolio, landing page, or status page.
- **Access:** `http://localhost:8081`

---

## Technical Comparisons

### 🖥️ Virtual Machines vs Docker

| Aspect | Virtual Machines | Docker Containers |
|--------|------------------|-------------------|
| **Architecture** | Full OS with hypervisor | Shared kernel, isolated processes |
| **Size** | Gigabytes (full OS) | Megabytes (app + dependencies) |
| **Startup Time** | Minutes | Seconds |
| **Resource Usage** | High (dedicated resources) | Low (shared resources) |
| **Isolation** | Hardware-level (stronger) | Process-level (lighter) |
| **Portability** | Limited (large images) | High (lightweight images) |
| **Use Case** | Running different OS, strong isolation | Microservices, dev environments |

**Why Docker for this project?**
Docker provides lightweight, reproducible environments ideal for web services. Each service runs in isolation while sharing the host kernel, making it efficient for a multi-service architecture.

---

### 🔐 Secrets vs Environment Variables

| Aspect | Environment Variables | Docker Secrets |
|--------|----------------------|----------------|
| **Storage** | Plain text in .env file | Encrypted, stored in Swarm |
| **Access** | Visible in `docker inspect` | Only available inside container |
| **Scope** | Any Docker setup | Docker Swarm only |
| **Security** | Lower (exposed in process list) | Higher (encrypted at rest) |
| **Ease of Use** | Simple, universal | Requires Swarm mode |

**Project Choice:**
This project uses **environment variables** via `.env` file because:
- Docker Compose standalone doesn't support Swarm secrets
- The `.env` file is excluded from version control
- Simpler setup for development/learning purposes

**Best Practice:** In production, use Docker Secrets with Swarm or external secret managers (Vault, AWS Secrets Manager).

---

### 🌐 Docker Network vs Host Network

| Aspect | Docker Network (Bridge) | Host Network |
|--------|------------------------|--------------|
| **Isolation** | Containers isolated from host | Container shares host's network |
| **Port Mapping** | Required (`-p 443:443`) | Not needed (direct access) |
| **Security** | Higher (controlled exposure) | Lower (all ports exposed) |
| **DNS Resolution** | Container names as hostnames | Uses host's DNS |
| **Performance** | Slight overhead | Native performance |
| **Multi-Container** | Containers communicate by name | Containers share host ports |

**Project Choice:**
This project uses a **custom bridge network** (`all`) because:
- Containers communicate securely by service name
- Only necessary ports are exposed to the host
- Better isolation and security
- Required by the project subject (no `network: host` allowed)

---

### 💾 Docker Volumes vs Bind Mounts

| Aspect | Docker Volumes | Bind Mounts |
|--------|---------------|-------------|
| **Management** | Managed by Docker | Direct host path |
| **Location** | `/var/lib/docker/volumes/` | Any host directory |
| **Portability** | Easy backup/restore | Host-dependent |
| **Performance** | Optimized for containers | Native filesystem |
| **Use Case** | Persistent data (databases) | Development (live code) |
| **Permissions** | Docker handles permissions | Manual permission management |

**Project Choice:**
This project uses **named Docker volumes** with custom paths:
```yaml
volumes:
  database:
    driver_opts:
      device: /home/mmiguelo/data/database
```
This provides:
- Persistent data across container restarts
- Data stored in user's home directory (`/home/login/data/`)
- Easy backup and inspection

---

## Instructions

### Prerequisites

- Docker Engine 20.10+
- Docker Compose v2.0+
- `make` utility
- `hostsed` for hosts file management (or manually edit `/etc/hosts`)

### Installation

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd inception
   ```

2. **Configure environment variables:**
   ```bash
   cp srcs/.env.example srcs/.env
   # Edit srcs/.env with your credentials
   ```

3. **Build and start services:**
   ```bash
   make          # Start mandatory services only
   # OR
   make bonus    # Start all services (mandatory + bonus)
   ```

### Makefile Commands

| Command | Description |
|---------|-------------|
| `make` or `make up` | Build and start mandatory services |
| `make down` | Stop and remove containers |
| `make bonus` | Build and start all services (including bonus) |
| `make bonus-down` | Stop all services |
| `make status` | Show container, image, volume, and network status |
| `make clean` | Stop containers and remove volumes |
| `make fclean` | Full cleanup (backup data first) |
| `make prepare` | Remove ALL Docker resources (clean slate) |
| `make re` | Rebuild everything from scratch |

---

## Further Documentation

| Document | Description |
|----------|-------------|
| [USER_DOC.md](USER_DOC.md) | User guide: accessing services, credentials, status checks |
| [DEV_DOC.md](DEV_DOC.md) | Developer guide: setup, building, container management |
| [EVALUATION_GUIDE.md](EVALUATION_GUIDE.md) | Testing procedures for 42 evaluation |

---

## Resources

### Official Documentation

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [NGINX Documentation](https://nginx.org/en/docs/)
- [MariaDB Documentation](https://mariadb.com/kb/en/documentation/)
- [WordPress Developer Resources](https://developer.wordpress.org/)
- [PHP-FPM Documentation](https://www.php.net/manual/en/install.fpm.php)

### Tutorials & Articles

- [Docker Getting Started Guide](https://docs.docker.com/get-started/)
- [Dockerfile Best Practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- [Docker Networking Overview](https://docs.docker.com/network/)
- [NGINX + PHP-FPM Configuration](https://www.nginx.com/resources/wiki/start/topics/examples/phpfcgi/)
- [SSL/TLS Certificate Generation](https://www.openssl.org/docs/man1.1.1/man1/req.html)

### AI Usage Disclosure

AI tools (GitHub Copilot, Claude) were used in this project for:

| Task | AI Contribution |
|------|-----------------|
| **Dockerfile optimization** | Suggestions for multi-stage builds and layer optimization |
| **Configuration debugging** | Identifying syntax errors in nginx.conf, php-fpm configs |
| **Documentation** | Generating this README structure and content |
| **Shell scripting** | Setup scripts for service initialization |
| **Troubleshooting** | Diagnosing container networking and permission issues |

All AI-generated code was reviewed, tested, and adapted to meet project requirements. The core architecture and design decisions were made independently.

---

## License

This project is part of the 42 school curriculum. Feel free to use it as a reference for learning purposes.

---

## Author

- **mmiguelo** - [42 Profile](https://profile.intra.42.fr/users/mmiguelo)

---

*Made with 🐳 and ☕*
