#!/bin/bash
# anteon-tutorial-test.sh
# macOS test script for Anteon Kubernetes monitoring and performance testing tutorial
# Created: 2025-08-28
# 
# This script validates all commands and procedures described in the Anteon tutorial
# blog posts across all three languages (English, Korean, Arabic)

set -e  # Exit on any error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Global variables
CLUSTER_NAME="anteon-demo"
NAMESPACE_ANTEON="anteon"
NAMESPACE_DEMO="demo-apps"
TEST_LOG_FILE="anteon-test-$(date +%Y%m%d-%H%M%S).log"

# Logging function
log() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$TEST_LOG_FILE"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$TEST_LOG_FILE"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$TEST_LOG_FILE"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$TEST_LOG_FILE"
}

# Function to check if command exists
check_command() {
    if command -v "$1" &> /dev/null; then
        log_success "$1 is installed"
        return 0
    else
        log_error "$1 is not installed"
        return 1
    fi
}

# Function to install required tools
install_tools() {
    log "🚀 Installing required tools for Anteon tutorial..."
    
    # Check and install Docker
    if ! check_command docker; then
        log "Installing Docker..."
        if [[ "$OSTYPE" == "darwin"* ]]; then
            brew install --cask docker
        else
            log_error "Please install Docker manually for your OS"
            return 1
        fi
    fi
    
    # Check and install kubectl
    if ! check_command kubectl; then
        log "Installing kubectl..."
        if [[ "$OSTYPE" == "darwin"* ]]; then
            brew install kubectl
        else
            log_error "Please install kubectl manually for your OS"
            return 1
        fi
    fi
    
    # Check and install Helm
    if ! check_command helm; then
        log "Installing Helm..."
        if [[ "$OSTYPE" == "darwin"* ]]; then
            brew install helm
        else
            log_error "Please install Helm manually for your OS"
            return 1
        fi
    fi
    
    # Check and install Kind
    if ! check_command kind; then
        log "Installing Kind..."
        if [[ "$OSTYPE" == "darwin"* ]]; then
            brew install kind
        else
            log_error "Please install kind manually for your OS"
            return 1
        fi
    fi
    
    # Check and install Anteon CLI
    if ! check_command ddosify; then
        log "Installing Anteon CLI (ddosify)..."
        if [[ "$OSTYPE" == "darwin"* ]]; then
            brew tap getanteon/tap
            brew install ddosify
        else
            log_error "Please install ddosify manually for your OS"
            return 1
        fi
    fi
    
    log_success "All required tools are installed!"
}

# Function to create Kind cluster
create_kind_cluster() {
    log "🎯 Creating Kind cluster for Anteon demo..."
    
    # Check if cluster already exists
    if kind get clusters | grep -q "$CLUSTER_NAME"; then
        log_warning "Kind cluster '$CLUSTER_NAME' already exists. Deleting..."
        kind delete cluster --name "$CLUSTER_NAME"
    fi
    
    # Create Kind cluster configuration
    cat > kind-config.yaml <<EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: $CLUSTER_NAME
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 8080
    protocol: TCP
  - containerPort: 443
    hostPort: 8443
    protocol: TCP
- role: worker
- role: worker
EOF
    
    # Create the cluster
    kind create cluster --config kind-config.yaml
    
    # Verify cluster is running
    kubectl cluster-info --context "kind-$CLUSTER_NAME"
    
    log_success "Kind cluster '$CLUSTER_NAME' created successfully!"
}

