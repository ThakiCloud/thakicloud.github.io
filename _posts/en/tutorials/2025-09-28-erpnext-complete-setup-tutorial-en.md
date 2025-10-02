---
title: "ERPNext Complete Setup and Usage Tutorial: Open Source ERP System Guide"
excerpt: "Complete guide to setting up and using ERPNext, a powerful open-source ERP system. Learn installation, configuration, and key features for business management."
seo_title: "ERPNext Tutorial: Complete Setup Guide for Open Source ERP - Thaki Cloud"
seo_description: "Learn how to install, configure, and use ERPNext - a free open-source ERP system. Complete tutorial covering Docker setup, basic configuration, and business features."
date: 2025-09-28
categories:
  - tutorials
tags:
  - ERPNext
  - ERP
  - Open Source
  - Business Management
  - Docker
  - Frappe Framework
author_profile: true
toc: true
toc_label: "Table of Contents"
lang: en
permalink: /en/tutorials/erpnext-complete-setup-tutorial/
canonical_url: "https://thakicloud.github.io/en/tutorials/erpnext-complete-setup-tutorial/"
---

⏱️ **Estimated Reading Time**: 15 minutes

## Introduction

ERPNext is a powerful, intuitive, and completely open-source Enterprise Resource Planning (ERP) system that helps businesses manage their operations efficiently. Built on the Frappe Framework, ERPNext provides comprehensive solutions for accounting, inventory management, manufacturing, project management, and much more - all for free.

In this comprehensive tutorial, we'll walk through the complete process of setting up ERPNext, from installation to basic configuration and usage. Whether you're a small business owner or an enterprise looking for a cost-effective ERP solution, this guide will help you get started with ERPNext.

## What is ERPNext?

ERPNext is a 100% open-source ERP system developed by Frappe Technologies. It's designed to help businesses run their operations more efficiently by providing integrated solutions for various business processes.

### Key Features

**Accounting & Finance**
- Complete accounting suite with general ledger, accounts payable/receivable
- Financial reporting and analysis tools
- Multi-currency support
- Tax management and compliance

**Inventory & Order Management**
- Real-time inventory tracking
- Purchase and sales order management
- Supplier and customer relationship management
- Warehouse management with multiple locations

**Manufacturing**
- Bill of Materials (BOM) management
- Production planning and scheduling
- Work order tracking
- Subcontracting management

**Project Management**
- Task and milestone tracking
- Timesheet management
- Project profitability analysis
- Issue tracking and resolution

**Human Resources**
- Employee management and payroll
- Leave and attendance tracking
- Performance management
- Recruitment and onboarding

## Prerequisites

Before we begin the installation, make sure you have the following prerequisites:

### System Requirements
- **Operating System**: Linux (Ubuntu 18.04+), macOS, or Windows with WSL2
- **RAM**: Minimum 4GB (8GB recommended)
- **Storage**: At least 10GB free space
- **Network**: Stable internet connection

### Required Software
- Docker and Docker Compose
- Git
- Web browser (Chrome, Firefox, Safari, or Edge)

## Installation Methods

ERPNext can be installed in several ways. We'll cover the most popular methods:

### Method 1: Docker Installation (Recommended)

Docker installation is the easiest and most reliable method for getting started with ERPNext.

#### Step 1: Install Docker and Docker Compose

**On Ubuntu/Debian:**
```bash
# Update package index
sudo apt update

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Add user to docker group
sudo usermod -aG docker $USER
```

**On macOS:**
```bash
# Install Docker Desktop from https://docker.com/products/docker-desktop
# Or using Homebrew
brew install --cask docker
```

#### Step 2: Clone ERPNext Docker Repository

```bash
# Clone the official ERPNext Docker repository
git clone https://github.com/frappe/frappe_docker
cd frappe_docker

# Create environment file
cp example.env .env
```

#### Step 3: Configure Environment Variables

Edit the `.env` file to customize your installation:

```bash
# Edit environment file
nano .env
```

Key configurations to modify:
```env
# Site configuration
SITES=erpnext.localhost
ERPNEXT_SITE_NAME=erpnext.localhost

# Database configuration
DB_PASSWORD=your_secure_password
MYSQL_ROOT_PASSWORD=your_root_password

# Administrator password
ADMIN_PASSWORD=your_admin_password
```

#### Step 4: Start ERPNext Services

```bash
# Start ERPNext with Docker Compose
docker compose -f pwd.yml up -d

# Check if services are running
docker compose -f pwd.yml ps
```

#### Step 5: Access ERPNext

After a few minutes, ERPNext should be accessible at:
- **URL**: `http://localhost:8080`
- **Username**: `Administrator`
- **Password**: `admin` (or the password you set in .env)

### Method 2: Manual Installation with Bench

For development or custom setups, you can install ERPNext manually using the Bench tool.

#### Step 1: Install System Dependencies

**On Ubuntu/Debian:**
```bash
# Install system dependencies
sudo apt update
sudo apt install -y python3-dev python3-pip python3-venv
sudo apt install -y software-properties-common
sudo apt install -y mariadb-server mariadb-client
sudo apt install -y redis-server
sudo apt install -y curl
sudo apt install -y nodejs npm
```

