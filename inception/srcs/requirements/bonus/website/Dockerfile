# Static Website - Custom HTML/CSS website
# Serves a static website using Nginx

FROM    debian:bookworm

EXPOSE  80

# Install Nginx
RUN     apt update && apt install -y --no-install-recommends --no-install-suggests \
        nginx && \
        rm -rf /var/lib/apt/lists/*

# Remove default nginx site
RUN     rm -f /etc/nginx/sites-enabled/default

# Create website directory
RUN     mkdir -p /var/www/website

# Copy nginx config
COPY    conf/website.conf /etc/nginx/sites-available/website
RUN     ln -s /etc/nginx/sites-available/website /etc/nginx/sites-enabled/

# Copy HTML file
COPY    mmiguelo.html /var/www/website/index.html

# Set permissions
RUN     chown -R www-data:www-data /var/www/website

# Run Nginx in foreground
CMD     ["nginx", "-g", "daemon off;"]