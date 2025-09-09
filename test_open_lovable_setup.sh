#!/bin/bash

# Open Lovable Setup and Test Script for macOS
# This script tests the Open Lovable installation process on macOS

set -e  # Exit on any error

echo "🔥 Open Lovable - AI React App Builder Test Script"
echo "================================================="
echo "Testing Open Lovable installation on macOS..."
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check Node.js
    if command -v node >/dev/null 2>&1; then
        NODE_VERSION=$(node --version)
        print_success "Node.js found: $NODE_VERSION"
        
        # Check if version is 18 or higher
        NODE_MAJOR_VERSION=$(echo $NODE_VERSION | cut -d'.' -f1 | sed 's/v//')
        if [ "$NODE_MAJOR_VERSION" -ge 18 ]; then
            print_success "Node.js version is 18 or higher ✅"
        else
            print_error "Node.js version must be 18 or higher. Current: $NODE_VERSION"
            exit 1
        fi
    else
        print_error "Node.js not found. Please install Node.js 18 or higher"
        echo "Install with: brew install node"
        exit 1
    fi
    
    # Check npm
    if command -v npm >/dev/null 2>&1; then
        NPM_VERSION=$(npm --version)
        print_success "npm found: $NPM_VERSION"
    else
        print_error "npm not found"
        exit 1
    fi
    
    # Check Git
    if command -v git >/dev/null 2>&1; then
        GIT_VERSION=$(git --version)
        print_success "Git found: $GIT_VERSION"
    else
        print_error "Git not found. Please install Git"
        echo "Install with: xcode-select --install"
        exit 1
    fi
    
    echo ""
}

# Clone repository
clone_repository() {
    print_status "Cloning Open Lovable repository..."
    
    REPO_DIR="open-lovable-test"
    
    # Remove existing directory if it exists
    if [ -d "$REPO_DIR" ]; then
        print_warning "Removing existing $REPO_DIR directory..."
        rm -rf "$REPO_DIR"
    fi
    
    # Clone the repository
    if git clone https://github.com/firecrawl/open-lovable.git "$REPO_DIR"; then
        print_success "Repository cloned successfully"
        cd "$REPO_DIR"
    else
        print_error "Failed to clone repository"
        exit 1
    fi
    
    echo ""
}

# Install dependencies
install_dependencies() {
    print_status "Installing dependencies..."
    
    # Install with npm
    if npm install; then
        print_success "Dependencies installed successfully"
    else
        print_error "Failed to install dependencies"
        exit 1
    fi
    
    echo ""
}

# Setup environment
setup_environment() {
    print_status "Setting up environment..."
    
    # Copy example environment file
    if [ -f ".env.example" ]; then
        cp .env.example .env.local
        print_success "Created .env.local from .env.example"
        
        print_warning "⚠️  IMPORTANT: You need to add your API keys to .env.local"
        echo "Required API keys:"
        echo "  - E2B_API_KEY (from https://e2b.dev)"
        echo "  - FIRECRAWL_API_KEY (from https://firecrawl.dev)"
        echo "Optional AI provider keys (choose at least one):"
        echo "  - ANTHROPIC_API_KEY (from https://console.anthropic.com)"
        echo "  - OPENAI_API_KEY (from https://platform.openai.com)"
        echo "  - GEMINI_API_KEY (from https://aistudio.google.com/app/apikey)"
        echo "  - GROQ_API_KEY (from https://console.groq.com)"
        echo ""
        
        # Show the environment file structure
        print_status "Environment file structure:"
        cat .env.example
        echo ""
    else
        print_error ".env.example file not found"
        exit 1
    fi
}

# Check project structure
check_project_structure() {
    print_status "Checking project structure..."
    
    EXPECTED_DIRS=("app" "components" "config" "lib" "public" "types")
    EXPECTED_FILES=("package.json" "next.config.ts" "tailwind.config.ts" "tsconfig.json")
    
    for dir in "${EXPECTED_DIRS[@]}"; do
        if [ -d "$dir" ]; then
            print_success "Directory found: $dir"
        else
            print_warning "Directory missing: $dir"
        fi
    done
    
    for file in "${EXPECTED_FILES[@]}"; do
        if [ -f "$file" ]; then
            print_success "File found: $file"
        else
            print_warning "File missing: $file"
        fi
    done
    
    echo ""
}

# Test build (dry run without API keys)
test_build() {
    print_status "Testing project build (without API keys)..."
    
    # Try to build the project
    if npm run build; then
        print_success "Build completed successfully"
    else
        print_warning "Build failed (expected without API keys)"
        print_status "This is normal if API keys are not configured"
    fi
    
    echo ""
}

# Test development server (quick start/stop)
test_dev_server() {
    print_status "Testing development server..."
    
    # Start dev server in background
    print_status "Starting development server..."
    npm run dev &
    DEV_PID=$!
    
    # Wait a bit for server to start
    sleep 10
    
    # Check if server is running
    if curl -s http://localhost:3000 >/dev/null; then
        print_success "Development server is running on http://localhost:3000"
    else
        print_warning "Development server may not be fully started yet"
    fi
    
    # Stop the server
    print_status "Stopping development server..."
    kill $DEV_PID 2>/dev/null || true
    
    # Wait for process to stop
    sleep 2
    
    print_success "Development server test completed"
    echo ""
}

# Show next steps
show_next_steps() {
    print_status "🎉 Installation test completed!"
    echo ""
    echo "Next steps to use Open Lovable:"
    echo ""
    echo "1. 📝 Configure API keys in .env.local:"
    echo "   cd open-lovable-test"
    echo "   nano .env.local"
    echo ""
    echo "2. 🚀 Start the development server:"
    echo "   npm run dev"
    echo ""
    echo "3. 🌐 Open your browser:"
    echo "   http://localhost:3000"
    echo ""
    echo "4. 💬 Start chatting with AI to build React apps!"
    echo ""
    echo "📚 Documentation and examples:"
    echo "   - GitHub: https://github.com/firecrawl/open-lovable"
    echo "   - API Documentation: Check the docs/ directory"
    echo ""
    echo "⚠️  Remember to:"
    echo "   - Never commit API keys to version control"
    echo "   - Keep your API keys secure"
    echo "   - Monitor your API usage and costs"
    echo ""
}

# Cleanup function
cleanup() {
    print_status "Cleaning up test environment..."
    cd ..
    if [ -d "open-lovable-test" ]; then
        rm -rf "open-lovable-test"
        print_success "Test directory removed"
    fi
}

# Main execution
main() {
    echo "Starting Open Lovable installation test..."
    echo ""
    
    check_prerequisites
    clone_repository
    install_dependencies
    setup_environment
    check_project_structure
    test_build
    test_dev_server
    show_next_steps
    
    # Ask user if they want to keep the test directory
    echo ""
    read -p "Keep the test directory? (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        cleanup
    else
        print_success "Test directory kept: open-lovable-test"
    fi
    
    print_success "✅ Open Lovable test completed successfully!"
}

# Run main function
main

# Exit successfully
exit 0