#### Step 2: Install Bench

```bash
# Install Bench CLI
pip3 install frappe-bench

# Create a new bench directory
bench init frappe-bench --frappe-branch version-14
cd frappe-bench

# Start bench services
bench start
```

#### Step 3: Create New Site and Install ERPNext

```bash
# Create a new site
bench new-site erpnext.localhost

# Get ERPNext app
bench get-app https://github.com/frappe/erpnext

# Install ERPNext on the site
bench --site erpnext.localhost install-app erpnext

# Set site as default
bench use erpnext.localhost
```

## Initial Configuration

Once ERPNext is installed and running, you'll need to complete the initial setup wizard.

### Setup Wizard Steps

#### Step 1: Language and Region
- Select your preferred language
- Choose your country and timezone
- Set currency and date format

#### Step 2: Company Information
```
Company Name: Your Company Name
Company Abbreviation: YCN
Default Currency: USD (or your local currency)
Country: Your Country
Timezone: Your Timezone
```

#### Step 3: User Information
- Create your administrator account
- Set up your profile information
- Configure email settings

#### Step 4: Business Domain
Select the domains relevant to your business:
- Manufacturing
- Distribution
- Retail
- Services
- Non Profit
- Education

#### Step 5: Chart of Accounts
- Choose a standard chart of accounts template
- Or create a custom chart based on your needs

## Core Modules Overview

Let's explore the main modules in ERPNext and their basic usage:

### 1. Accounting Module

The Accounting module is the heart of ERPNext's financial management.

**Key Features:**
- Chart of Accounts management
- Journal entries and vouchers
- Accounts payable and receivable
- Financial reports and analytics

**Basic Usage:**
```
Navigate to: Accounting > Chart of Accounts
- Create account heads for your business
- Set up tax templates
- Configure payment terms
```

### 2. Selling Module

Manage your sales process from lead to payment.

**Key Components:**
- Customer management
- Sales orders and invoices
- Quotations and proposals
- Sales analytics

**Creating a Sales Order:**
1. Go to `Selling > Sales Order > New`
2. Select customer or create new
3. Add items with quantities and rates
4. Set delivery date and terms
5. Submit the order

### 3. Buying Module

Streamline your procurement process.

**Features:**
- Supplier management
- Purchase orders and receipts
- Purchase invoices
- Supplier analytics

**Creating a Purchase Order:**
1. Navigate to `Buying > Purchase Order > New`
2. Select supplier
3. Add items to purchase
4. Set delivery schedule
5. Submit for approval

### 4. Stock Module

Comprehensive inventory management system.

**Capabilities:**
- Multi-warehouse inventory tracking
- Stock movements and transfers
- Serial and batch number tracking
- Inventory valuation

**Stock Entry Process:**
1. Go to `Stock > Stock Entry > New`
2. Select entry type (Material Receipt, Transfer, etc.)
3. Choose source and target warehouses
4. Add items with quantities
5. Submit the entry

### 5. Manufacturing Module

Plan and track your production processes.

**Components:**
- Bill of Materials (BOM)
- Work orders
- Production planning
- Job cards

**Creating a BOM:**
1. Navigate to `Manufacturing > BOM > New`
2. Select the item to manufacture
3. Add raw materials with quantities
4. Set operations and workstations
5. Calculate costs and save

## Advanced Configuration

### Email Configuration

Set up email integration for automated notifications:

```
Settings > Email Domain
- Configure SMTP settings
- Set up email accounts
- Create email templates
```

**SMTP Configuration Example:**
```
Email Server: smtp.gmail.com
Port: 587
Use TLS: Yes
Username: your-email@gmail.com
Password: your-app-password
```

### Print Formats

Customize your business documents:

```
Settings > Print Settings
- Create custom letterheads
- Design invoice templates
- Set up print formats for different documents
```

### Custom Fields

Add custom fields to existing doctypes:

```
Settings > Customize Form
- Select the doctype to customize
- Add custom fields
- Set field properties and permissions
```

### Workflow Configuration

Set up approval workflows:

```
Settings > Workflow
- Create workflow states
- Define transitions and conditions
- Assign roles and permissions
```

## User Management and Permissions

### Creating Users

1. Go to `Settings > User > New`
2. Enter user details and email
3. Assign roles and permissions
4. Set up user preferences

### Role-Based Permissions

ERPNext uses a comprehensive role-based permission system:

**Standard Roles:**
- System Manager: Full system access
- Accounts Manager: Financial operations
- Sales Manager: Sales operations
- Purchase Manager: Procurement operations
- Stock Manager: Inventory operations

**Setting Permissions:**
```
Settings > Role Permissions Manager
- Select doctype and role
- Set read, write, create, delete permissions
- Configure field-level permissions
```

## Reporting and Analytics

ERPNext provides powerful reporting capabilities:

### Standard Reports

Access pre-built reports:
```
Accounts > Reports
- Profit and Loss Statement
- Balance Sheet
- Cash Flow Statement
- Accounts Receivable Summary
```

