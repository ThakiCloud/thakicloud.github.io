---
title: "Complete Guide to PrestaShop Installation and Setup: Building Your E-commerce Store from Scratch"
excerpt: "Step-by-step tutorial for installing and configuring PrestaShop 9.0 e-commerce platform with Docker, PHP, and MySQL. Perfect for beginners building their first online store."
seo_title: "PrestaShop Installation Guide 2025 - Complete Setup Tutorial - Thaki Cloud"
seo_description: "Learn how to install PrestaShop 9.0 e-commerce platform step-by-step. Includes Docker setup, database configuration, and best practices for online store development."
date: 2025-09-02
categories:
  - tutorials
tags:
  - prestashop
  - ecommerce
  - php
  - docker
  - mysql
  - installation
author_profile: true
toc: true
toc_label: "Contents"
lang: en
permalink: /en/tutorials/prestashop-complete-setup-installation-guide/
canonical_url: "https://thakicloud.github.io/en/tutorials/prestashop-complete-setup-installation-guide/"
---

⏱️ **Estimated Reading Time**: 15 minutes

## Introduction

PrestaShop is a powerful open-source e-commerce platform that enables you to build professional online stores with advanced features like multi-language support, payment gateway integration, and comprehensive inventory management. In this comprehensive tutorial, you'll learn how to install and configure PrestaShop 9.0 from scratch, whether you're using traditional server setup or modern Docker containers.

With over 8.7k GitHub stars and active community support, PrestaShop has established itself as one of the leading e-commerce solutions for businesses of all sizes. This guide will walk you through every step of the installation process, ensuring you have a fully functional online store ready for customization.

## Prerequisites and System Requirements

Before beginning the installation, ensure your system meets the following requirements:

### Server Requirements
- **PHP**: Version 8.1 or higher
- **Database**: MySQL 5.6+, MariaDB, or Percona Server
- **Web Server**: Apache or Nginx (recommended)
- **Memory**: Minimum 512MB RAM (2GB+ recommended for production)
- **Storage**: At least 1GB free disk space

### Development Environment Requirements
- **Docker**: Latest version (for container-based setup)
- **Git**: For cloning the repository
- **Text Editor**: VS Code, PhpStorm, or similar
- **Database Admin Tool**: phpMyAdmin (optional but recommended)

### Recommended System Configuration
```bash
# For Ubuntu/Debian systems
sudo apt update && sudo apt upgrade -y
sudo apt install php8.1 php8.1-mysql php8.1-curl php8.1-gd php8.1-mbstring php8.1-xml php8.1-zip
sudo apt install mysql-server nginx git curl
```

## Installation Method 1: Docker Setup (Recommended for Development)

Docker provides the fastest and most reliable way to get PrestaShop running, especially for development and testing purposes.

### Step 1: Clone the PrestaShop Repository

```bash
# Create project directory
mkdir prestashop-project && cd prestashop-project

# Clone the official repository
git clone https://github.com/PrestaShop/PrestaShop.git
cd PrestaShop

# Switch to the stable branch (optional)
git checkout main
```

### Step 2: Configure Environment Variables

```bash
# Set custom admin credentials (optional)
export ADMIN_MAIL=admin@yourstore.com
export ADMIN_PASSWD=SecurePassword123!

# Verify environment variables
echo "Admin Email: $ADMIN_MAIL"
echo "Admin Password: $ADMIN_PASSWD"
```

### Step 3: Launch Docker Services

```bash
# Start PrestaShop with Docker Compose
docker compose up -d

# Monitor the startup process
docker compose logs -f prestashop
```

### Step 4: Access Your Store

Once the containers are running, you can access:

- **Frontend Store**: http://localhost:8001
- **Admin Panel**: http://localhost:8001/admin-dev
- **Default Login**: demo@prestashop.com / Correct Horse Battery Staple

### Step 5: Optional Services Setup

#### Adding phpMyAdmin
```bash
# Copy the override configuration
cp docker-compose.override.yml.dist docker-compose.override.yml

# Start services with phpMyAdmin
docker compose up -d

# Access phpMyAdmin at http://localhost:8080
```

#### Blackfire Integration (Performance Monitoring)
```bash
# Set Blackfire environment variables
export BLACKFIRE_ENABLE=1
export BLACKFIRE_SERVER_ID="your_server_id"
export BLACKFIRE_SERVER_TOKEN="your_blackfire_server_token"

# Update docker-compose.override.yml with Blackfire configuration
# Then restart services
docker compose down && docker compose up -d
```

## Installation Method 2: Traditional Server Setup

For production environments or when you prefer traditional server setup, follow these steps:

### Step 1: Download PrestaShop

