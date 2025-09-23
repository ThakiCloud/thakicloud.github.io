---
title: "Kite Kubernetes Dashboard: Complete Setup and Management Tutorial"
excerpt: "Learn how to deploy and use Kite, a modern lightweight Kubernetes dashboard with multi-cluster support, real-time monitoring, and intuitive UI. Complete guide from installation to advanced features."
seo_title: "Kite Kubernetes Dashboard Tutorial - Modern K8s Management - Thaki Cloud"
seo_description: "Complete tutorial for Kite Kubernetes Dashboard: installation via Helm/kubectl, multi-cluster setup, resource management, monitoring with Prometheus, and security features."
date: 2025-09-21
categories:
  - tutorials
tags:
  - kubernetes
  - dashboard
  - monitoring
  - devops
  - cloud-native
author_profile: true
toc: true
toc_label: "Table of Contents"
lang: en
permalink: /en/tutorials/kite-kubernetes-dashboard-complete-tutorial/
canonical_url: "https://thakicloud.github.io/en/tutorials/kite-kubernetes-dashboard-complete-tutorial/"
---

⏱️ **Estimated Reading Time**: 12 minutes

## Introduction

Managing Kubernetes clusters through command-line tools can be challenging, especially when dealing with multiple clusters or complex deployments. **Kite** is a modern, lightweight Kubernetes dashboard that provides an intuitive web interface for cluster management and monitoring.

Unlike traditional Kubernetes dashboards, Kite offers:
- **Modern UI/UX** with dark/light themes
- **Multi-cluster management** capabilities
- **Real-time monitoring** with Prometheus integration
- **Comprehensive resource management** with live YAML editing
- **Security features** with OAuth and RBAC support

In this tutorial, we'll explore how to install, configure, and effectively use Kite for Kubernetes cluster management.

## What is Kite?

