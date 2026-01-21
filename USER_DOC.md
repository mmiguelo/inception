# 📖 Inception - User Documentation

This guide explains how to use and manage the Inception web hosting stack.

---

## Table of Contents

1. [Services Overview](#1-services-overview)
2. [Starting and Stopping the Project](#2-starting-and-stopping-the-project)
3. [Accessing the Website and Admin Panel](#3-accessing-the-website-and-admin-panel)
4. [Managing Credentials](#4-managing-credentials)
5. [Checking Service Status](#5-checking-service-status)

---

## 1. Services Overview

Inception provides a complete web hosting infrastructure with the following services:

### Core Services (Mandatory)

| Service | What it does |
|---------|--------------|
| **WordPress** | Your website content management system (CMS) |
| **MariaDB** | Database storing all website content and settings |
| **NGINX** | Web server that handles incoming requests with SSL encryption |

### Additional Services (Bonus)

| Service | What it does | When to use it |
|---------|--------------|----------------|
| **Adminer** | Database management interface | When you need to view/edit database tables |
| **Redis** | Performance cache | Automatically speeds up your website |
| **FTP** | File transfer server | When uploading files without SSH |
| **cAdvisor** | Container monitoring | When checking resource usage |
| **Portainer** | Docker management UI | When managing containers visually |
| **Uptime Kuma** | Status monitoring | When tracking service uptime |
| **Cron** | Automated backups | Runs automatically (daily at 3 AM) |
| **Static Website** | Additional HTML site | For hosting static content |

---

## 2. Starting and Stopping the Project

### Starting the Project

**Start core services only:**
```bash
make
```

**Start all services (including bonus):**
```bash
make bonus
```

### Stopping the Project

**Stop core services:**
```bash
make down
```

**Stop all services (including bonus):**
```bash
make bonus-down
```

### Other Useful Commands

| Command | What it does |
|---------|--------------|
| `make status` | Show all running containers and their status |
| `make clean` | Stop containers and remove data volumes |
| `make fclean` | Full cleanup (creates backup first) |
| `make re` | Restart everything from scratch |

### Quick Reference

```
┌─────────────────────────────────────────────────────────┐
│                    QUICK START                          │
├─────────────────────────────────────────────────────────┤
│                                                         │
│   Start:    make          (core only)                   │
│             make bonus    (all services)                │
│                                                         │
│   Stop:     make down     (core only)                   │
│             make bonus-down (all services)              │
│                                                         │
│   Status:   make status                                 │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## 3. Accessing the Website and Admin Panel

### Main Website

| What | URL |
|------|-----|
| **Website** | https://mmiguelo.42.fr |
| **Admin Panel** | https://mmiguelo.42.fr/wp-admin |

> ⚠️ **Note:** You will see a security warning about the SSL certificate. This is normal for self-signed certificates. Click "Advanced" → "Proceed to mmiguelo.42.fr" to continue.

### Bonus Services Access

| Service | URL | Notes |
|---------|-----|-------|
| **Adminer** | http://localhost:600 | Database management |
| **Portainer** | https://localhost:9443 | Docker management |
| **Uptime Kuma** | http://localhost:3001 | Monitoring dashboard |
| **cAdvisor** | http://localhost:8080 | Container metrics |
| **Static Website** | http://localhost:8081 | Custom HTML site |

### FTP Access

```
Host: localhost
Port: 21
User: ftpuser
Password: (see credentials section)
```

---

## 4. Managing Credentials

### Where are credentials stored?

All credentials are stored in a single file:

```
srcs/.env
```

### How to view credentials

```bash
cat srcs/.env
```

### Credential Reference

| Credential | Environment Variable | Used For |
|------------|---------------------|----------|
| **Database Name** | `DB_NAME` | MariaDB database name |
| **Database User** | `DB_USER` | MariaDB user account |
| **Database Password** | `DB_PASSWORD` | MariaDB user password |
| **Database Root Password** | `DB_PASS_ROOT` | MariaDB admin password |
| **WordPress Admin User** | `WP_ADMIN_USER` | WordPress admin login |
| **WordPress Admin Password** | `WP_ADMIN_PASSWORD` | WordPress admin password |
| **WordPress User** | `WP_USER` | WordPress regular user |
| **WordPress User Password** | `WP_PASSWORD` | WordPress user password |
| **FTP User** | `FTP_USER` | FTP login username |
| **FTP Password** | `FTP_PASSWORD` | FTP login password |

### Changing Credentials

1. **Stop the project:**
   ```bash
   make down
   ```

2. **Edit the credentials file:**
   ```bash
   nano srcs/.env
   ```

3. **Clean old data (required for database changes):**
   ```bash
   make clean
   ```

4. **Restart the project:**
   ```bash
   make
   ```

> ⚠️ **Important:** Changing database credentials requires removing old data. Make a backup first!

### First-Time Setup Credentials (Bonus Services)

Some bonus services require initial setup:

| Service | First Access |
|---------|--------------|
| **Portainer** | Create admin account on first visit |
| **Uptime Kuma** | Create admin account on first visit |
| **Adminer** | Use MariaDB credentials from `.env` |

---

## 5. Checking Service Status

### Quick Status Check

```bash
make status
```

This shows:
- Running containers
- Docker images
- Volumes
- Networks

### Check if Services are Running

```bash
docker ps
```

**Expected output (core services):**
```
CONTAINER ID   IMAGE                  STATUS         NAMES
xxxxxxxxxxxx   inception-nginx        Up X minutes   nginx
xxxxxxxxxxxx   inception-wordpress    Up X minutes   wordpress
xxxxxxxxxxxx   inception-mariadb      Up X minutes   mariadb
```

### Test Website Accessibility

```bash
curl -k https://mmiguelo.42.fr
```

**Expected:** HTML content of your WordPress site.

### Test Database Connection

```bash
docker exec -it mariadb mariadb -u theuser -pabc thedatabase -e "SELECT 1;"
```

**Expected:** Returns "1" if database is working.

### Check Individual Service Logs

```bash
# View NGINX logs
docker logs nginx

# View WordPress logs
docker logs wordpress

# View MariaDB logs
docker logs mariadb

# Follow logs in real-time (add -f)
docker logs -f nginx
```

### Health Check Commands

| Service | Test Command | Expected Result |
|---------|--------------|-----------------|
| **Website** | `curl -k https://mmiguelo.42.fr` | HTML content |
| **Adminer** | `curl http://localhost:600` | HTML form |
| **Redis** | `docker exec redis redis-cli ping` | `PONG` |
| **FTP** | `curl ftp://localhost:21` | Connection established |
| **cAdvisor** | `curl http://localhost:8080` | HTML/redirect |
| **Portainer** | `curl -k https://localhost:9443` | HTML content |
| **Kuma** | `curl http://localhost:3001` | HTML content |
| **Website** | `curl http://localhost:8081` | HTML content |

### Troubleshooting

#### Website not loading?

1. Check if containers are running:
   ```bash
   docker ps
   ```

2. Check NGINX logs:
   ```bash
   docker logs nginx
   ```

3. Verify host entry:
   ```bash
   grep mmiguelo /etc/hosts
   ```
   Should show: `127.0.0.1 mmiguelo.42.fr`

#### Database connection error?

1. Check MariaDB is running:
   ```bash
   docker ps | grep mariadb
   ```

2. Check MariaDB logs:
   ```bash
   docker logs mariadb
   ```

3. Test connection:
   ```bash
   docker exec -it mariadb mariadb -u root -p
   ```

#### Container keeps restarting?

Check logs for errors:
```bash
docker logs <container_name>
```

#### Need to start fresh?

```bash
make fclean   # Backup and remove everything
make prepare  # 
make up       # Rebuild from scratch
```
or
```
make prepare # Remove ALL Docker resources (clean slate)
make up      # Rebuild from scratch
```

---

## Quick Reference Card

```
┌─────────────────────────────────────────────────────────────────────┐
│                     INCEPTION QUICK REFERENCE                       │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  URLS                                                               │
│  ────                                                               │
│  Website:        https://mmiguelo.42.fr                             │
│  Admin Panel:    https://mmiguelo.42.fr/wp-admin                    │
│  Adminer:        http://localhost:600                               │
│  Portainer:      https://localhost:9443                             │
│  Monitoring:     http://localhost:3001                              │
│                                                                     │
│  COMMANDS                                                           │
│  ────────                                                           │
│  Start:          make  or  make bonus                               │
│  Stop:           make down  or  make bonus-down                     │
│  Status:         make status                                        │
│  Logs:           docker logs <container>                            │
│                                                                     │
│  CREDENTIALS                                                        │
│  ───────────                                                        │
│  Location:       srcs/.env                                          │
│  View:           cat srcs/.env                                      │
│                                                                     │
│  TROUBLESHOOTING                                                    │
│  ───────────────                                                    │
│  Check status:   docker ps                                          │
│  View logs:      docker logs nginx                                  │
│  Restart:        make down && make                                  │
│  Full reset:     make fclean && make                                │
│  Clen Slate:     make prepare && make                               │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

*For technical details and architecture information, see [README.md](README.md)*
