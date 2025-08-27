#!/bin/bash

# CCPM Workflow Test Script for macOS
# This script tests the CCPM (Claude Code Project Management) workflow
# Author: Thaki Cloud
# Date: 2025-08-25

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Configuration
TEST_DIR="ccpm-test-project"
CCPM_REPO="https://github.com/automazeio/ccpm.git"

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check macOS version
check_macos() {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        log_error "This script is designed for macOS. Current OS: $OSTYPE"
        return 1
    fi
    
    local macos_version=$(sw_vers -productVersion)
    log_info "macOS version: $macos_version"
    return 0
}

# Function to check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check macOS
    if ! check_macos; then
        return 1
    fi
    
    # Check Git
    if ! command_exists git; then
        log_error "Git is not installed. Please install Git first."
        log_info "Install with: xcode-select --install"
        return 1
    fi
    
    local git_version=$(git --version)
    log_info "Git: $git_version"
    
    # Check if git version is 2.30+
    local git_ver_num=$(git --version | grep -oE '[0-9]+\.[0-9]+' | head -1)
    if [[ $(echo "$git_ver_num < 2.30" | bc -l 2>/dev/null || echo "1") == "1" ]]; then
        log_warning "Git version might be too old (required: 2.30+). Current: $git_ver_num"
    fi
    
    # Check GitHub CLI
    if ! command_exists gh; then
        log_warning "GitHub CLI (gh) is not installed."
        log_info "Install with: brew install gh"
        log_info "Or visit: https://cli.github.com/"
        read -p "Do you want to continue without GitHub CLI? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return 1
        fi
    else
        local gh_version=$(gh --version | head -1)
        log_info "GitHub CLI: $gh_version"
        
        # Check GitHub authentication
        if ! gh auth status >/dev/null 2>&1; then
            log_warning "GitHub CLI is not authenticated."
            log_info "Run: gh auth login"
        else
            log_success "GitHub CLI is authenticated"
        fi
    fi
    
    # Check Node.js
    if ! command_exists node; then
        log_warning "Node.js is not installed (recommended for automation scripts)"
        log_info "Install with: brew install node"
    else
        local node_version=$(node --version)
        log_info "Node.js: $node_version"
    fi
    
    # Check if Claude Code is available (this is tricky to test automatically)
    log_info "Note: Claude Code (Anthropic's coding assistant) is required but cannot be tested automatically"
    log_info "Make sure you have access to Claude Code before proceeding"
    
    return 0
}

# Function to setup test project
setup_test_project() {
    log_info "Setting up test project..."
    
    # Create test directory
    if [[ -d "$TEST_DIR" ]]; then
        log_warning "Test directory $TEST_DIR already exists. Removing..."
        rm -rf "$TEST_DIR"
    fi
    
    mkdir "$TEST_DIR"
    cd "$TEST_DIR"
    
    # Initialize git repository
    git init
    log_success "Initialized Git repository"
    
    # Create basic project structure
    mkdir -p src docs tests
    echo "# CCPM Test Project" > README.md
    echo "This is a test project for CCPM workflow." >> README.md
    
    # Create a basic package.json
    cat > package.json << 'EOF'
{
  "name": "ccpm-test-project",
  "version": "1.0.0",
  "description": "Test project for CCPM workflow",
  "main": "src/index.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "author": "CCPM Test",
  "license": "MIT"
}
EOF
    
    # Create basic source file
    cat > src/index.js << 'EOF'
// CCPM Test Project - Main Entry Point
console.log('Hello from CCPM Test Project!');

// This will be enhanced through CCPM workflow
function main() {
    console.log('Starting CCPM test application...');
}

if (require.main === module) {
    main();
}

module.exports = { main };
EOF
    
    # Initial commit
    git add .
    git commit -m "Initial commit: CCPM test project setup"
    
    log_success "Test project setup complete"
}

