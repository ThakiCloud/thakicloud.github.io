---
title: "Helm Dashboard: Complete Guide to Kubernetes Helm Charts UI Management"
excerpt: "A comprehensive tutorial on Helm Dashboard - the missing UI for Helm that simplifies Kubernetes chart management with visual interface, revision history, and easy rollback capabilities."
seo_title: "Helm Dashboard Tutorial: Kubernetes Helm Charts UI Guide - Thaki Cloud"
seo_description: "Learn how to install and use Helm Dashboard for Kubernetes. Complete guide covering installation methods, chart management, rollback operations, and best practices for Helm UI."
date: 2025-10-10
categories:
  - tutorials
tags:
  - helm
  - kubernetes
  - helm-dashboard
  - k8s
  - devops
  - helm-plugin
author_profile: true
toc: true
toc_label: "Table of Contents"
lang: en
permalink: /en/tutorials/helm-dashboard-kubernetes-ui-complete-guide/
canonical_url: "https://thakicloud.github.io/en/tutorials/helm-dashboard-kubernetes-ui-complete-guide/"
---

⏱️ **Estimated Reading Time**: 12 minutes

## Introduction

Managing Helm charts in Kubernetes can be challenging when you're limited to command-line interfaces. **Helm Dashboard** is an open-source project that provides a user-friendly web interface for viewing installed Helm charts, examining revision history, and performing operations like rollbacks and upgrades with visual manifest diffs.

This comprehensive tutorial will guide you through installing Helm Dashboard, exploring its features, and leveraging it for efficient Kubernetes chart management.

### What is Helm Dashboard?

Helm Dashboard is an open-source tool developed by Komodor that offers a UI-driven approach to working with Helm charts. Unlike the traditional Helm CLI, it provides:

- **Visual chart management**: See all installed charts at a glance
- **Revision history**: Track changes across chart versions
- **Manifest diff viewer**: Compare configurations between revisions
- **Resource browsing**: Explore Kubernetes resources created by charts
- **Easy operations**: Perform rollbacks and upgrades with confidence
- **Multi-cluster support**: Switch between different Kubernetes clusters
- **Standalone operation**: Works without requiring Helm or kubectl installed

### Why Use Helm Dashboard?

Traditional Helm management requires remembering numerous CLI commands and piecing together information from multiple sources. Helm Dashboard solves this by:

1. **Reducing cognitive load**: Visual interface eliminates the need to memorize complex commands
2. **Improving visibility**: See the complete state of your Helm releases in one place
3. **Preventing mistakes**: Visual diff shows exactly what will change before applying updates
4. **Accelerating troubleshooting**: Quickly identify problematic revisions and roll back
5. **Enhancing collaboration**: Team members can explore charts without deep Helm expertise

## Prerequisites

Before starting this tutorial, ensure you have:

- **Kubernetes cluster**: A running cluster (minikube, kind, or production cluster)
- **Basic Kubernetes knowledge**: Understanding of pods, services, and deployments
- **macOS, Linux, or Windows**: Helm Dashboard supports all major platforms
- **Web browser**: Modern browser for accessing the dashboard UI

**Note**: Helm and kubectl are **NOT** required when using the standalone binary installation method.

## Installation Methods

Helm Dashboard offers three installation approaches, each suited for different use cases.

### Method 1: Standalone Binary (Recommended)

The standalone binary is the simplest and most flexible installation method. It doesn't require Helm or kubectl to be installed on your system.

#### Step 1: Download the Binary

