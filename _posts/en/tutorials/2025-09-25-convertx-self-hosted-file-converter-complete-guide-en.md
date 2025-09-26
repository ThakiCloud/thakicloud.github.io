---
title: "ConvertX: Self-Hosted Online File Converter - Complete Setup and Usage Guide"
excerpt: "Learn how to deploy and use ConvertX, a powerful self-hosted file converter supporting 1000+ formats with Docker. Perfect for privacy-conscious users and organizations."
seo_title: "ConvertX Self-Hosted File Converter Tutorial - Complete Guide - Thaki Cloud"
seo_description: "Step-by-step guide to deploy ConvertX with Docker. Self-hosted file converter supporting 1000+ formats including images, videos, documents, and 3D assets."
date: 2025-09-25
categories:
  - tutorials
tags:
  - docker
  - file-converter
  - self-hosted
  - typescript
  - privacy
author_profile: true
toc: true
toc_label: "Table of Contents"
lang: en
permalink: /en/tutorials/convertx-self-hosted-file-converter-complete-guide/
canonical_url: "https://thakicloud.github.io/en/tutorials/convertx-self-hosted-file-converter-complete-guide/"
---

⏱️ **Estimated Reading Time**: 8 minutes

## Introduction

In today's digital world, file format conversion is a common necessity. Whether you're dealing with images, videos, documents, or 3D assets, having a reliable converter is essential. While cloud-based solutions exist, they often raise privacy concerns and may have limitations on file sizes or usage quotas.

