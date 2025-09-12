#!/bin/bash

# =============================================================================
# Youtu-Agent macOS Compatibility Test Script
# =============================================================================
# This script tests Youtu-Agent installation and basic functionality on macOS
# Version: 1.0
# Date: 2025-09-10
# =============================================================================

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

log_header() {
    echo -e "\n${BLUE}$1${NC}"
    echo "================================"
}

# Test results tracking
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_WARNING=0

record_result() {
    case $1 in
        "pass")
            ((TESTS_PASSED++))
            ;;
        "fail")
            ((TESTS_FAILED++))
            ;;
        "warning")
            ((TESTS_WARNING++))
            ;;
    esac
}

# Main test function
main() {
    log_header "🧪 Testing Youtu-Agent on macOS"
    
    test_system_requirements
    test_python_version
    test_uv_installation
    test_git_availability
    test_project_structure
    test_virtual_environment
    test_environment_configuration
    test_basic_agent_functionality
    test_dependency_installation
    test_example_scripts
    
    print_summary
}

# Test 1: System Requirements
test_system_requirements() {
    log_header "1. System Requirements Check"
    
    # Check macOS
    if [[ "$OSTYPE" == "darwin"* ]]; then
        log_success "Running on macOS"
        record_result "pass"
    else
        log_warning "Not running on macOS, but script may still work"
        record_result "warning"
    fi
    
    # Check macOS version
    if command -v sw_vers &> /dev/null; then
        macos_version=$(sw_vers -productVersion)
        log_info "macOS Version: $macos_version"
        
        # Check if version is 10.15+ (Catalina or later)
        if [[ $(echo "$macos_version 10.15" | tr " " "\n" | sort -V | head -n1) == "10.15" ]]; then
            log_success "macOS version is compatible"
            record_result "pass"
        else
            log_warning "macOS version may be too old (requires 10.15+)"
            record_result "warning"
        fi
    fi
    
    # Check available disk space
    available_space=$(df -h . | awk 'NR==2 {print $4}')
    log_info "Available disk space: $available_space"
    
    # Check memory
    if command -v vm_stat &> /dev/null; then
        free_memory=$(vm_stat | grep "Pages free" | awk '{print $3}' | sed 's/\.//')
        free_mb=$((free_memory * 4096 / 1024 / 1024))
        log_info "Free memory: ${free_mb}MB"
        
        if [ $free_mb -gt 2048 ]; then
            log_success "Sufficient memory available"
            record_result "pass"
        else
            log_warning "Low memory detected (< 2GB free)"
            record_result "warning"
        fi
    fi
}