Visit the [Helm Dashboard releases page](https://github.com/komodorio/helm-dashboard/releases) and download the appropriate package for your platform:

```bash
# For macOS (Apple Silicon)
curl -LO https://github.com/komodorio/helm-dashboard/releases/latest/download/helm-dashboard_Darwin_arm64.tar.gz
tar -xzf helm-dashboard_Darwin_arm64.tar.gz

# For macOS (Intel)
curl -LO https://github.com/komodorio/helm-dashboard/releases/latest/download/helm-dashboard_Darwin_x86_64.tar.gz
tar -xzf helm-dashboard_Darwin_x86_64.tar.gz

# For Linux (AMD64)
curl -LO https://github.com/komodorio/helm-dashboard/releases/latest/download/helm-dashboard_Linux_x86_64.tar.gz
tar -xzf helm-dashboard_Linux_x86_64.tar.gz
```

#### Step 2: Make it Executable and Run

```bash
chmod +x dashboard
./dashboard
```

The dashboard will start a web server on `http://localhost:8080` and automatically open your browser.

### Method 2: Helm Plugin Installation

If you already use Helm and prefer plugin-based tools, install Helm Dashboard as a Helm plugin.

#### Requirements
- Helm 3.4.0 or later
- kubectl configured with cluster access

#### Installation

```bash
# Install the plugin
helm plugin install https://github.com/komodorio/helm-dashboard.git

# Verify installation
helm plugin list
```

#### Usage

```bash
# Start the dashboard
helm dashboard

# Start with custom port
helm dashboard --port 9090

# Start without auto-opening browser
helm dashboard --no-browser

# Limit to specific namespace
helm dashboard --namespace production
```

#### Plugin Management

```bash
# Update the plugin
helm plugin update dashboard

# Uninstall the plugin
helm plugin uninstall dashboard
```

### Method 3: Deploy to Kubernetes Cluster

For team environments, deploy Helm Dashboard directly into your Kubernetes cluster using the official Helm chart.

```bash
# Add the Helm Dashboard repository
helm repo add komodorio https://helm-charts.komodor.io
helm repo update

# Install into your cluster
helm install helm-dashboard komodorio/helm-dashboard \
  --namespace helm-dashboard \
  --create-namespace

# Access via port-forward
kubectl port-forward -n helm-dashboard svc/helm-dashboard 8080:8080
```

Then navigate to `http://localhost:8080` in your browser.

## Testing the Installation

Let's verify that Helm Dashboard is working correctly by installing a sample chart and exploring it through the UI.

### Step 1: Create Test Script

```bash
#!/bin/bash
# File: test-helm-dashboard.sh

set -e

echo "🚀 Testing Helm Dashboard Installation..."

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed. Please install kubectl first."
    exit 1
fi

# Check cluster connectivity
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Cannot connect to Kubernetes cluster. Please configure kubectl."
    exit 1
fi

# Create test namespace
echo "📦 Creating test namespace..."
kubectl create namespace helm-dashboard-test --dry-run=client -o yaml | kubectl apply -f -

# Install a sample chart (nginx)
echo "📥 Installing sample nginx chart..."
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

helm install test-nginx bitnami/nginx \
  --namespace helm-dashboard-test \
  --set service.type=ClusterIP \
  --wait

# Verify installation
echo "✅ Verifying installation..."
helm list -n helm-dashboard-test

echo ""
echo "✨ Success! You can now:"
echo "1. Start Helm Dashboard: ./dashboard (or helm dashboard)"
echo "2. Navigate to: http://localhost:8080"
echo "3. Select 'helm-dashboard-test' namespace"
echo "4. View the 'test-nginx' release"
echo ""
echo "🧹 To cleanup: kubectl delete namespace helm-dashboard-test"
```

### Step 2: Run the Test

```bash
chmod +x test-helm-dashboard.sh
./test-helm-dashboard.sh
```

### Step 3: Explore the Dashboard

1. **Start Dashboard**: Run `./dashboard` or `helm dashboard`
2. **Open Browser**: Navigate to `http://localhost:8080`
3. **Select Namespace**: Choose `helm-dashboard-test` from the dropdown
4. **View Release**: Click on the `test-nginx` release

You should see detailed information about the nginx deployment, including:
- Chart version and app version
- Installation timestamp
- Current status
- List of Kubernetes resources created

## Core Features and Usage

### 1. Viewing Installed Charts

The main dashboard view displays all Helm releases across selected namespaces:

- **Release name**: The name you gave during installation
- **Namespace**: Where the chart is deployed
- **Chart version**: The version of the Helm chart
- **App version**: The version of the application being deployed
- **Status**: Current state (deployed, failed, pending-upgrade, etc.)
- **Updated**: Last modification timestamp

**Navigation Tips**:
- Use the namespace filter to focus on specific namespaces
- Click on any release to view detailed information
- Use the search box to quickly find releases by name

### 2. Examining Revision History

Every Helm release maintains a history of all revisions. To view revision history:

1. Click on a release name
2. Navigate to the **History** tab
3. Review the list of revisions showing:
   - Revision number
   - Updated timestamp
   - Status (superseded, deployed, failed)
   - Chart version
   - Description of changes

**Use Cases**:
- Track who made changes and when
- Understand the evolution of your deployment
- Identify when issues were introduced

### 3. Comparing Manifest Diffs

One of Helm Dashboard's most powerful features is the ability to compare manifests between revisions:

1. Open a release's history
2. Select two revisions to compare
3. Click **Diff** to see a side-by-side comparison
4. Review added (green), removed (red), and changed (yellow) lines

**Why This Matters**:
- Understand exactly what changed between versions
- Identify configuration issues
- Make informed rollback decisions
- Verify upgrade changes before applying

### 4. Browsing Kubernetes Resources

Helm Dashboard allows you to explore all Kubernetes resources created by a chart:

1. Click on a release
2. Navigate to the **Resources** tab
3. View categorized resources:
   - Workloads (Deployments, StatefulSets, DaemonSets)
   - Services and Ingresses
   - ConfigMaps and Secrets
   - PersistentVolumeClaims
   - Other custom resources

**Interactive Features**:
- Click on any resource to view its YAML definition
- Check resource status and health
- Identify resource relationships

### 5. Performing Rollbacks

When you need to revert to a previous version:

1. Open the release's history
2. Locate the revision you want to roll back to
3. Click the **Rollback** button
4. Review the manifest diff showing what will change
5. Confirm the rollback operation

**Best Practices**:
- Always review the diff before rolling back
- Document the reason for rollback
- Monitor the application after rollback
- Consider fixing forward instead of rolling back when possible

### 6. Upgrading Charts

To upgrade a chart to a newer version:

1. Click on a release
2. Click the **Upgrade** button
3. Select the new chart version
4. Modify values if needed
5. Review the manifest diff
6. Confirm and apply the upgrade

**Upgrade Workflow**:
```yaml
Current Version: nginx-15.0.0
Target Version: nginx-15.1.0

# Dashboard shows:
- What values will change
- What resources will be modified
- What resources will be added/removed
```

### 7. Multi-Cluster Management

Helm Dashboard can work with multiple Kubernetes clusters:

1. Ensure your kubeconfig includes multiple contexts
2. Use the cluster selector dropdown in the UI
3. Switch between clusters seamlessly

**Configuration Example**:
```bash
# List available contexts
kubectl config get-contexts

# Switch context via kubectl
kubectl config use-context production-cluster

# Dashboard will automatically detect the change
```

## Advanced Configuration

### Custom Port and Binding

By default, Helm Dashboard binds to `localhost:8080`. To customize:

```bash
# Using flag
./dashboard --port 9090 --bind=0.0.0.0

# Using environment variable
export HD_BIND=0.0.0.0
export HD_PORT=9090
./dashboard
```

**Security Warning**: Binding to `0.0.0.0` exposes the dashboard to all network interfaces. Only do this in secure environments.

### Namespace Filtering

Limit dashboard operations to specific namespaces:

```bash
# Single namespace
./dashboard --namespace production

# Multiple namespaces
./dashboard --namespace="production,staging,development"
```

### Verbose Logging

Enable detailed logging for troubleshooting:

```bash
./dashboard --verbose
```

This provides:
- HTTP request logs
- Helm operation details
- Error stack traces
- Performance metrics

### Disabling Analytics

Helm Dashboard collects anonymous usage analytics to improve the project. To disable:

```bash
./dashboard --no-analytics
```

### Browser Control

Prevent automatic browser opening:

```bash
./dashboard --no-browser
```

Then manually navigate to the displayed URL.

## Real-World Use Cases

### Use Case 1: Debugging Failed Deployments

**Scenario**: A chart upgrade failed and you need to understand why.

**Solution with Helm Dashboard**:
1. Open the release in dashboard
2. Check the **History** tab - you'll see a revision marked as "failed"
3. Compare the failed revision with the previous successful one using **Diff**
4. Identify the problematic configuration change
5. Rollback to the last working revision
6. Fix the issue and retry the upgrade

**Time Saved**: What took 15-20 minutes with CLI commands takes 2-3 minutes with visual comparison.

### Use Case 2: Onboarding New Team Members

**Scenario**: New developers need to understand the deployed applications.

**Solution with Helm Dashboard**:
1. Share the dashboard URL (if deployed in-cluster)
2. New team members can explore:
   - What applications are running
   - How they're configured
   - What resources they use
   - Their deployment history
3. No need to learn Helm CLI immediately

**Benefit**: Reduces onboarding time from days to hours.

### Use Case 3: Change Auditing

**Scenario**: You need to create an audit trail of infrastructure changes.

**Solution with Helm Dashboard**:
1. Use the **History** tab to review all changes
2. Export revision information
3. Compare manifests to see exact changes
4. Document who made changes and when

**Compliance**: Helps meet audit requirements for regulated industries.

### Use Case 4: Safe Production Deployments

**Scenario**: Upgrading a critical production service requires careful validation.

**Solution with Helm Dashboard**:
1. Test the upgrade in staging environment first
2. Use dashboard to compare staging vs production configurations
3. Review manifest diff for the production upgrade
4. Verify no unexpected changes
5. Proceed with confidence or abort if issues detected

**Risk Mitigation**: Prevents production incidents caused by configuration drift.

## Troubleshooting Common Issues

### Issue 1: Dashboard Won't Start

**Symptoms**: Error message when running `./dashboard`

**Solutions**:

```bash
# Check if port 8080 is already in use
lsof -i :8080

# Use a different port
./dashboard --port 8081

# Check Kubernetes connectivity
kubectl cluster-info

# Verify kubeconfig
kubectl config view
```

### Issue 2: No Releases Showing

**Symptoms**: Dashboard loads but shows no releases

**Possible Causes**:
1. Wrong namespace selected
2. No Helm releases installed
3. Insufficient RBAC permissions

**Solutions**:

```bash
# List all releases in all namespaces
helm list --all-namespaces

# Check current namespace context
kubectl config view --minify | grep namespace:

# Verify RBAC permissions
kubectl auth can-i list secrets
kubectl auth can-i get secrets
```

### Issue 3: Cannot Connect to Cluster

**Symptoms**: Error about Kubernetes connection failure

**Solutions**:

```bash
# Verify cluster is running
kubectl cluster-info

# Check kubeconfig path
echo $KUBECONFIG
ls -la ~/.kube/config

# Test connection
kubectl get nodes

# For minikube users
minikube status
minikube start
```

### Issue 4: Diff Not Showing

**Symptoms**: Manifest diff appears empty

**Possible Causes**:
1. Comparing identical revisions
2. Large manifests timing out
3. Browser caching issues

**Solutions**:
1. Refresh the browser page
2. Clear browser cache
3. Try a different browser
4. Check verbose logs for errors

## Security Considerations

### Access Control

Helm Dashboard inherits permissions from the kubeconfig it uses. To limit access:

1. **Service Account**: Create a dedicated service account with limited permissions
2. **RBAC**: Define specific roles for Helm Dashboard operations
3. **Namespace Isolation**: Use namespace-scoped service accounts

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: helm-dashboard-readonly
  namespace: helm-dashboard
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: helm-dashboard-readonly
rules:
- apiGroups: [""]
  resources: ["secrets", "configmaps"]
  verbs: ["get", "list"]
- apiGroups: [""]
  resources: ["pods", "services"]
  verbs: ["get", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: helm-dashboard-readonly
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: helm-dashboard-readonly
subjects:
- kind: ServiceAccount
  name: helm-dashboard-readonly
  namespace: helm-dashboard
```

### Network Security

When exposing Helm Dashboard:

1. **Local Only**: Default `localhost` binding is safest for single-user scenarios
2. **Internal Network**: Use `0.0.0.0` only within trusted networks
3. **Authentication**: Consider adding authentication proxy (OAuth2 Proxy, Pomerium)
4. **TLS**: Use TLS for any external exposure
5. **Firewall**: Restrict access to authorized IP ranges

### Secret Management

Helm Dashboard can view Kubernetes secrets that store Helm release data:

1. **Principle of Least Privilege**: Only grant necessary permissions
2. **Audit Logging**: Enable Kubernetes audit logs to track secret access
3. **Secret Encryption**: Ensure etcd encryption is enabled
4. **Regular Review**: Periodically review who has access

## Performance Optimization

### For Large Clusters

If you manage many Helm releases:

1. **Namespace Filtering**: Use `--namespace` to limit scope
2. **Resource Limits**: When deployed in-cluster, set appropriate resource limits
3. **Caching**: Helm Dashboard caches release data - adjust cache settings if needed

```yaml
# When deploying to cluster
resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 100m
    memory: 128Mi
```

### Browser Performance

For manifests with thousands of lines:

1. **Use Diff Selectively**: Only compare when necessary
2. **Close Unused Tabs**: Dashboard uses WebSocket connections
3. **Modern Browser**: Use latest Chrome/Firefox/Safari for best performance

## Integration with CI/CD

Helm Dashboard can complement your CI/CD pipeline:

### GitOps Workflow

```bash
# Deploy Helm Dashboard to cluster
helm install helm-dashboard komodorio/helm-dashboard

# Team uses dashboard to:
# 1. Monitor deployments triggered by ArgoCD/Flux
# 2. Verify changes match Git commits
# 3. Quickly rollback if issues detected
```

### Staging Validation

```bash
# In CI pipeline (example with GitHub Actions)
- name: Deploy to Staging
  run: helm upgrade --install myapp ./charts/myapp -n staging

- name: Verify with Dashboard
  run: |
    # Open dashboard for manual verification
    echo "Review deployment at: http://dashboard.staging.example.com"
    echo "Compare revisions and verify changes"
```

### Deployment Notifications

Combine with monitoring tools:

```bash
# After deployment
helm upgrade --install myapp ./charts/myapp

# Notify team with dashboard link
slack-notify "New deployment ready. Review: http://dashboard/myapp"
```

## Comparison with Alternatives

| Feature | Helm Dashboard | K9s | Lens | Rancher |
|---------|---------------|-----|------|---------|
| Helm-specific UI | ✅ | ❌ | Partial | ✅ |
| Revision diff | ✅ | ❌ | ❌ | ✅ |
| Standalone binary | ✅ | ✅ | ✅ | ❌ |
| Multi-cluster | ✅ | ✅ | ✅ | ✅ |
| Web-based | ✅ | ❌ | ❌ (Desktop) | ✅ |
| Open source | ✅ | ✅ | ✅ | ✅ |
| Learning curve | Low | Medium | Low | High |

**When to Use Helm Dashboard**:
- Primary focus is Helm release management
- Need visual manifest comparison
- Want web-based access
- Prefer lightweight solution

**When to Use Alternatives**:
- **K9s**: For terminal-based workflow, broader K8s management
- **Lens**: For comprehensive desktop IDE experience
- **Rancher**: For enterprise multi-cluster management with additional features

## Best Practices

### 1. Regular Updates

Keep Helm Dashboard updated:

```bash
# For plugin installation
helm plugin update dashboard

# For standalone binary
# Download latest release periodically
```

### 2. Document Your Releases

Use Helm's `--description` flag to document changes:

```bash
helm upgrade myapp ./charts/myapp \
  --description "Updated to v2.0.0 - Added new API endpoints"
```

This description appears in Dashboard's history view.

### 3. Use Semantic Versioning

Follow semantic versioning for your charts:

```yaml
# Chart.yaml
version: 2.1.0  # MAJOR.MINOR.PATCH
appVersion: 1.16.0
```

Dashboard's history becomes more meaningful with clear version progression.

### 4. Review Before Applying

Always use Dashboard's diff feature before:
- Upgrading to a new version
- Rolling back to a previous version
- Applying value changes

### 5. Combine with GitOps

Use Dashboard for monitoring and troubleshooting, while maintaining Git as source of truth:

```bash
# Git remains source of truth
git commit -m "Update myapp to v2.0.0"
git push

# ArgoCD/Flux applies changes
# Use Dashboard to monitor and verify
```

### 6. Namespace Strategy

Organize releases by environment using namespaces:

```bash
# Development
helm install myapp ./charts/myapp -n dev

# Staging
helm install myapp ./charts/myapp -n staging

# Production
helm install myapp ./charts/myapp -n production
```

Use Dashboard's namespace filter to switch between environments.

### 7. Backup Release Secrets

Helm stores release data in Kubernetes secrets. Back them up:

```bash
# Backup all Helm release secrets
kubectl get secrets -A -l owner=helm -o yaml > helm-releases-backup.yaml

# Restore if needed
kubectl apply -f helm-releases-backup.yaml
```

## Clean Up Test Resources

After completing this tutorial, clean up the test resources:

```bash
#!/bin/bash
# cleanup-helm-dashboard-test.sh

echo "🧹 Cleaning up Helm Dashboard test resources..."

# Uninstall test release
helm uninstall test-nginx -n helm-dashboard-test

# Delete test namespace
kubectl delete namespace helm-dashboard-test

# Remove downloaded binaries (optional)
# rm -f dashboard helm-dashboard_*.tar.gz

echo "✅ Cleanup complete!"
```

Run the cleanup script:

```bash
chmod +x cleanup-helm-dashboard-test.sh
./cleanup-helm-dashboard-test.sh
```

## Conclusion

Helm Dashboard bridges the gap between the powerful Helm CLI and the need for visual management tools. By providing an intuitive web interface, it makes Helm chart management accessible to both experts and newcomers.

### Key Takeaways

1. **Easy Installation**: Multiple installation methods suit different environments
2. **Visual Management**: See your Helm releases at a glance
3. **Safe Operations**: Diff feature prevents configuration mistakes
4. **Team Collaboration**: Lower barrier to entry for team members
5. **Troubleshooting**: Quickly identify and resolve deployment issues
6. **Production Ready**: Suitable for both development and production environments

### Next Steps

To continue your Helm Dashboard journey:

1. **Deploy to Your Cluster**: Move from local binary to in-cluster deployment
2. **Integrate with CI/CD**: Incorporate dashboard into your deployment workflow
3. **Explore Advanced Features**: Try integration with problem scanners
4. **Contribute**: Consider contributing to the [open-source project](https://github.com/komodorio/helm-dashboard)
5. **Join Community**: Connect with other users on Slack

### Additional Resources

- **Official Repository**: [https://github.com/komodorio/helm-dashboard](https://github.com/komodorio/helm-dashboard)
- **Helm Documentation**: [https://helm.sh/docs/](https://helm.sh/docs/)
- **Kubernetes Documentation**: [https://kubernetes.io/docs/](https://kubernetes.io/docs/)
- **Feature Overview**: [FEATURES.md](https://github.com/komodorio/helm-dashboard/blob/main/FEATURES.md)

Helm Dashboard demonstrates that powerful tools don't have to be complex. By making Helm more accessible, it helps teams manage Kubernetes applications more confidently and efficiently. Whether you're a solo developer or part of a large team, Helm Dashboard can improve your Kubernetes workflow.

Happy charting! 🚀