[ConvertX](https://github.com/C4illin/ConvertX) offers an elegant solution: a self-hosted online file converter that supports over 1000 different formats. Built with TypeScript, Bun, and Elysia, ConvertX gives you complete control over your data while providing enterprise-grade conversion capabilities.

## What is ConvertX?

ConvertX is an open-source, self-hosted file conversion platform that runs entirely on your infrastructure. With support for multiple file formats across various categories, it's designed to be both powerful and privacy-focused.

### Key Features

- **Extensive Format Support**: Over 1000 different file formats
- **Batch Processing**: Convert multiple files simultaneously
- **Privacy Protection**: Password protection and user authentication
- **Multi-User Support**: Multiple accounts with proper isolation
- **Modern Architecture**: Built with TypeScript and modern web technologies
- **Docker-Ready**: Easy deployment with Docker and Docker Compose

### Supported Converters

ConvertX integrates multiple specialized converters to handle different file types:

| Converter | Use Case | Input Formats | Output Formats |
|-----------|----------|---------------|----------------|
| **FFmpeg** | Video/Audio | ~472 | ~199 |
| **ImageMagick** | Images | 245 | 183 |
| **GraphicsMagick** | Images | 167 | 130 |
| **Assimp** | 3D Assets | 77 | 23 |
| **Pandoc** | Documents | 43 | 65 |
| **Vips** | Images | 45 | 23 |
| **Calibre** | E-books | 26 | 19 |
| **Inkscape** | Vector Graphics | 7 | 17 |
| **libjxl** | JPEG XL | 11 | 11 |
| **Potrace** | Raster to Vector | 4 | 11 |

## Prerequisites

Before deploying ConvertX, ensure you have:

- **Docker** (version 20.10 or later)
- **Docker Compose** (version 2.0 or later)
- **Server with sufficient resources**:
  - Minimum: 2GB RAM, 1 CPU core
  - Recommended: 4GB RAM, 2+ CPU cores
  - Storage: At least 10GB free space for files and containers

## Installation and Setup

### Method 1: Docker Compose (Recommended)

Create a project directory and set up the configuration:

```bash
# Create project directory
mkdir convertx-app
cd convertx-app

# Create Docker Compose file
cat > docker-compose.yml << 'EOF'
services:
  convertx:
    image: ghcr.io/c4illin/convertx
    container_name: convertx
    restart: unless-stopped
    ports:
      - "3000:3000"
    environment:
      - JWT_SECRET=aLongAndSecretStringUsedToSignTheJSONWebToken1234567890
      - ACCOUNT_REGISTRATION=false
      - AUTO_DELETE_EVERY_N_HOURS=24
      - LANGUAGE=en
      # Uncomment if accessing over HTTP (not recommended for production)
      # - HTTP_ALLOWED=true
    volumes:
      - ./data:/app/data
    labels:
      - "com.docker.compose.project=convertx"
EOF

# Create data directory with proper permissions
mkdir -p data
sudo chown -R $USER:$USER data
```

### Method 2: Docker Run

For a quick start without Docker Compose:

```bash
# Create data directory
mkdir -p ~/convertx-data

# Run ConvertX container
docker run -d \
  --name convertx \
  --restart unless-stopped \
  -p 3000:3000 \
  -v ~/convertx-data:/app/data \
  -e JWT_SECRET=aLongAndSecretStringUsedToSignTheJSONWebToken1234567890 \
  -e ACCOUNT_REGISTRATION=false \
  -e AUTO_DELETE_EVERY_N_HOURS=24 \
  ghcr.io/c4illin/convertx
```

### Deployment

Deploy the application:

```bash
# Using Docker Compose
docker-compose up -d

# Verify the container is running
docker-compose ps

# Check logs
docker-compose logs -f convertx
```

## Initial Configuration

### 1. Access the Application

Open your web browser and navigate to:
- **Local access**: `http://localhost:3000`
- **Remote access**: `https://your-domain.com:3000` (HTTPS recommended)

### 2. Create Administrator Account

1. On first access, you'll see the registration page
2. Create your administrator account with a strong password
3. **Important**: Disable registration after creating your account by setting `ACCOUNT_REGISTRATION=false`

### 3. Configure Security Settings

For production deployment, consider these security enhancements:

```yaml
# Enhanced docker-compose.yml
services:
  convertx:
    image: ghcr.io/c4illin/convertx
    container_name: convertx
    restart: unless-stopped
    ports:
      - "127.0.0.1:3000:3000"  # Bind to localhost only
    environment:
      - JWT_SECRET=${JWT_SECRET}  # Use environment variable
      - ACCOUNT_REGISTRATION=false
      - HTTP_ALLOWED=false  # Force HTTPS
      - AUTO_DELETE_EVERY_N_HOURS=12  # Clean up files more frequently
      - HIDE_HISTORY=false
    volumes:
      - ./data:/app/data
      - /etc/localtime:/etc/localtime:ro  # Sync timezone
    networks:
      - convertx-network

networks:
  convertx-network:
    driver: bridge
```

## Usage Guide

### Basic File Conversion

1. **Upload Files**:
   - Click "Choose Files" or drag and drop
   - Select single or multiple files
   - Supported formats are automatically detected

2. **Select Output Format**:
   - Choose target format from the dropdown
   - Formats are categorized by type (Image, Video, Document, etc.)

3. **Configure Settings** (if available):
   - Quality settings for images/videos
   - Compression options
   - Resolution settings

4. **Start Conversion**:
   - Click "Convert" to begin processing
   - Monitor progress in real-time
   - Download results when complete

### Advanced Features

#### Batch Processing

ConvertX excels at processing multiple files:

```bash
# Example: Convert multiple images
# Upload: image1.png, image2.jpg, image3.bmp
# Output format: WebP
# Result: All images converted to WebP format
```

#### Password Protection

Protect sensitive files during conversion:

1. Enable password protection in settings
2. Set a conversion password
3. Share the password securely with authorized users

#### Custom FFmpeg Arguments

For advanced video processing, you can configure custom FFmpeg arguments:

```yaml
environment:
  - FFMPEG_ARGS=-preset veryfast -crf 23
```

### Practical Use Cases

#### 1. Image Optimization for Web

```bash
# Convert and optimize images for web use
Input: high-resolution.jpg (5MB)
Output: optimized.webp (500KB)
Settings: WebP format, 80% quality
```

#### 2. Document Format Migration

```bash
# Convert legacy documents
Input: old-document.doc
Output: modern-document.pdf
Converter: Pandoc
```

#### 3. Video Compression

```bash
# Compress video files
Input: large-video.mov (1GB)
Output: compressed-video.mp4 (200MB)
Converter: FFmpeg with H.264 codec
```

#### 4. 3D Asset Processing

```bash
# Convert 3D models between formats
Input: model.fbx
Output: model.glb
Converter: Assimp
```

## Environment Variables Reference

Customize ConvertX behavior with these environment variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `JWT_SECRET` | Random UUID | Secret key for JWT token signing |
| `ACCOUNT_REGISTRATION` | `false` | Allow new user registration |
| `HTTP_ALLOWED` | `false` | Allow HTTP connections (use only locally) |
| `ALLOW_UNAUTHENTICATED` | `false` | Allow anonymous usage |
| `AUTO_DELETE_EVERY_N_HOURS` | `24` | Automatic file cleanup interval |
| `WEBROOT` | `/` | Web application root path |
| `FFMPEG_ARGS` | None | Custom FFmpeg arguments |
| `HIDE_HISTORY` | `false` | Hide conversion history |
| `LANGUAGE` | `en` | Interface language (BCP 47 format) |
| `UNAUTHENTICATED_USER_SHARING` | `false` | Share history between anonymous users |

## Monitoring and Maintenance

### Health Checks

Monitor ConvertX status:

```bash
# Check container status
docker-compose ps

# View real-time logs
docker-compose logs -f convertx

# Check resource usage
docker stats convertx
```

### Backup Strategy

Protect your data with regular backups:

```bash
#!/bin/bash
# backup-convertx.sh

BACKUP_DIR="/backup/convertx"
DATA_DIR="./data"
DATE=$(date +%Y%m%d_%H%M%S)

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Backup data directory
tar -czf "$BACKUP_DIR/convertx_data_$DATE.tar.gz" -C "$DATA_DIR" .

# Keep only last 7 backups
find "$BACKUP_DIR" -name "convertx_data_*.tar.gz" -mtime +7 -delete

echo "Backup completed: convertx_data_$DATE.tar.gz"
```

### Updates

Keep ConvertX updated:

```bash
# Update to latest version
docker-compose pull
docker-compose up -d

# Check version
docker exec convertx cat /app/package.json | grep version
```

## Troubleshooting

### Common Issues

#### 1. Permission Errors

```bash
# Fix data directory permissions
sudo chown -R $USER:$USER ./data
chmod -R 755 ./data
```

#### 2. Login Issues

If you can't log in:
- Ensure you're accessing via HTTPS or localhost
- Set `HTTP_ALLOWED=true` for HTTP access (not recommended for production)

#### 3. Conversion Failures

Check logs for specific error messages:

```bash
# View detailed logs
docker-compose logs --tail=50 convertx

# Check container resources
docker stats convertx
```

#### 4. File Upload Limits

Large file uploads may fail. Check:
- Available disk space
- Container memory limits
- Network timeout settings

### Performance Optimization

#### Resource Allocation

For heavy usage, adjust Docker resource limits:

```yaml
services:
  convertx:
    # ... other configuration
    deploy:
      resources:
        limits:
          memory: 4G
          cpus: '2'
        reservations:
          memory: 2G
          cpus: '1'
```

#### Storage Optimization

Configure automatic cleanup:

```yaml
environment:
  - AUTO_DELETE_EVERY_N_HOURS=6  # Clean up every 6 hours
```

## Security Best Practices

### 1. Network Security

Use a reverse proxy for production:

```nginx
# Nginx configuration example
server {
    listen 443 ssl http2;
    server_name convert.yourdomain.com;
    
    ssl_certificate /path/to/certificate.crt;
    ssl_certificate_key /path/to/private.key;
    
    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # File upload size limit
        client_max_body_size 100M;
    }
}
```

### 2. Access Control

Implement additional security layers:

```yaml
# Using Traefik labels for authentication
labels:
  - "traefik.http.middlewares.convertx-auth.basicauth.users=admin:$$2y$$10$$..."
  - "traefik.http.routers.convertx.middlewares=convertx-auth"
```

### 3. Regular Security Updates

```bash
# Update ConvertX regularly
docker-compose pull && docker-compose up -d

# Update base system
sudo apt update && sudo apt upgrade -y
```

## Conclusion

ConvertX provides a robust, self-hosted solution for file conversion needs. With its extensive format support, privacy-focused design, and easy Docker deployment, it's an excellent choice for both personal and enterprise use.

The platform's strength lies in its combination of powerful conversion capabilities and user control. By hosting it yourself, you maintain complete privacy over your files while benefiting from professional-grade conversion tools.

Whether you're processing images for a website, converting documents for archival, or handling multimedia content, ConvertX offers the flexibility and reliability needed for modern file conversion workflows.

## Additional Resources

- **Official Repository**: [https://github.com/C4illin/ConvertX](https://github.com/C4illin/ConvertX)
- **Docker Hub**: [https://hub.docker.com/r/c4illin/convertx](https://hub.docker.com/r/c4illin/convertx)
- **GitHub Container Registry**: [https://ghcr.io/c4illin/convertx](https://ghcr.io/c4illin/convertx)
- **Issue Tracker**: [https://github.com/C4illin/ConvertX/issues](https://github.com/C4illin/ConvertX/issues)

---

*This tutorial covers the essential aspects of deploying and using ConvertX. For specific use cases or advanced configurations, refer to the official documentation or community discussions.*