### Custom Reports

Create custom reports using Report Builder:
```
Settings > Report Builder
- Select source doctype
- Choose fields and filters
- Set grouping and sorting
- Save and share reports
```

### Dashboard Analytics

Monitor key metrics with dashboards:
```
Home > Dashboard
- View key performance indicators
- Track sales and purchase trends
- Monitor inventory levels
- Analyze financial performance
```

## Mobile Access

ERPNext provides mobile access through:

### Web Mobile Interface
- Responsive web interface
- Touch-friendly navigation
- Offline capability for basic operations

### ERPNext Mobile App
- Available for iOS and Android
- Real-time synchronization
- Push notifications for important updates

## Backup and Maintenance

### Automated Backups

Set up regular backups:
```bash
# For Docker installation
docker compose exec backend bench --site erpnext.localhost backup

# For manual installation
bench --site erpnext.localhost backup
```

### System Maintenance

Regular maintenance tasks:
- Update ERPNext to latest version
- Monitor system performance
- Clean up old files and logs
- Review user access and permissions

### Update Process

**Docker Installation:**
```bash
# Pull latest images
docker compose pull

# Restart services
docker compose down
docker compose up -d
```

**Manual Installation:**
```bash
# Update bench and apps
bench update

# Migrate site
bench --site erpnext.localhost migrate
```

## Troubleshooting Common Issues

### Installation Issues

**Docker Container Won't Start:**
```bash
# Check container logs
docker compose logs

# Restart services
docker compose restart

# Check system resources
docker system df
```

**Database Connection Issues:**
- Verify database credentials in configuration
- Check if MariaDB service is running
- Ensure proper network connectivity

### Performance Issues

**Slow Loading Times:**
- Check system resources (RAM, CPU)
- Optimize database queries
- Enable caching
- Review custom scripts and customizations

**High Memory Usage:**
- Monitor background jobs
- Optimize large reports
- Clean up old logs and files

### Access Issues

**Login Problems:**
- Reset password using bench command
- Check user permissions and roles
- Verify email configuration

**Permission Errors:**
- Review role assignments
- Check doctype permissions
- Verify user group memberships

## Best Practices

### Data Management
1. **Regular Backups**: Set up automated daily backups
2. **Data Validation**: Use validation rules to ensure data quality
3. **Naming Conventions**: Establish consistent naming standards
4. **Archive Old Data**: Regularly archive historical records

### Security
1. **Strong Passwords**: Enforce strong password policies
2. **Two-Factor Authentication**: Enable 2FA for admin users
3. **Regular Updates**: Keep ERPNext updated to latest version
4. **Access Control**: Implement principle of least privilege

### Performance Optimization
1. **Database Indexing**: Optimize database queries with proper indexes
2. **Caching**: Enable Redis caching for better performance
3. **Resource Monitoring**: Monitor system resources regularly
4. **Custom Scripts**: Optimize custom Python and JavaScript code

## Integration Capabilities

ERPNext can integrate with various third-party services:

### E-commerce Integration
- Shopify connector
- WooCommerce integration
- Magento synchronization

### Payment Gateways
- PayPal integration
- Stripe payment processing
- Razorpay for Indian businesses

### Communication Tools
- WhatsApp Business API
- Slack notifications
- Email marketing platforms

### Accounting Software
- QuickBooks migration
- Tally data import
- Excel/CSV data import

## Conclusion

ERPNext is a comprehensive, feature-rich ERP solution that can significantly improve your business operations. Its open-source nature, combined with powerful features and flexibility, makes it an excellent choice for businesses of all sizes.

Key takeaways from this tutorial:

1. **Easy Installation**: Docker-based setup makes installation straightforward
2. **Comprehensive Features**: Covers all major business processes
3. **Customizable**: Highly flexible and customizable to fit specific needs
4. **Cost-Effective**: Free and open-source with no licensing fees
5. **Active Community**: Strong community support and regular updates

### Next Steps

After completing this tutorial, consider:

1. **Explore Advanced Features**: Dive deeper into manufacturing, project management, or HR modules
2. **Customize for Your Business**: Add custom fields, workflows, and reports
3. **Train Your Team**: Provide comprehensive training to your staff
4. **Join the Community**: Participate in ERPNext forums and discussions
5. **Consider Professional Support**: Explore Frappe Cloud for managed hosting

### Resources for Further Learning

- **Official Documentation**: [https://docs.erpnext.com](https://docs.erpnext.com)
- **Frappe School**: [https://frappe.school](https://frappe.school)
- **Community Forum**: [https://discuss.erpnext.com](https://discuss.erpnext.com)
- **GitHub Repository**: [https://github.com/frappe/erpnext](https://github.com/frappe/erpnext)
- **YouTube Channel**: ERPNext official tutorials

ERPNext's journey from a simple accounting tool to a comprehensive ERP system demonstrates the power of open-source development. With its continuous evolution and growing community, ERPNext is well-positioned to meet the changing needs of modern businesses.

Start your ERPNext journey today and experience the benefits of a truly integrated business management system!


