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
- [Usage](#usage)
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

### Infrastructure Diagram:

```
                                  ┌─────────────────────────────────────────────────────────┐
                                  │                  Docker Network (all)                   │
                                  │                                                         │
┌──────────┐  HTTPS (443)    ┌────┴────┐  FastCGI (9000)   ┌───────────┐  SQL (3306)   ┌────┴─────┐
│  Client  │ ─────────────▶  │  NGINX  │ ───────────────▶  │ WordPress │ ────────────▶ │ MariaDB  │
│ Browser  │                 │   SSL   │                   │  PHP-FPM  │               │ Database │
└──────────┘                 └─────────┘                   └───────────┘               └──────────┘
                                  │                              │                          │
                                  │                              │                          │
                             ┌────┴────┐                    ┌────┴────┐                ┌────┴────┐
                             │ Volume  │                    │ Volume  │                │ Volume  │
                             │  certs  │                    │  files  │                │   db    │
                             └─────────┘                    └─────────┘                └─────────┘
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

## Usage

### Accessing Services

| Service | URL | Credentials |
|---------|-----|-------------|
| WordPress | https://mmiguelo.42.fr | User: see `.env` |
| WordPress Admin | https://mmiguelo.42.fr/wp-admin | Admin: see `.env` |
| Adminer | http://localhost:600 | Server: `mariadb` |
| Portainer | https://localhost:9443 | Create on first access |
| Uptime Kuma | http://localhost:3001 | Create on first access |
| cAdvisor | http://localhost:8080 | No auth |
| Static Website | http://localhost:8081 | No auth |

### Database Access

```bash
# Connect to MariaDB
docker exec -it mariadb mariadb -u <DB_USER> -p<DB_PASSWORD> <DB_NAME>

# Example
docker exec -it mariadb mariadb -u theuser -pabc thedatabase
```

### Useful Commands

```bash
# View container logs
docker logs <container_name>

# Enter a container shell
docker exec -it <container_name> bash

# Check network connections
docker network inspect inception_all

# Verify SSL certificate
echo | openssl s_client -connect mmiguelo.42.fr:443 2>/dev/null | openssl x509 -noout -text
```

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