# Test 2: Python Version
test_python_version() {
    log_header "2. Python Version Check"
    
    if command -v python3 &> /dev/null; then
        python_version=$(python3 --version 2>&1)
        log_info "Python version: $python_version"
        
        # Extract version number
        version_number=$(echo "$python_version" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
        major_version=$(echo "$version_number" | cut -d. -f1)
        minor_version=$(echo "$version_number" | cut -d. -f2)
        
        if [ "$major_version" -eq 3 ] && [ "$minor_version" -ge 12 ]; then
            log_success "Python version is compatible (3.12+)"
            record_result "pass"
        else
            log_error "Python 3.12+ required (found: $python_version)"
            record_result "fail"
            
            # Suggest installation methods
            log_info "Install Python 3.12+ using one of these methods:"
            log_info "  • Homebrew: brew install python@3.12"
            log_info "  • pyenv: pyenv install 3.12.0"
            log_info "  • Official installer: https://www.python.org/downloads/"
        fi
    else
        log_error "Python3 not found"
        record_result "fail"
    fi
    
    # Check if python command points to python3
    if command -v python &> /dev/null; then
        python_version=$(python --version 2>&1)
        log_info "python command: $python_version"
    else
        log_warning "python command not found (using python3 is recommended)"
        record_result "warning"
    fi
}

# Test 3: uv Installation
test_uv_installation() {
    log_header "3. uv Package Manager Check"
    
    if command -v uv &> /dev/null; then
        uv_version=$(uv --version 2>&1)
        log_success "uv is installed: $uv_version"
        record_result "pass"
        
        # Test uv functionality
        if uv --help &> /dev/null; then
            log_success "uv is working correctly"
            record_result "pass"
        else
            log_warning "uv installed but not working properly"
            record_result "warning"
        fi
    else
        log_warning "uv not found, installing..."
        record_result "warning"
        
        # Install uv
        if curl -LsSf https://astral.sh/uv/install.sh | sh; then
            # Reload shell environment
            export PATH="$HOME/.cargo/bin:$PATH"
            
            if command -v uv &> /dev/null; then
                log_success "uv installed successfully"
                record_result "pass"
            else
                log_error "uv installation failed"
                record_result "fail"
            fi
        else
            log_error "Failed to install uv"
            record_result "fail"
        fi
    fi
}

# Test 4: Git Availability
test_git_availability() {
    log_header "4. Git Availability Check"
    
    if command -v git &> /dev/null; then
        git_version=$(git --version)
        log_success "Git is available: $git_version"
        record_result "pass"
    else
        log_error "Git not found. Install with: xcode-select --install"
        record_result "fail"
    fi
}

# Test 5: Project Structure
test_project_structure() {
    log_header "5. Project Structure Check"
    
    # Check if we're in a youtu-agent directory or need to clone
    if [ -f "pyproject.toml" ] && grep -q "youtu-agent" pyproject.toml 2>/dev/null; then
        log_success "Already in youtu-agent project directory"
        record_result "pass"
    else
        log_info "Not in youtu-agent directory, checking if we can clone..."
        
        if [ -d "youtu-agent" ]; then
            log_info "youtu-agent directory exists, entering it"
            cd youtu-agent || {
                log_error "Failed to enter youtu-agent directory"
                record_result "fail"
                return
            }
        else
            log_info "Cloning youtu-agent repository..."
            if git clone https://github.com/TencentCloudADP/youtu-agent.git; then
                cd youtu-agent || {
                    log_error "Failed to enter cloned directory"
                    record_result "fail"
                    return
                }
                log_success "Successfully cloned youtu-agent"
                record_result "pass"
            else
                log_error "Failed to clone youtu-agent repository"
                record_result "fail"
                return
            fi
        fi
    fi
    
    # Check essential files
    essential_files=("pyproject.toml" "uv.lock" "README.md" ".env.example")
    for file in "${essential_files[@]}"; do
        if [ -f "$file" ]; then
            log_success "$file exists"
        else
            log_warning "$file not found"
            record_result "warning"
        fi
    done
    
    # Check essential directories
    essential_dirs=("utu" "configs" "examples" "scripts")
    for dir in "${essential_dirs[@]}"; do
        if [ -d "$dir" ]; then
            log_success "$dir/ directory exists"
        else
            log_warning "$dir/ directory not found"
            record_result "warning"
        fi
    done
}

# Test 6: Virtual Environment
test_virtual_environment() {
    log_header "6. Virtual Environment Check"
    
    # Try to sync dependencies
    if command -v uv &> /dev/null; then
        log_info "Syncing dependencies with uv..."
        if uv sync; then
            log_success "Dependencies synced successfully"
            record_result "pass"
        else
            log_error "Failed to sync dependencies"
            record_result "fail"
            return
        fi
    else
        log_error "uv not available for dependency management"
        record_result "fail"
        return
    fi
    
    # Check if virtual environment was created
    if [ -d ".venv" ]; then
        log_success "Virtual environment created at .venv/"
        record_result "pass"
        
        # Activate virtual environment
        if source ./.venv/bin/activate; then
            log_success "Virtual environment activated"
            record_result "pass"
            
            # Test import
            if python -c "import utu; print('✅ utu module imported successfully')" 2>/dev/null; then
                log_success "utu module imports correctly"
                record_result "pass"
            else
                log_error "Failed to import utu module"
                record_result "fail"
            fi
        else
            log_error "Failed to activate virtual environment"
            record_result "fail"
        fi
    else
        log_error "Virtual environment not created"
        record_result "fail"
    fi
}

# Test 7: Environment Configuration
test_environment_configuration() {
    log_header "7. Environment Configuration Check"
    
    if [ -f ".env" ]; then
        log_success ".env file exists"
        record_result "pass"
        
        # Check for required environment variables
        required_vars=("UTU_LLM_TYPE" "UTU_LLM_MODEL" "UTU_LLM_BASE_URL" "UTU_LLM_API_KEY")
        for var in "${required_vars[@]}"; do
            if grep -q "^$var=" .env; then
                if grep -q "^$var=.*[^[:space:]]" .env; then
                    log_success "$var is configured"
                    record_result "pass"
                else
                    log_warning "$var is set but empty"
                    record_result "warning"
                fi
            else
                log_warning "$var not found in .env"
                record_result "warning"
            fi
        done
        
        # Check optional API keys
        optional_vars=("SERPER_API_KEY" "JINA_API_KEY")
        for var in "${optional_vars[@]}"; do
            if grep -q "^$var=" .env && grep -q "^$var=.*[^[:space:]]" .env; then
                log_success "$var is configured (optional)"
            else
                log_warning "$var not configured (required for web search)"
            fi
        done
    else
        log_warning ".env file not found"
        record_result "warning"
        
        if [ -f ".env.example" ]; then
            log_info "Copying .env.example to .env..."
            if cp .env.example .env; then
                log_success "Created .env from template"
                log_warning "Please edit .env and add your API keys"
                record_result "warning"
            else
                log_error "Failed to copy .env.example"
                record_result "fail"
            fi
        else
            log_error ".env.example not found"
            record_result "fail"
        fi
    fi
}

# Test 8: Basic Agent Functionality
test_basic_agent_functionality() {
    log_header "8. Basic Agent Functionality Test"
    
    # Ensure virtual environment is activated
    if [ -z "$VIRTUAL_ENV" ] && [ -d ".venv" ]; then
        source ./.venv/bin/activate
    fi
    
    # Test configuration loading
    log_info "Testing configuration loading..."
    if python -c "
from utu.core.config import load_config
try:
    config = load_config('configs/agents/base.yaml')
    print('✅ Base configuration loaded successfully')
except Exception as e:
    print(f'❌ Configuration error: {e}')
    exit(1)
" 2>/dev/null; then
        log_success "Configuration loading works"
        record_result "pass"
    else
        log_error "Configuration loading failed"
        record_result "fail"
    fi
    
    # Test agent creation (without API calls)
    log_info "Testing agent creation..."
    if python -c "
from utu.core.agent import Agent
from utu.core.config import load_config
try:
    config = load_config('configs/agents/base.yaml')
    agent = Agent(config)
    print('✅ Agent created successfully')
except Exception as e:
    print(f'❌ Agent creation error: {e}')
    exit(1)
" 2>/dev/null; then
        log_success "Agent creation works"
        record_result "pass"
    else
        log_error "Agent creation failed"
        record_result "fail"
    fi
}

# Test 9: Dependency Installation
test_dependency_installation() {
    log_header "9. Dependency Installation Test"
    
    # Ensure virtual environment is activated
    if [ -z "$VIRTUAL_ENV" ] && [ -d ".venv" ]; then
        source ./.venv/bin/activate
    fi
    
    # Test critical imports
    critical_modules=("utu" "openai" "yaml" "asyncio" "pydantic")
    for module in "${critical_modules[@]}"; do
        if python -c "import $module" 2>/dev/null; then
            log_success "$module module available"
            record_result "pass"
        else
            log_error "$module module not available"
            record_result "fail"
        fi
    done
    
    # Test optional imports
    optional_modules=("fastapi" "flask" "streamlit")
    for module in "${optional_modules[@]}"; do
        if python -c "import $module" 2>/dev/null; then
            log_success "$module module available (optional)"
        else
            log_info "$module module not available (optional)"
        fi
    done
}

# Test 10: Example Scripts
test_example_scripts() {
    log_header "10. Example Scripts Test"
    
    # Check if example scripts exist
    example_scripts=("scripts/cli_chat.py" "examples/svg_generator/main.py")
    for script in "${example_scripts[@]}"; do
        if [ -f "$script" ]; then
            log_success "$script exists"
            record_result "pass"
            
            # Test script syntax
            if python -m py_compile "$script" 2>/dev/null; then
                log_success "$script syntax is valid"
                record_result "pass"
            else
                log_error "$script has syntax errors"
                record_result "fail"
            fi
        else
            log_warning "$script not found"
            record_result "warning"
        fi
    done
    
    # Test running CLI script (syntax check only)
    if [ -f "scripts/cli_chat.py" ]; then
        log_info "Testing CLI script help..."
        if python scripts/cli_chat.py --help &>/dev/null; then
            log_success "CLI script help works"
            record_result "pass"
        else
            log_warning "CLI script help failed (may be due to missing dependencies)"
            record_result "warning"
        fi
    fi
}

# Print test summary
print_summary() {
    log_header "📊 Test Summary"
    
    total_tests=$((TESTS_PASSED + TESTS_FAILED + TESTS_WARNING))
    
    echo -e "${GREEN}✅ Passed: $TESTS_PASSED${NC}"
    echo -e "${RED}❌ Failed: $TESTS_FAILED${NC}"
    echo -e "${YELLOW}⚠️  Warnings: $TESTS_WARNING${NC}"
    echo -e "${BLUE}📊 Total: $total_tests${NC}"
    
    if [ $TESTS_FAILED -eq 0 ]; then
        log_success "🎉 All critical tests passed!"
        
        if [ $TESTS_WARNING -gt 0 ]; then
            log_warning "Some warnings were found. Check the output above for details."
        fi
        
        echo ""
        log_info "Next steps:"
        log_info "1. Edit .env file with your API keys"
        log_info "2. Run: python scripts/cli_chat.py --stream --config base"
        log_info "3. Explore examples/ directory for more use cases"
        
    else
        log_error "❌ Some tests failed. Please address the issues above."
        echo ""
        log_info "Common solutions:"
        log_info "• Install Python 3.12+: brew install python@3.12"
        log_info "• Install uv: curl -LsSf https://astral.sh/uv/install.sh | sh"
        log_info "• Install Git: xcode-select --install"
        log_info "• Check internet connection for downloads"
        
        exit 1
    fi
}

# Cleanup function
cleanup() {
    log_info "Cleaning up..."
    # Add any cleanup code here if needed
}

# Trap for cleanup on exit
trap cleanup EXIT

# Run main function
main "$@"