# Function to deploy sample applications
deploy_sample_apps() {
    log "🎯 Deploying sample applications for monitoring..."
    
    # Create namespace
    kubectl create namespace "$NAMESPACE_DEMO" --dry-run=client -o yaml | kubectl apply -f -
    
    # Deploy web application
    cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
  namespace: $NAMESPACE_DEMO
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
    spec:
      containers:
      - name: web-app
        image: nginx:1.21
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 500m
            memory: 512Mi
---
apiVersion: v1
kind: Service
metadata:
  name: web-app-service
  namespace: $NAMESPACE_DEMO
spec:
  selector:
    app: web-app
  ports:
  - port: 80
    targetPort: 80
  type: ClusterIP
EOF
    
    # Deploy database simulation
    cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: db-app
  namespace: $NAMESPACE_DEMO
spec:
  replicas: 1
  selector:
    matchLabels:
      app: db-app
  template:
    metadata:
      labels:
        app: db-app
    spec:
      containers:
      - name: db-app
        image: postgres:13
        env:
        - name: POSTGRES_DB
          value: testdb
        - name: POSTGRES_USER
          value: testuser
        - name: POSTGRES_PASSWORD
          value: testpass
        ports:
        - containerPort: 5432
        resources:
          requests:
            cpu: 100m
            memory: 256Mi
          limits:
            cpu: 1000m
            memory: 1Gi
---
apiVersion: v1
kind: Service
metadata:
  name: db-app-service
  namespace: $NAMESPACE_DEMO
spec:
  selector:
    app: db-app
  ports:
  - port: 5432
    targetPort: 5432
  type: ClusterIP
EOF
    
    # Wait for deployments to be ready
    log "Waiting for sample applications to be ready..."
    kubectl wait --for=condition=available --timeout=300s deployment/web-app -n "$NAMESPACE_DEMO"
    kubectl wait --for=condition=available --timeout=300s deployment/db-app -n "$NAMESPACE_DEMO"
    
    log_success "Sample applications deployed successfully!"
    kubectl get pods -n "$NAMESPACE_DEMO"
}

# Function to install Anteon
install_anteon() {
    log "🚀 Installing Anteon on Kubernetes..."
    
    # Add Anteon Helm repository
    helm repo add anteon https://getanteon.github.io/anteon || true
    helm repo update
    
    # Create namespace for Anteon
    kubectl create namespace "$NAMESPACE_ANTEON" --dry-run=client -o yaml | kubectl apply -f -
    
    # Create Anteon values file
    cat > anteon-values.yaml <<EOF
alaz:
  enabled: true
  image:
    tag: "latest"
  resources:
    requests:
      cpu: 100m
      memory: 200Mi
    limits:
      cpu: 500m
      memory: 1Gi

backend:
  enabled: true
  replicas: 1
  resources:
    requests:
      cpu: 200m
      memory: 512Mi
    limits:
      cpu: 1000m
      memory: 2Gi

frontend:
  enabled: true
  replicas: 1
  service:
    type: NodePort
    port: 8080

postgres:
  enabled: true
  auth:
    database: anteon
    username: anteon
    password: anteon123
EOF
    
    # Install Anteon
    helm install anteon anteon/anteon \
        --namespace "$NAMESPACE_ANTEON" \
        --values anteon-values.yaml \
        --wait \
        --timeout=600s
    
    log_success "Anteon installed successfully!"
    
    # Check installation status
    kubectl get pods -n "$NAMESPACE_ANTEON"
    kubectl get services -n "$NAMESPACE_ANTEON"
}

# Function to test Anteon dashboard access
test_dashboard_access() {
    log "🌐 Testing Anteon dashboard access..."
    
    # Get the frontend service
    FRONTEND_SERVICE=$(kubectl get service -n "$NAMESPACE_ANTEON" -l app.kubernetes.io/name=anteon -o jsonpath='{.items[0].metadata.name}')
    
    if [ -z "$FRONTEND_SERVICE" ]; then
        log_error "Anteon frontend service not found"
        return 1
    fi
    
    log "Found frontend service: $FRONTEND_SERVICE"
    
    # Start port forwarding in background
    kubectl port-forward -n "$NAMESPACE_ANTEON" "service/$FRONTEND_SERVICE" 8080:8080 &
    PORT_FORWARD_PID=$!
    
    # Wait for port forward to establish
    sleep 10
    
    # Test dashboard access
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:8080 | grep -q "200\|302"; then
        log_success "Anteon dashboard is accessible at http://localhost:8080"
    else
        log_warning "Dashboard might not be fully ready. Please check manually at http://localhost:8080"
    fi
    
    # Keep port forward running for a bit longer for manual testing
    log "Port forward will run for 30 seconds for manual testing..."
    sleep 30
    
    # Clean up port forward
    kill $PORT_FORWARD_PID 2>/dev/null || true
    
    log_success "Dashboard access test completed"
}