[Kite](https://github.com/zxh326/kite) is an open-source Kubernetes dashboard developed by [zxh326](https://github.com/zxh326). It's designed to be a modern alternative to the traditional Kubernetes dashboard, focusing on user experience and practical functionality.

### Key Features

#### 🎯 Modern User Experience
- **Multi-theme support**: Dark, light, and color themes with system preference detection
- **Advanced search**: Global search across all resources
- **Internationalization**: Support for English and Chinese languages
- **Responsive design**: Optimized for desktop, tablet, and mobile devices

#### 🏘️ Multi-Cluster Management
- **Seamless cluster switching**: Switch between multiple Kubernetes clusters
- **Per-cluster monitoring**: Independent Prometheus configuration for each cluster
- **Kubeconfig integration**: Automatic discovery of clusters from kubeconfig file
- **Cluster access control**: Fine-grained permissions for cluster access management

#### 🔍 Comprehensive Resource Management
- **Full resource coverage**: Pods, Deployments, Services, ConfigMaps, Secrets, PVs, PVCs, Nodes, and more
- **Live YAML editing**: Built-in Monaco editor with syntax highlighting and validation
- **Detailed resource views**: In-depth information with containers, volumes, events, and conditions
- **Resource relationships**: Visualize connections between related resources
- **Resource operations**: Create, update, delete, scale, and restart resources directly from the UI
- **Custom resources**: Full support for CRDs (Custom Resource Definitions)
- **Quick image tag selector**: Easily select and change container image tags

#### 📈 Monitoring & Observability
- **Real-time metrics**: CPU, memory, and network usage charts powered by Prometheus
- **Cluster overview**: Comprehensive cluster health and resource statistics
- **Live logs**: Stream pod logs in real-time with filtering and search capabilities
- **Web/Node terminal**: Execute commands directly in pods/nodes through the browser
- **Node monitoring**: Detailed node-level performance metrics and utilization
- **Pod monitoring**: Individual pod resource usage and performance tracking

#### 🔐 Security
- **OAuth integration**: Supports OAuth management in the UI
- **Role-based access control**: Supports user permission management in the UI
- **User management**: Comprehensive user management and role allocation in the UI

## Prerequisites

Before installing Kite, ensure you have:

1. **Kubernetes Cluster**: A running Kubernetes cluster (v1.19+)
2. **kubectl**: Configured and connected to your cluster
3. **Helm** (optional but recommended): Version 3.0+
4. **Prometheus** (optional): For monitoring features
5. **Cluster Admin Permissions**: Required for installation

### Verify Prerequisites

```bash
# Check kubectl connectivity
kubectl cluster-info

# Check Kubernetes version
kubectl version --short

# Check Helm installation (if using Helm)
helm version

# Verify cluster admin permissions
kubectl auth can-i '*' '*' --all-namespaces
```

## Installation Methods

Kite can be installed using several methods. We'll cover the most common approaches.

### Method 1: Helm Installation (Recommended)

Helm is the recommended installation method as it provides better configuration management and upgrade capabilities.

#### Step 1: Add Kite Helm Repository

```bash
# Add the official Kite Helm repository
helm repo add kite https://zxh326.github.io/kite

# Update Helm repositories
helm repo update

# Verify the repository was added
helm repo list | grep kite
```

#### Step 2: Install Kite with Default Configuration

```bash
# Install Kite in the kube-system namespace
helm install kite kite/kite -n kube-system

# Wait for deployment to complete
kubectl rollout status deployment/kite -n kube-system
```

#### Step 3: Verify Installation

```bash
# Check pod status
kubectl get pods -n kube-system -l app=kite

# Check service status
kubectl get services -n kube-system -l app=kite

# View Kite logs
kubectl logs -n kube-system -l app=kite
```

### Method 2: kubectl Installation

If you prefer not to use Helm, you can install Kite directly using kubectl.

#### Step 1: Apply Installation Manifest

```bash
# Install from GitHub (latest version)
kubectl apply -f https://raw.githubusercontent.com/zxh326/kite/refs/heads/main/deploy/install.yaml

# Or download and apply locally
curl -O https://raw.githubusercontent.com/zxh326/kite/refs/heads/main/deploy/install.yaml
kubectl apply -f install.yaml
```

#### Step 2: Verify Installation

```bash
# Check deployment status
kubectl get deployment kite -n kube-system

# Check pod status
kubectl get pods -n kube-system -l app=kite
```

### Method 3: Docker (Development/Testing)

For development or testing purposes, you can run Kite using Docker.

```bash
# Run Kite with Docker
docker run --rm -p 8080:8080 ghcr.io/zxh326/kite:latest

# With custom kubeconfig
docker run --rm -p 8080:8080 \
  -v ~/.kube/config:/app/.kube/config:ro \
  ghcr.io/zxh326/kite:latest
```

## Accessing Kite Dashboard

### Port Forwarding (Quick Access)

The simplest way to access Kite is through port forwarding:

```bash
# Forward local port 8080 to Kite service
kubectl port-forward -n kube-system svc/kite 8080:8080

# Access the dashboard
open http://localhost:8080
```

### LoadBalancer Service (Cloud Environments)

For cloud deployments, you can expose Kite using a LoadBalancer:

```bash
# Patch service to LoadBalancer type
kubectl patch svc kite -n kube-system -p '{"spec": {"type": "LoadBalancer"}}'

# Get external IP
kubectl get svc kite -n kube-system
```

### Ingress Configuration (Production)

For production deployments, configure an Ingress:

```yaml
# kite-ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: kite-ingress
  namespace: kube-system
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
spec:
  rules:
  - host: kite.yourdomain.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: kite
            port:
              number: 8080
  tls:
  - hosts:
    - kite.yourdomain.com
    secretName: kite-tls
```

```bash
# Apply Ingress configuration
kubectl apply -f kite-ingress.yaml
```

## Configuration

### Basic Configuration

Kite can be configured through environment variables or configuration files. Here are the key configuration options:

```yaml
# values.yaml for Helm deployment
config:
  # Server configuration
  port: 8080
  
  # Kubernetes configuration
  kubeconfig: ""  # Path to kubeconfig file
  
  # Multi-cluster support
  clusters:
    - name: "production"
      kubeconfig: "/configs/prod-kubeconfig"
    - name: "staging"
      kubeconfig: "/configs/staging-kubeconfig"
  
  # Prometheus configuration
  prometheus:
    enabled: true
    endpoint: "http://prometheus-server.monitoring.svc.cluster.local:80"
  
  # Security configuration
  auth:
    enabled: false
    oauth:
      provider: "github"
      clientId: "your-client-id"
      clientSecret: "your-client-secret"
```

### Advanced Helm Configuration

```bash
# Install with custom values
helm install kite kite/kite -n kube-system \
  --set config.prometheus.enabled=true \
  --set config.prometheus.endpoint="http://prometheus:9090" \
  --set config.auth.enabled=true

# Or use a values file
helm install kite kite/kite -n kube-system -f custom-values.yaml
```

### Environment Variables

When running with Docker or custom deployments:

```bash
# Basic configuration
export KITE_PORT=8080
export KITE_KUBECONFIG=/path/to/kubeconfig

# Prometheus integration
export KITE_PROMETHEUS_ENABLED=true
export KITE_PROMETHEUS_ENDPOINT=http://prometheus:9090

# Authentication
export KITE_AUTH_ENABLED=true
export KITE_OAUTH_PROVIDER=github
export KITE_OAUTH_CLIENT_ID=your-client-id
export KITE_OAUTH_CLIENT_SECRET=your-client-secret
```

## Using Kite Dashboard

### Dashboard Overview

When you first access Kite, you'll see the main dashboard with:

1. **Cluster Overview**: Real-time cluster statistics and health
2. **Resource Summary**: Quick counts of pods, services, deployments, etc.
3. **Node Status**: Node health and resource utilization
4. **Recent Events**: Latest cluster events and activities

### Navigation and Interface

#### Top Navigation Bar
- **Cluster Selector**: Switch between multiple clusters
- **Search**: Global search across all resources
- **Theme Toggle**: Switch between dark/light themes
- **User Menu**: Authentication and user settings

#### Sidebar Navigation
- **Workloads**: Deployments, ReplicaSets, Pods, Jobs, etc.
- **Services**: Services, Ingresses, NetworkPolicies
- **Storage**: PersistentVolumes, PersistentVolumeClaims, StorageClasses
- **Config**: ConfigMaps, Secrets
- **RBAC**: ServiceAccounts, Roles, RoleBindings
- **Cluster**: Nodes, Namespaces, Events

### Resource Management

#### Viewing Resources

1. **List View**: Navigate to any resource type to see a comprehensive list
2. **Detail View**: Click on any resource to see detailed information
3. **YAML View**: View and edit raw YAML configurations
4. **Relationships**: See related resources and dependencies

#### Creating Resources

```yaml
# Example: Creating a deployment through Kite
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  namespace: default
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
        ports:
        - containerPort: 80
```

1. Navigate to **Workloads > Deployments**
2. Click **Create** button
3. Use the built-in Monaco editor to write YAML
4. Click **Apply** to create the resource

#### Editing Resources

1. Click on any resource to open details
2. Click **Edit** or **YAML** tab
3. Modify the configuration in the Monaco editor
4. Click **Apply** to save changes

#### Scaling and Operations

- **Scale Deployments**: Use the scale button or edit replicas directly
- **Restart Deployments**: Restart all pods in a deployment
- **Delete Resources**: Remove resources with confirmation
- **View Logs**: Stream logs from pods in real-time
- **Execute Commands**: Use the built-in terminal for pods

### Multi-Cluster Management

#### Adding Clusters

1. **Automatic Discovery**: Kite can automatically discover clusters from your kubeconfig
2. **Manual Configuration**: Add clusters through configuration files
3. **Dynamic Addition**: Add clusters through the UI (if authentication is enabled)

#### Switching Clusters

Use the cluster selector in the top navigation to switch between clusters. Each cluster maintains its own:
- Resource state
- Monitoring configuration
- User permissions
- Settings

### Monitoring and Observability

#### Real-Time Metrics

With Prometheus integration, Kite provides:

1. **Cluster Metrics**:
   - CPU and memory utilization
   - Pod and node counts
   - Resource allocation and usage

2. **Node Metrics**:
   - Individual node performance
   - Resource usage over time
   - Node conditions and events

3. **Pod Metrics**:
   - Container resource usage
   - Performance trends
   - Health status

#### Log Streaming

1. Navigate to any pod
2. Click **Logs** tab
3. Stream logs in real-time with:
   - Multiple container support
   - Search and filtering
   - Download capabilities
   - Auto-refresh options

#### Terminal Access

1. Navigate to any pod
2. Click **Terminal** tab
3. Execute commands directly in containers:
   - Multiple container support
   - Full terminal emulation
   - File upload/download
   - Session management

## Prometheus Integration

### Installing Prometheus

If you don't have Prometheus installed, you can deploy it using Helm:

```bash
# Add Prometheus Helm repository
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Install Prometheus
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false
```

### Configuring Kite with Prometheus

Update your Kite configuration to include Prometheus:

```yaml
# values.yaml
config:
  prometheus:
    enabled: true
    endpoint: "http://prometheus-kube-prometheus-prometheus.monitoring.svc.cluster.local:9090"
```

Upgrade your Kite installation:

```bash
helm upgrade kite kite/kite -n kube-system -f values.yaml
```

### Verifying Metrics

1. Access Kite dashboard
2. Navigate to **Cluster Overview**
3. Verify that metrics charts are displaying data
4. Check individual node and pod metrics

## Security Configuration

### Authentication Setup

#### OAuth Configuration

Kite supports OAuth authentication with various providers:

```yaml
# values.yaml
config:
  auth:
    enabled: true
    oauth:
      provider: "github"  # or "google", "gitlab"
      clientId: "your-github-client-id"
      clientSecret: "your-github-client-secret"
      redirectUrl: "http://kite.yourdomain.com/auth/callback"
```

#### Creating GitHub OAuth App

1. Go to GitHub Settings > Developer settings > OAuth Apps
2. Click "New OAuth App"
3. Fill in application details:
   - **Application name**: Kite Dashboard
   - **Homepage URL**: http://kite.yourdomain.com
   - **Authorization callback URL**: http://kite.yourdomain.com/auth/callback
4. Note the Client ID and Client Secret

### RBAC Configuration

Create appropriate RBAC rules for Kite:

```yaml
# kite-rbac.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: kite
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: kite
rules:
- apiGroups: ["*"]
  resources: ["*"]
  verbs: ["*"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: kite
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: kite
subjects:
- kind: ServiceAccount
  name: kite
  namespace: kube-system
```

```bash
# Apply RBAC configuration
kubectl apply -f kite-rbac.yaml
```

### User Management

When authentication is enabled, you can:

1. **Manage Users**: Add/remove users through the UI
2. **Assign Roles**: Map users to Kubernetes RBAC roles
3. **Audit Access**: Track user activities and permissions
4. **Session Management**: Control session timeouts and policies

## Troubleshooting

### Common Issues

#### 1. Pod Not Starting

```bash
# Check pod status
kubectl get pods -n kube-system -l app=kite

# Check pod logs
kubectl logs -n kube-system -l app=kite

# Check events
kubectl get events -n kube-system --sort-by=.metadata.creationTimestamp
```

Common solutions:
- Verify RBAC permissions
- Check resource limits
- Ensure proper kubeconfig configuration

#### 2. Metrics Not Displaying

```bash
# Verify Prometheus connectivity
kubectl exec -n kube-system deployment/kite -- wget -qO- http://prometheus-endpoint:9090/api/v1/query?query=up

# Check Prometheus service
kubectl get svc -n monitoring
```

Solutions:
- Verify Prometheus endpoint configuration
- Check network policies
- Ensure Prometheus is collecting Kubernetes metrics

#### 3. Authentication Issues

Check OAuth configuration:
- Verify client ID and secret
- Confirm redirect URLs
- Check provider-specific settings

#### 4. Multi-Cluster Issues

```bash
# Verify kubeconfig files
kubectl config get-contexts

# Test cluster connectivity
kubectl cluster-info --context=cluster-name
```

### Debug Mode

Enable debug logging for troubleshooting:

```yaml
# values.yaml
config:
  debug: true
  logLevel: "debug"
```

### Health Checks

Kite provides health check endpoints:

```bash
# Health check
curl http://localhost:8080/health

# Readiness check
curl http://localhost:8080/ready

# Metrics endpoint
curl http://localhost:8080/metrics
```

## Advanced Features

### Custom Resource Definitions (CRDs)

Kite automatically supports any CRDs in your cluster:

1. **Automatic Discovery**: CRDs are automatically detected and listed
2. **Full CRUD Operations**: Create, read, update, and delete custom resources
3. **YAML Editing**: Edit custom resources with syntax highlighting
4. **Status Tracking**: Monitor custom resource status and conditions

### Image Tag Management

Kite provides an intuitive interface for managing container images:

1. **Tag Selection**: Browse available tags from container registries
2. **Quick Updates**: Update deployment images with a few clicks
3. **Rollback Support**: Easy rollback to previous image versions
4. **Registry Integration**: Support for Docker Hub, ECR, GCR, and private registries

### Bulk Operations

Perform operations on multiple resources:

1. **Multi-Select**: Select multiple resources in list views
2. **Bulk Delete**: Remove multiple resources at once
3. **Bulk Label**: Add/remove labels from multiple resources
4. **Bulk Scale**: Scale multiple deployments simultaneously

### Resource Templates

Create and use templates for common resources:

1. **Save Templates**: Save frequently used resource configurations
2. **Template Library**: Build a library of organizational templates
3. **Quick Deploy**: Deploy resources from templates with minimal changes
4. **Parameter Substitution**: Use variables in templates for flexibility

## Best Practices

### Security Best Practices

1. **Use RBAC**: Implement proper role-based access control
2. **Enable Authentication**: Use OAuth for user authentication
3. **Network Policies**: Restrict network access to Kite
4. **TLS Encryption**: Use HTTPS with proper certificates
5. **Regular Updates**: Keep Kite updated to the latest version

### Performance Optimization

1. **Resource Limits**: Set appropriate CPU and memory limits
2. **Prometheus Tuning**: Optimize Prometheus queries and retention
3. **Network Optimization**: Use local Prometheus when possible
4. **Caching**: Enable appropriate caching for better performance

### Operational Guidelines

1. **Backup Configurations**: Backup Kite and cluster configurations
2. **Monitoring**: Monitor Kite's own health and performance
3. **Log Management**: Implement proper log rotation and retention
4. **Documentation**: Document cluster-specific configurations and procedures

## Conclusion

Kite provides a modern, intuitive interface for Kubernetes cluster management that significantly improves the developer and operator experience. With its comprehensive feature set including multi-cluster support, real-time monitoring, and advanced security options, it serves as an excellent alternative to traditional Kubernetes dashboards.

Key takeaways:

1. **Easy Installation**: Multiple installation methods support various deployment scenarios
2. **Rich Feature Set**: Comprehensive resource management with modern UI/UX
3. **Multi-Cluster Support**: Seamless management of multiple Kubernetes clusters
4. **Monitoring Integration**: Real-time metrics and observability with Prometheus
5. **Security Focus**: Built-in authentication and RBAC support
6. **Active Development**: Regular updates and community support

Whether you're managing a single development cluster or multiple production environments, Kite provides the tools and interface needed for effective Kubernetes operations.

## Additional Resources

- **Official Documentation**: [Kite Documentation](https://github.com/zxh326/kite/tree/main/docs)
- **GitHub Repository**: [https://github.com/zxh326/kite](https://github.com/zxh326/kite)
- **Live Demo**: [kite.zzde.me](https://kite.zzde.me/)
- **Helm Charts**: [Kite Helm Repository](https://zxh326.github.io/kite)
- **Issue Tracking**: [GitHub Issues](https://github.com/zxh326/kite/issues)

Have questions or feedback about this tutorial? Feel free to reach out or contribute to the Kite project on GitHub!