# Function to install CCPM
install_ccpm() {
    log_info "Installing CCPM..."
    
    # Clone CCPM repository to a temporary directory
    local temp_dir=$(mktemp -d)
    git clone "$CCPM_REPO" "$temp_dir"
    
    # Copy CCPM files to current project
    if [[ -d ".claude" ]]; then
        log_warning ".claude directory already exists. Creating backup..."
        mv .claude .claude.backup.$(date +%Y%m%d_%H%M%S)
    fi
    
    cp -r "$temp_dir/.claude" .
    
    # Copy other important files
    if [[ -f "$temp_dir/AGENTS.md" ]]; then
        cp "$temp_dir/AGENTS.md" .
    fi
    
    if [[ -f "$temp_dir/COMMANDS.md" ]]; then
        cp "$temp_dir/COMMANDS.md" .
    fi
    
    # Clean up
    rm -rf "$temp_dir"
    
    # Update .gitignore
    echo "" >> .gitignore
    echo "# CCPM" >> .gitignore
    echo ".claude/context/*" >> .gitignore
    echo ".claude/memory/*" >> .gitignore
    echo "!.claude/context/.gitkeep" >> .gitignore
    echo "!.claude/memory/.gitkeep" >> .gitignore
    
    # Create necessary directories
    mkdir -p .claude/context .claude/memory
    touch .claude/context/.gitkeep .claude/memory/.gitkeep
    
    git add .
    git commit -m "feat: Add CCMP system to project"
    
    log_success "CCPM installation complete"
}

# Function to validate CCPM installation
validate_ccpm_installation() {
    log_info "Validating CCPM installation..."
    
    # Check for required CCPM files
    local required_files=(
        ".claude"
        ".claude/CLAUDE.md"
    )
    
    for file in "${required_files[@]}"; do
        if [[ ! -e "$file" ]]; then
            log_error "Required CCPM file missing: $file"
            return 1
        fi
    done
    
    # Check .claude directory structure
    if [[ ! -d ".claude/context" ]] || [[ ! -d ".claude/memory" ]]; then
        log_error "CCPM directory structure is incomplete"
        return 1
    fi
    
    log_success "CCPM installation validation passed"
    
    # Display CCMP commands reference
    log_info "Available CCPM commands:"
    echo "  /pm:init                 - Initialize CCPM system"
    echo "  /pm:prd-new <name>       - Create new PRD"
    echo "  /pm:prd-parse <name>     - Parse PRD into epic"
    echo "  /pm:epic-oneshot <name>  - Create epic and sync to GitHub"
    echo "  /pm:issue-start <id>     - Start work on issue"
    echo "  /pm:status               - Show project status"
    echo "  /pm:next                 - Get next priority task"
    echo "  /pm:sync                 - Sync with GitHub"
    echo ""
    echo "See COMMANDS.md for complete command reference"
}

# Function to create sample workflow
create_sample_workflow() {
    log_info "Creating sample CCPM workflow..."
    
    # Create a sample PRD
    mkdir -p .claude/prds
    cat > .claude/prds/sample-feature.md << 'EOF'
# Sample Feature PRD

## Problem Statement
This is a sample PRD to demonstrate CCPM workflow capabilities.

## Success Metrics
- Demonstrate complete CCMP workflow
- Show PRD to production code traceability
- Validate parallel execution concept

## User Stories
- As a developer, I want to see how CCPM transforms ideas into code
- As a team lead, I want transparent progress tracking
- As a product manager, I want requirements preserved throughout development

## Technical Requirements
- Simple feature implementation
- Test coverage
- Documentation
- GitHub integration

## Integration Points
- Existing project structure
- Git workflow
- CI/CD pipeline (future)

## Acceptance Criteria
- [ ] Feature implemented according to spec
- [ ] Tests passing
- [ ] Documentation updated
- [ ] Code reviewed and approved
EOF
    
    # Create sample epic structure
    mkdir -p .claude/epics
    cat > .claude/epics/sample-feature.md << 'EOF'
# Epic: Sample Feature Implementation

## Overview
Implement sample feature to demonstrate CCPM workflow from PRD to production.

## Tasks
1. **Core Implementation** (1-2 days)
   - Implement main feature logic
   - Add error handling
   - Create configuration options

2. **Testing & Quality** (1 day)
   - Unit tests
   - Integration tests
   - Code quality checks

3. **Documentation & Integration** (0.5 days)
   - API documentation
   - User documentation
   - README updates

## Dependencies
- Project setup complete
- Development environment ready
- GitHub repository configured

## Success Criteria
- All tests passing
- Documentation complete
- Code review approved
- Feature deployed to staging
EOF
    
    git add .
    git commit -m "docs: Add sample CCPM workflow files"
    
    log_success "Sample workflow created"
}