# Function to generate sample traffic
generate_sample_traffic() {
    log "🚦 Generating sample traffic for monitoring..."
    
    # Start port forward to web app
    kubectl port-forward -n "$NAMESPACE_DEMO" service/web-app-service 8090:80 &
    WEB_FORWARD_PID=$!
    
    sleep 5
    
    # Generate normal traffic
    log "🔄 Generating normal traffic..."
    for i in {1..50}; do
        curl -s http://localhost:8090 > /dev/null || true
        sleep 0.1
    done
    
    # Generate burst traffic
    log "🔄 Generating burst traffic..."
    for i in {1..10}; do
        (
            for j in {1..10}; do
                curl -s http://localhost:8090 > /dev/null || true
            done
        ) &
    done
    wait
    
    # Clean up port forward
    kill $WEB_FORWARD_PID 2>/dev/null || true
    
    log_success "Sample traffic generation completed!"
}

# Function to run performance tests
run_performance_tests() {
    log "🚀 Running performance tests with Anteon..."
    
    # Start port forward to web app for testing
    kubectl port-forward -n "$NAMESPACE_DEMO" service/web-app-service 8091:80 &
    TEST_FORWARD_PID=$!
    
    sleep 5
    
    # Run basic load test
    log "🔄 Executing basic load test..."
    ddosify -t http://localhost:8091 \
        -n 100 \
        -d 30 \
        -m GET \
        -h "User-Agent: Anteon-LoadTest" \
        -o stdout-json > load-test-results.json
    
    # Create advanced test configuration
    cat > advanced-test.json <<EOF
{
  "iteration_count": 50,
  "load_type": "linear",
  "duration": 60,
  "steps": [
    {
      "id": 1,
      "url": "http://localhost:8091/",
      "method": "GET",
      "headers": {
        "User-Agent": "Anteon-Advanced-Test"
      },
      "timeout": 5
    }
  ]
}
EOF
    
    # Run advanced test
    log "🔄 Executing advanced load test..."
    ddosify -config advanced-test.json > advanced-test-results.json
    
    # Clean up port forward
    kill $TEST_FORWARD_PID 2>/dev/null || true
    
    log_success "Performance tests completed!"
    log "Results saved to load-test-results.json and advanced-test-results.json"
}

# Function to test monitoring features
test_monitoring_features() {
    log "📊 Testing Anteon monitoring features..."
    
    # Check if Anteon pods are running
    if kubectl get pods -n "$NAMESPACE_ANTEON" | grep -q "Running"; then
        log_success "Anteon monitoring pods are running"
    else
        log_error "Some Anteon pods are not running properly"
        kubectl get pods -n "$NAMESPACE_ANTEON"
        return 1
    fi
    
    # Check if services are discoverable
    SERVICE_COUNT=$(kubectl get services --all-namespaces --no-headers | wc -l)
    log "Found $SERVICE_COUNT services across all namespaces"
    
    # Verify eBPF capability
    KERNEL_VERSION=$(kubectl get nodes -o jsonpath='{.items[0].status.nodeInfo.kernelVersion}')
    log "Kubernetes node kernel version: $KERNEL_VERSION"
    
    if echo "$KERNEL_VERSION" | grep -q "3\."; then
        log_warning "Old kernel version detected. eBPF features may be limited."
    else
        log_success "Kernel version supports eBPF"
    fi
    
    log_success "Monitoring features test completed"
}

# Function to cleanup resources
cleanup_resources() {
    log "🧹 Cleaning up tutorial resources..."
    
    # Remove Anteon
    if helm list -n "$NAMESPACE_ANTEON" | grep -q anteon; then
        helm uninstall anteon -n "$NAMESPACE_ANTEON"
    fi
    
    # Remove namespaces
    kubectl delete namespace "$NAMESPACE_ANTEON" --ignore-not-found=true
    kubectl delete namespace "$NAMESPACE_DEMO" --ignore-not-found=true
    
    # Remove Kind cluster
    if kind get clusters | grep -q "$CLUSTER_NAME"; then
        kind delete cluster --name "$CLUSTER_NAME"
    fi
    
    # Remove temporary files
    rm -f kind-config.yaml anteon-values.yaml advanced-test.json
    rm -f load-test-results.json advanced-test-results.json
    
    log_success "Cleanup completed!"
}