```bash
# Download the latest stable release
wget https://github.com/PrestaShop/PrestaShop/releases/download/9.0.0/prestashop_9.0.0.zip

# Extract the files
unzip prestashop_9.0.0.zip -d /var/www/html/prestashop

# Set proper permissions
sudo chown -R www-data:www-data /var/www/html/prestashop
sudo chmod -R 755 /var/www/html/prestashop
```

### Step 2: Configure Web Server

#### Nginx Configuration
```nginx
server {
    listen 80;
    server_name your-domain.com;
    root /var/www/html/prestashop;
    index index.php index.html;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

#### Apache Configuration
```apache
<VirtualHost *:80>
    ServerName your-domain.com
    DocumentRoot /var/www/html/prestashop
    
    <Directory /var/www/html/prestashop>
        AllowOverride All
        Require all granted
    </Directory>
    
    ErrorLog ${APACHE_LOG_DIR}/prestashop_error.log
    CustomLog ${APACHE_LOG_DIR}/prestashop_access.log combined
</VirtualHost>
```

### Step 3: Database Setup

```sql
-- Create database and user
CREATE DATABASE prestashop_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'prestashop_user'@'localhost' IDENTIFIED BY 'secure_password';
GRANT ALL PRIVILEGES ON prestashop_db.* TO 'prestashop_user'@'localhost';
FLUSH PRIVILEGES;
```

### Step 4: Run Installation Wizard

1. Navigate to `http://your-domain.com/install-dev`
2. Follow the installation wizard:
   - **Language Selection**: Choose your preferred language
   - **License Agreement**: Accept the terms
   - **System Requirements**: Verify all requirements are met
   - **Store Information**: Configure store name, logo, and admin account
   - **Database Configuration**: Enter MySQL credentials
   - **Installation**: Wait for the process to complete

### Step 5: Security Hardening

```bash
# Remove installation directory
sudo rm -rf /var/www/html/prestashop/install-dev

# Rename admin directory for security
sudo mv /var/www/html/prestashop/admin-dev /var/www/html/prestashop/admin-$(openssl rand -hex 4)

# Set restrictive permissions
sudo chmod 644 /var/www/html/prestashop/app/config/parameters.php
sudo chmod 755 /var/www/html/prestashop/var
```

## Post-Installation Configuration

### Essential Security Settings

1. **Change Admin Directory Name**
   ```bash
   # The admin directory should be renamed to prevent unauthorized access
   mv admin-dev admin-$(date +%s)
   ```

2. **Configure SSL/HTTPS**
   ```bash
   # Install SSL certificate (using Let's Encrypt)
   sudo apt install certbot python3-certbot-nginx
   sudo certbot --nginx -d your-domain.com
   ```

3. **Update Configuration Parameters**
   ```php
   // In app/config/parameters.php
   'ps_base_dir' => '/var/www/html/prestashop/',
   'ps_ssl_enabled' => true,
   'ps_shop_domain' => 'your-domain.com',
   'ps_shop_domain_ssl' => 'your-domain.com',
   ```

### Performance Optimization

#### Enable Caching
```php
// In app/config/parameters.php
'cache_driver' => 'redis', // or 'memcached'
'cache_prefix' => 'ps_',
'cache_host' => '127.0.0.1',
'cache_port' => 6379,
```

#### Configure OpCache
```ini
; In php.ini
opcache.enable=1
opcache.memory_consumption=128
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=4000
opcache.revalidate_freq=60
opcache.save_comments=1
```

### Module Management

#### Install Essential Modules
```bash
# Navigate to modules directory
cd /var/www/html/prestashop/modules

# Download popular modules
git clone https://github.com/PrestaShop/ps_facetedsearch.git
git clone https://github.com/PrestaShop/ps_emailsubscription.git
```

#### Configure Payment Modules
1. **PayPal Integration**
   - Go to Admin → Modules → Payment
   - Install PayPal Official module
   - Configure API credentials

2. **Stripe Configuration**
   - Install Stripe Official module
   - Set up webhook endpoints
   - Configure test/live modes

## Development Environment Setup

### Development Dependencies

```bash
# Install Node.js and npm for theme development
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install nodejs

# Install Composer for PHP dependencies
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

# Install development tools
composer install --dev
npm install
```

### Theme Development Setup

```bash
# Navigate to themes directory
cd themes/classic

# Install theme dependencies
npm install

# Start development server with hot reload
npm run dev

# Build for production
npm run build
```

### Module Development Environment

```bash
# Create custom module structure
mkdir modules/mycustommodule
cd modules/mycustommodule

# Basic module structure
touch mycustommodule.php
mkdir config controllers override translations views
mkdir views/templates views/css views/js
```

## Troubleshooting Common Issues

### Docker-Related Problems

#### Container Won't Start
```bash
# Check container logs
docker compose logs prestashop

# Reset containers completely
docker compose down -v
docker compose build --no-cache
docker compose up --build --force-recreate
```

