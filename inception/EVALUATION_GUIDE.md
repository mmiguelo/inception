# 🎯 Inception Evaluation Guide - mmiguelo

---

## 📋 Table of Contents
1. [Pre-Evaluation Cleanup](#1-pre-evaluation-cleanup)
2. [Preliminary Tests](#2-preliminary-tests)
3. [Theoretical Questions & Answers](#3-theoretical-questions--answers)
4. [Mandatory Part Tests](#4-mandatory-part-tests)
5. [Bonus Part Tests](#5-bonus-part-tests)

---

## 1. Pre-Evaluation Cleanup

### Full Docker Cleanup (run this BEFORE evaluation starts)

```bash
# Official cleanup command from subject
docker stop $(docker ps -qa); docker rm $(docker ps -qa); docker rmi -f $(docker images -qa); docker volume rm $(docker volume ls -q); docker network rm $(docker network ls -q) 2>/dev/null
```

**OR use your Makefile:**
```bash
make prepare
```

### Verify clean state:
```bash
docker ps -a          # Expected: empty (no containers)
docker images         # Expected: empty (no images)
docker volume ls      # Expected: empty (no volumes)
docker network ls     # Expected: only bridge, host, none
```

---

## 2. Preliminary Tests

### 2.1 Check .env file location
```bash
ls -la srcs/.env
```
**Expected:** File exists inside `srcs/` folder

### 2.2 Check no credentials in git (outside .env)
```bash
grep -r "password\|PASSWORD\|secret\|SECRET\|api_key\|API_KEY" --include="*.sh" --include="*.conf" --include="*.php" --include="Dockerfile" srcs/
```
**Expected:** No sensitive hardcoded values (only environment variable references like `${DB_PASSWORD}`)

### 2.3 Verify folder structure
```bash
ls -la           # Expected: Makefile at root
ls -la srcs/     # Expected: docker-compose.yml + requirements folder
```

### 2.4 Check docker-compose.yml for forbidden items
```bash
# Must NOT contain 'network: host' or 'links:'
grep -E "network:\s*host|links:" srcs/docker-compose.yml
```
**Expected:** No output (nothing found)

```bash
# MUST contain 'networks:'
grep "networks:" srcs/docker-compose.yml
```
**Expected:** Multiple matches showing network configuration

### 2.5 Check for forbidden '--link' in Makefile/scripts
```bash
grep -r "\-\-link" Makefile srcs/
```
**Expected:** No output (nothing found)

### 2.6 Check Dockerfiles for forbidden commands
```bash
# Check for 'tail -f' in ENTRYPOINT
grep -r "tail -f" srcs/requirements/*/Dockerfile
grep -r "sleep infinity" srcs/requirements/*/Dockerfile
grep -r "tail -f /dev/null" srcs/requirements/*/Dockerfile
```
**Expected:** No output (nothing found)

### 2.7 Run Makefile
```bash
make
```
**Expected:** All 3 mandatory containers start successfully (mariadb, wordpress, nginx)

---

## 3. Theoretical Questions & Answers

### 3.1 How Docker and docker compose work?

**Answer:**
> "Docker is a containerization platform that packages applications and their dependencies into isolated containers. Each container shares the host OS kernel but has its own filesystem, network, and process space.
>
> Docker Compose is a tool for defining and running multi-container applications. It uses a YAML file (docker-compose.yml) to configure all services, networks, and volumes in one place. With a single command (`docker compose up`), it creates and starts all the services defined in the configuration."

### 3.2 Difference between Docker image with/without docker compose?

**Answer:**
> "Without docker compose, you manage each container individually:
> - Build: `docker build -t myimage .`
> - Run: `docker run -d -p 80:80 --network mynet -v myvol:/data myimage`
> - You must manually handle networks, volumes, and dependencies.
>
> With docker compose, everything is declarative in a YAML file:
> - All services, networks, volumes defined in one place
> - Dependencies handled automatically with `depends_on`
> - Single command `docker compose up` starts everything in correct order
> - Easier to manage complex multi-container applications"

### 3.3 Benefit of Docker compared to VMs?

**Answer:**
> "Docker containers are more lightweight and efficient than VMs:
>
> | Feature | Docker Containers | Virtual Machines |
> |---------|------------------|------------------|
> | Size | MBs | GBs |
> | Startup | Seconds | Minutes |
> | OS | Shares host kernel | Full OS per VM |
> | Resources | Less overhead | High overhead |
> | Isolation | Process-level | Hardware-level |
>
> Docker is ideal for microservices and development environments where fast startup and low resource usage are priorities."

### 3.4 Pertinence of directory structure?

**Answer:**
> "The directory structure follows best practices for Docker projects:
> ```
> inception/
> ├── Makefile              # Automation at root level
> └── srcs/
>     ├── .env              # Environment variables (secrets)
>     ├── docker-compose.yml # Service orchestration
>     └── requirements/      # One folder per service
>         ├── mariadb/
>         │   ├── Dockerfile
>         │   ├── conf/      # Configuration files
>         │   └── tools/     # Scripts
>         ├── nginx/
>         └── wordpress/
> ```
> This separation allows:
> - Each service is self-contained and maintainable
> - Configuration is separate from code
> - Secrets are centralized in .env
> - Easy to add new services"

### 3.5 What is docker-network?

**Answer:**
> "Docker networks allow containers to communicate with each other securely. In this project, all containers are on the same network called 'all' (bridge driver).
>
> Benefits:
> - Containers can reach each other by container name (DNS resolution)
> - Isolated from external traffic unless ports are exposed
> - No need for IP addresses, just use service names (e.g., `mariadb:3306`)
>
> Example: WordPress connects to MariaDB using hostname 'mariadb' instead of an IP."

---

## 4. Mandatory Part Tests

### 4.1 Start the Project
```bash
make
```

### 4.2 Check Container Status
```bash
docker compose -f srcs/docker-compose.yml ps
# OR
make status
```
**Expected:** 3 containers running: mariadb, wordpress, nginx

### 4.3 NGINX - Port 443 Only

**Test port 443 (HTTPS) - should work:**
```bash
curl -k https://mmiguelo.42.fr
```
**Expected:** HTML content (WordPress page)

**Test port 80 (HTTP) - should FAIL:**
```bash
curl http://mmiguelo.42.fr
# OR
curl http://mmiguelo.42.fr:80
```
**Expected:** Connection refused (curl: (7) Failed to connect)

**Verify only port 443 is exposed:**
```bash
docker port nginx
```
**Expected:** `443/tcp -> 0.0.0.0:443`

### 4.4 SSL/TLS Certificate Verification

**Check TLS version:**
```bash
echo | openssl s_client -connect mmiguelo.42.fr:443 2>/dev/null | grep -E "Protocol|TLSv"
```
**Expected:** `Protocol  : TLSv1.3` (or TLSv1.2)

**View certificate details:**
```bash
echo | openssl s_client -connect mmiguelo.42.fr:443 2>/dev/null | openssl x509 -noout -subject -issuer
```
**Expected:**
```
subject=C = BR, ST = BA, L = Salvador, O = 42, OU = 42, CN = mmiguelo.42.fr
issuer=C = BR, ST = BA, L = Salvador, O = 42, OU = 42, CN = mmiguelo.42.fr
```
(Self-signed: subject = issuer)

### 4.5 WordPress Website

**Visual test:** Open browser to `https://mmiguelo.42.fr`

**Expected:** WordPress site loads (NOT the installation page)

**Terminal test:**
```bash
curl -k -s https://mmiguelo.42.fr | grep -i "wordpress\|Inception"
```
**Expected:** HTML content with WordPress or your site title

### 4.6 Check Dockerfiles Exist and Are Not Empty

```bash
# List all Dockerfiles
find srcs/requirements -name "Dockerfile" -exec echo "=== {} ===" \; -exec head -5 {} \;
```
**Expected:** Each Dockerfile starts with `FROM debian:bookworm`

### 4.7 Check Images Built Locally (not from DockerHub)

```bash
docker images | grep -E "inception|mariadb|wordpress|nginx"
```
**Expected:** Images named `inception-mariadb`, `inception-wordpress`, `inception-nginx`

**Verify base image:**
```bash
grep "^FROM" srcs/requirements/mariadb/Dockerfile
grep "^FROM" srcs/requirements/wordpress/Dockerfile
grep "^FROM" srcs/requirements/nginx/Dockerfile
```
**Expected:** All show `FROM debian:bookworm`

### 4.8 Docker Network

**List networks:**
```bash
docker network ls | grep inception
```
**Expected:** `inception_all` network visible

**Inspect network:**
```bash
docker network inspect inception_all
```
**Expected:** Shows all 3 containers (mariadb, wordpress, nginx) connected

### 4.9 Volumes Verification

**List volumes:**
```bash
docker volume ls | grep inception
```
**Expected:** `inception_database` and `inception_wordpress_files`

**Inspect database volume:**
```bash
docker volume inspect inception_database
```
**Expected:** Mountpoint contains `/home/mmiguelo/data/database`

**Inspect WordPress volume:**
```bash
docker volume inspect inception_wordpress_files
```
**Expected:** Mountpoint contains `/home/mmiguelo/data/wordpress_files`

### 4.10 WordPress User Test

**Visual test in browser:**
1. Go to `https://mmiguelo.42.fr`
2. Find a blog post with comments enabled
3. Add a comment as a visitor (or login as `theuser` / `abc`)
4. Verify comment appears

### 4.11 WordPress Admin Test

**Login as admin:**
1. Go to `https://mmiguelo.42.fr/wp-admin`
2. Login with: `theroot` / `123`
3. **Note:** Admin username is `theroot` (does NOT contain 'admin')

**Edit a page:**
1. Go to Pages → Edit any page
2. Make a change and publish
3. View the page on frontend - verify change appears

### 4.12 MariaDB Verification

**Connect to database:**
```bash
docker exec -it mariadb mariadb -u theuser -pabc thedatabase
```
**Expected:** MariaDB prompt appears

**Check database is not empty:**
```sql
SHOW TABLES;
```
**Expected:** WordPress tables (wp_posts, wp_users, wp_options, etc.)

```sql
SELECT user_login FROM wp_users;
```
**Expected:** Shows `theroot` and `theuser`

**Exit:**
```sql
EXIT;
```

### 4.13 Persistence Test (IMPORTANT!)

**Stop and restart:**
```bash
# Stop everything
make down

# OR for VM reboot simulation:
# sudo reboot

# Start again
make up
```

**Verify WordPress still works:**
```bash
curl -k https://mmiguelo.42.fr
```
**Expected:** Same WordPress site with all previous changes

**Verify database data persisted:**
```bash
docker exec -it mariadb mariadb -u theuser -pabc thedatabase -e "SELECT user_login FROM wp_users;"
```
**Expected:** Same users exist

---

## 5. Bonus Part Tests

### 5.1 Start Bonus Services
```bash
make bonus
```

**Check all containers:**
```bash
docker ps
```
**Expected:** 11 containers running:
- mariadb, wordpress, nginx (mandatory)
- adminer, ftp, redis, website, cadvisor, cron, portainer, kuma (bonus)

### 5.2 Adminer (Database Management Tool)

**Test:**
```bash
curl -s http://localhost:600 | head -20
```
**Expected:** HTML with Adminer login form

**Visual test:** Open `http://localhost:600`
- Server: `mariadb`
- Username: `theuser`
- Password: `abc`
- Database: `thedatabase`

**Explanation for evaluator:**
> "Adminer is a lightweight database management tool (like phpMyAdmin but simpler). It allows managing the MariaDB database through a web interface - viewing tables, running queries, importing/exporting data."

### 5.3 Redis (Cache)

**Test Redis is running:**
```bash
docker exec -it redis redis-cli ping
```
**Expected:** `PONG`

**Check Redis info:**
```bash
docker exec -it redis redis-cli info | head -20
```
**Expected:** Redis server information

**Explanation for evaluator:**
> "Redis is an in-memory data store used as a cache for WordPress. It stores frequently accessed data in RAM, reducing database queries and improving page load times."

### 5.4 FTP Server (vsftpd)

**Test FTP port:**
```bash
curl -v ftp://localhost:21 2>&1 | head -10
```
**Expected:** Connection established (220 response)

**Test FTP login:**
```bash
curl -u ftpuser:ftpuser123 ftp://localhost/
```
**Expected:** Directory listing of WordPress files

**Explanation for evaluator:**
> "The FTP server (vsftpd) provides file transfer access to the WordPress directory. It's useful for uploading themes, plugins, or managing files without SSH access."

### 5.5 Static Website

**Test:**
```bash
curl http://localhost:8081
```
**Expected:** HTML content of custom static website

**Visual test:** Open `http://localhost:8081`

**Explanation for evaluator:**
> "This is a separate static website served by Nginx. It demonstrates the ability to host multiple websites using Docker containers."

### 5.6 cAdvisor (Container Monitoring)

**Test:**
```bash
curl -s http://localhost:8080 | head -5
```
**Expected:** HTML (may redirect to /containers/)

**Visual test:** Open `http://localhost:8080`

**Explanation for evaluator:**
> "cAdvisor (Container Advisor) is Google's tool for monitoring container resource usage. It shows real-time CPU, memory, network, and filesystem usage for each container."

### 5.7 Portainer (Docker Management UI)

**Test:**
```bash
curl -k https://localhost:9443
```
**Expected:** HTML content (Portainer login page)

**Visual test:** Open `https://localhost:9443`
- First visit: Create admin account
- Then manage all Docker containers visually

**Explanation for evaluator:**
> "Portainer is a web-based Docker management UI. It allows managing containers, images, volumes, and networks through a graphical interface instead of command line."

### 5.8 Uptime Kuma (Monitoring)

**Test:**
```bash
curl -s http://localhost:3001 | head -5
```
**Expected:** HTML content (redirects to setup)

**Visual test:** Open `http://localhost:3001`
- Setup monitoring for your services
- Get alerts when services go down

**Explanation for evaluator:**
> "Uptime Kuma is a self-hosted monitoring tool. It checks if services are online and sends alerts if they go down. Useful for monitoring the health of all containers."

### 5.9 Cron (Scheduled Backups)

**Verify cron is running:**
```bash
docker exec cron ps aux | grep cron
```
**Expected:** cron daemon running

**Check crontab:**
```bash
docker exec cron crontab -l
```
**Expected:** Shows backup schedule (daily at 3 AM)

**Test backup manually:**
```bash
docker exec cron /usr/local/bin/backup.sh
```

**Verify backup created:**
```bash
docker exec cron ls -la /backups/
```
**Expected:** Backup files with timestamps

**Explanation for evaluator:**
> "The cron container runs scheduled tasks. It's configured to backup the WordPress database and files daily at 3 AM. Backups are stored in a persistent volume."

---

## 🔍 Quick Reference Commands

| Check | Command |
|-------|---------|
| All containers | `docker ps` |
| Container logs | `docker logs <container>` |
| Enter container | `docker exec -it <container> bash` |
| Network info | `docker network inspect inception_all` |
| Volume info | `docker volume inspect inception_database` |
| Stop all | `make down` or `make bonus-down` |
| Clean all | `make fclean` |
| Full reset | `make prepare` |

---

## ✅ Evaluation Checklist

### Mandatory
- [ ] No `network: host` or `links:` in docker-compose.yml
- [ ] `networks:` present in docker-compose.yml
- [ ] No `--link` in Makefile or scripts
- [ ] No `tail -f` or `sleep infinity` in Dockerfiles
- [ ] All Dockerfiles use `debian:bookworm` base
- [ ] NGINX only accessible on port 443
- [ ] SSL/TLS certificate (TLSv1.2 or TLSv1.3)
- [ ] WordPress loads (not installation page)
- [ ] Admin username doesn't contain 'admin'
- [ ] Can add comments and edit pages
- [ ] MariaDB database not empty
- [ ] Volumes mounted to `/home/mmiguelo/data/`
- [ ] Data persists after restart

### Bonus
- [ ] Adminer works (database management)
- [ ] Redis works (cache)
- [ ] FTP works (file transfer)
- [ ] Static website works
- [ ] cAdvisor works (monitoring)
- [ ] Portainer works (Docker UI)
- [ ] Uptime Kuma works (uptime monitoring)
- [ ] Cron works (scheduled backups)

---

*Good luck with your evaluation! 🚀*