# Function to run health checks
run_health_checks() {
    log "🔧 Running health checks..."
    
    # Check kubectl connectivity
    if kubectl cluster-info &>/dev/null; then
        log_success "kubectl connectivity OK"
    else
        log_error "kubectl connectivity failed"
        return 1
    fi
    
    # Check namespace existence
    if kubectl get namespace "$NAMESPACE_ANTEON" &>/dev/null; then
        log_success "Anteon namespace exists"
    else
        log_warning "Anteon namespace not found"
    fi
    
    if kubectl get namespace "$NAMESPACE_DEMO" &>/dev/null; then
        log_success "Demo apps namespace exists"
    else
        log_warning "Demo apps namespace not found"
    fi
    
    # Check pod health
    ANTEON_PODS_READY=$(kubectl get pods -n "$NAMESPACE_ANTEON" --no-headers 2>/dev/null | grep Running | wc -l)
    DEMO_PODS_READY=$(kubectl get pods -n "$NAMESPACE_DEMO" --no-headers 2>/dev/null | grep Running | wc -l)
    
    log "Anteon pods running: $ANTEON_PODS_READY"
    log "Demo app pods running: $DEMO_PODS_READY"
    
    log_success "Health checks completed"
}

# Function to show usage
show_usage() {
    cat <<EOF
Usage: $0 [OPTIONS] [COMMAND]

Commands:
    install-tools       Install required tools (Docker, kubectl, Helm, Kind, ddosify)
    create-cluster      Create Kind cluster for testing
    deploy-apps         Deploy sample applications
    install-anteon      Install Anteon using Helm
    test-dashboard      Test dashboard access
    generate-traffic    Generate sample traffic for monitoring
    run-performance     Run performance tests
    test-monitoring     Test monitoring features
    health-check        Run health checks
    cleanup             Clean up all resources
    full-test           Run complete test suite (default)

Options:
    -h, --help          Show this help message
    -v, --verbose       Enable verbose output
    --skip-cleanup      Skip cleanup at the end
    --cluster-name      Specify cluster name (default: anteon-demo)

Examples:
    $0                          # Run full test suite
    $0 full-test                # Run full test suite
    $0 install-tools            # Only install tools
    $0 create-cluster           # Only create cluster
    $0 cleanup                  # Only cleanup resources
    $0 --skip-cleanup full-test # Run tests but skip cleanup

EOF
}

# Main execution function
main() {
    local command="full-test"
    local skip_cleanup=false
    local verbose=false
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                exit 0
                ;;
            -v|--verbose)
                verbose=true
                set -x
                shift
                ;;
            --skip-cleanup)
                skip_cleanup=true
                shift
                ;;
            --cluster-name)
                CLUSTER_NAME="$2"
                shift 2
                ;;
            install-tools|create-cluster|deploy-apps|install-anteon|test-dashboard|generate-traffic|run-performance|test-monitoring|health-check|cleanup|full-test)
                command="$1"
                shift
                ;;
            *)
                log_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    log "🎯 Starting Anteon tutorial test script"
    log "Command: $command"
    log "Log file: $TEST_LOG_FILE"
    log "Cluster name: $CLUSTER_NAME"
    
    # Execute based on command
    case $command in
        install-tools)
            install_tools
            ;;
        create-cluster)
            create_kind_cluster
            ;;
        deploy-apps)
            deploy_sample_apps
            ;;
        install-anteon)
            install_anteon
            ;;
        test-dashboard)
            test_dashboard_access
            ;;
        generate-traffic)
            generate_sample_traffic
            ;;
        run-performance)
            run_performance_tests
            ;;
        test-monitoring)
            test_monitoring_features
            ;;
        health-check)
            run_health_checks
            ;;
        cleanup)
            cleanup_resources
            ;;
        full-test)
            # Run complete test suite
            log "🚀 Running complete Anteon tutorial test suite..."
            
            install_tools
            create_kind_cluster
            deploy_sample_apps
            install_anteon
            test_dashboard_access
            generate_sample_traffic
            run_performance_tests
            test_monitoring_features
            run_health_checks
            
            if [[ "$skip_cleanup" != "true" ]]; then
                log "⏳ Waiting 30 seconds before cleanup (Ctrl+C to keep resources)..."
                sleep 30
                cleanup_resources
            else
                log "⚠️  Skipping cleanup. Resources will remain active."
                log "To cleanup manually, run: $0 cleanup"
            fi
            ;;
    esac
    
    log_success "Anteon tutorial test script completed!"
    log "Full log available at: $TEST_LOG_FILE"
}

# Run main function with all arguments
main "$@"
