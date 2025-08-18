#!/bin/bash

# Sampler Aliases Setup Script
# This script adds useful aliases for Sampler monitoring to your shell

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🔧 Setting up Sampler aliases..."

# Add aliases to zshrc
cat >> ~/.zshrc << 'EOF'

# ==========================================
# Sampler Monitoring Aliases
# ==========================================

# Basic Sampler commands
alias sampler-system="sampler -c $HOME/work/thakicloud/thakicloud.github.io/tutorials/sampler-test/system-monitor.yml"
alias sampler-web="sampler -c $HOME/work/thakicloud/thakicloud.github.io/tutorials/sampler-test/web-monitor.yml"
alias sampler-dev="sampler -c $HOME/work/thakicloud/thakicloud.github.io/tutorials/sampler-test/development-monitor.yml"
alias sampler-docker="sampler -c $HOME/work/thakicloud/thakicloud.github.io/tutorials/sampler-test/docker-monitor.yml"

# Quick monitoring shortcuts
alias monitor-sys="sampler-system"
alias monitor-web="sampler-web"
alias monitor-dev="sampler-dev"
alias monitor-docker="sampler-docker"

# Sampler config directory
alias sampler-configs="cd $HOME/work/thakicloud/thakicloud.github.io/tutorials/sampler-test"

# System monitoring shortcuts
alias cpu-monitor="ps -A -o %cpu | awk '{s+=\$1} END {print s}'"
alias mem-monitor="ps -A -o %mem | awk '{s+=\$1} END {print s}'"
alias disk-monitor="df -h / | awk 'NR==2 {print \$3}'"

# Web monitoring shortcuts
alias web-ping="curl -o /dev/null -s -w 'Status: %{http_code}, Time: %{time_total}s'"
alias google-ping="web-ping https://www.google.com"
alias github-ping="web-ping https://github.com"

# Development monitoring shortcuts
alias git-activity="git log --since='1 day ago' --oneline | wc -l"
alias project-stats="find . -type f | wc -l"
alias commit-today="git log --since='today' --oneline"

EOF

echo "✅ Sampler aliases added to ~/.zshrc"
echo "🔄 Run 'source ~/.zshrc' to load the new aliases"

echo ""
echo "📋 Available aliases:"
echo "  sampler-system    - System monitoring dashboard"
echo "  sampler-web       - Website monitoring dashboard"
echo "  sampler-dev       - Development monitoring dashboard"
echo "  sampler-docker    - Docker monitoring dashboard"
echo ""
echo "  monitor-sys       - Quick system monitor"
echo "  monitor-web       - Quick web monitor"
echo "  monitor-dev       - Quick development monitor"
echo "  monitor-docker    - Quick Docker monitor"
echo ""
echo "  sampler-configs   - Navigate to config directory"
echo ""
echo "  cpu-monitor       - Current CPU usage"
echo "  mem-monitor       - Current memory usage"
echo "  disk-monitor      - Current disk usage"
echo ""
echo "  google-ping       - Ping Google"
echo "  github-ping       - Ping GitHub"
echo "  git-activity      - Git commits today"
echo "  project-stats     - Project file count"