#### Database Connection Issues
```bash
# Verify database container is running
docker compose ps

# Check database logs
docker compose logs mysql

# Reset database volume
docker compose down -v
docker volume rm prestashop_mysql_data
```

### Traditional Installation Issues

#### Permission Problems
```bash
# Fix file permissions
sudo chown -R www-data:www-data /var/www/html/prestashop
sudo find /var/www/html/prestashop -type d -exec chmod 755 {} \;
sudo find /var/www/html/prestashop -type f -exec chmod 644 {} \;
```

#### PHP Memory Limit
```ini
; In php.ini or .htaccess
memory_limit = 512M
max_execution_time = 300
max_input_vars = 10000
```

#### URL Rewrite Issues
```apache
# In .htaccess
RewriteEngine On
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule ^(.*)$ index.php [QSA,L]
```

## Advanced Configuration

### Multi-Store Setup

```php
// Enable multistore in parameters.php
'ps_multishop_feature_active' => true,

// Configure store groups
'shop_group' => [
    'main' => ['id' => 1, 'name' => 'Main Group'],
    'secondary' => ['id' => 2, 'name' => 'Secondary Group']
],
```

### API Configuration

```php
// Enable web services
'ps_webservice' => true,
'ps_webservice_key' => 'your-api-key-here',

// Configure API permissions
'api_permissions' => [
    'products' => ['GET', 'POST', 'PUT', 'DELETE'],
    'customers' => ['GET', 'POST', 'PUT'],
    'orders' => ['GET', 'PUT']
],
```

### Backup and Maintenance

#### Automated Backup Script
```bash
#!/bin/bash
# backup-prestashop.sh

BACKUP_DIR="/var/backups/prestashop"
DB_NAME="prestashop_db"
DB_USER="prestashop_user"
DB_PASS="secure_password"
WEB_DIR="/var/www/html/prestashop"

# Create backup directory
mkdir -p $BACKUP_DIR/$(date +%Y-%m-%d)

# Backup database
mysqldump -u$DB_USER -p$DB_PASS $DB_NAME > $BACKUP_DIR/$(date +%Y-%m-%d)/database.sql

# Backup files
tar -czf $BACKUP_DIR/$(date +%Y-%m-%d)/files.tar.gz $WEB_DIR

# Clean old backups (keep 30 days)
find $BACKUP_DIR -type d -mtime +30 -exec rm -rf {} \;
```

## Best Practices and Security

### Security Checklist

1. **Regular Updates**
   ```bash
   # Check for updates
   git fetch origin
   git checkout tags/latest-stable-version
   
   # Update dependencies
   composer update
   npm update
   ```

2. **Database Security**
   ```sql
   -- Use strong passwords
   -- Limit database user privileges
   -- Enable SSL connections
   SET GLOBAL require_secure_transport=ON;
   ```

3. **File System Security**
   ```bash
   # Disable directory browsing
   echo "Options -Indexes" >> .htaccess
   
   # Protect sensitive files
   chmod 600 app/config/parameters.php
   chmod 600 .env
   ```

### Performance Monitoring

#### Setup Monitoring Tools
```bash
# Install system monitoring
sudo apt install htop iotop nethogs

# Configure log rotation
sudo logrotate -d /etc/logrotate.d/prestashop

# Setup database monitoring
mysql -e "SHOW PROCESSLIST; SHOW STATUS LIKE 'Slow_queries';"
```

## Conclusion

You've successfully installed and configured PrestaShop, creating a robust foundation for your e-commerce store. Whether you chose the Docker approach for development convenience or the traditional server setup for production deployment, your PrestaShop installation is now ready for customization and store development.

Key accomplishments in this tutorial:
- ✅ **Complete Installation**: Successfully deployed PrestaShop 9.0
- ✅ **Security Configuration**: Implemented essential security measures
- ✅ **Performance Optimization**: Configured caching and optimization settings
- ✅ **Development Environment**: Set up tools for theme and module development
- ✅ **Troubleshooting Knowledge**: Learned to resolve common installation issues

### Next Steps

1. **Store Customization**: Configure your store settings, add products, and customize the theme
2. **Payment Integration**: Set up payment gateways like PayPal, Stripe, or local payment methods
3. **SEO Optimization**: Configure URL rewriting, meta tags, and sitemap generation
4. **Module Development**: Create custom modules for specific business requirements
5. **Performance Tuning**: Implement advanced caching strategies and CDN integration

For continued learning, explore the [PrestaShop DevDocs](https://devdocs.prestashop-project.org/) and join the active community on [GitHub](https://github.com/PrestaShop/PrestaShop) and [Slack](https://www.prestashop-project.org/slack/).

Your e-commerce journey with PrestaShop begins now – start building, customizing, and growing your online business!