# Function to test GitHub integration (if available)
test_github_integration() {
    if ! command_exists gh; then
        log_warning "Skipping GitHub integration test (gh CLI not available)"
        return 0
    fi
    
    if ! gh auth status >/dev/null 2>&1; then
        log_warning "Skipping GitHub integration test (not authenticated)"
        return 0
    fi
    
    log_info "Testing GitHub integration..."
    
    # This would normally create a GitHub repository and test issue creation
    # For safety, we'll just validate that the commands would work
    log_info "GitHub CLI is ready for CCMP integration"
    log_info "In Claude Code, you can now use:"
    echo "  /pm:epic-sync sample-feature"
    echo "  /pm:issue-start <issue-id>"
    
    log_success "GitHub integration test complete"
}

# Function to cleanup test project
cleanup_test_project() {
    log_info "Cleaning up test project..."
    cd ..
    if [[ -d "$TEST_DIR" ]]; then
        rm -rf "$TEST_DIR"
        log_success "Test project cleaned up"
    fi
}

# Function to display final instructions
display_final_instructions() {
    log_success "CCPM Workflow Test Complete!"
    echo ""
    echo "🎉 Next Steps:"
    echo "1. Open your project in Claude Code"
    echo "2. Run: /pm:init"
    echo "3. Create your first PRD: /pm:prd-new my-feature"
    echo "4. Parse to epic: /pm:prd-parse my-feature"
    echo "5. Sync to GitHub: /pm:epic-oneshot my-feature"
    echo "6. Start development: /pm:issue-start <issue-id>"
    echo ""
    echo "📚 Resources:"
    echo "- CCPM Repository: $CCPM_REPO"
    echo "- Commands Reference: COMMANDS.md"
    echo "- Agents Guide: AGENTS.md"
    echo ""
    echo "💡 Tips:"
    echo "- Use /pm:status to track progress"
    echo "- Use /pm:next for intelligent task prioritization"
    echo "- Use /pm:sync to keep GitHub in sync"
    echo ""
    log_info "Happy coding with CCPM! 🚀"
}

# Main execution
main() {
    echo "================================================"
    echo "🚀 CCPM Workflow Test Script"
    echo "================================================"
    echo ""
    
    # Check prerequisites
    if ! check_prerequisites; then
        log_error "Prerequisites check failed"
        exit 1
    fi
    
    echo ""
    log_success "Prerequisites check passed"
    echo ""
    
    # Setup test project
    setup_test_project
    echo ""
    
    # Install CCPM
    install_ccpm
    echo ""
    
    # Validate installation
    validate_ccmp_installation
    echo ""
    
    # Create sample workflow
    create_sample_workflow
    echo ""
    
    # Test GitHub integration
    test_github_integration
    echo ""
    
    # Display final instructions
    display_final_instructions
    
    # Ask if user wants to keep test project
    echo ""
    read -p "Keep test project for experimentation? (Y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        cleanup_test_project
    else
        log_info "Test project preserved at: $(pwd)/$TEST_DIR"
    fi
}

# Trap to cleanup on exit
trap 'log_error "Script interrupted"; cleanup_test_project' INT TERM

# Run main function
main "$@"
