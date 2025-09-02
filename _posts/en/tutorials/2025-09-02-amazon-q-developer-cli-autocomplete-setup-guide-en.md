---
title: "Amazon Q Developer CLI: Complete Setup and Usage Guide for Terminal Autocomplete"
excerpt: "Learn how to install and configure Amazon Q Developer CLI (formerly Fig) for intelligent terminal autocomplete with hundreds of CLI tools including git, npm, docker, and aws."
seo_title: "Amazon Q Developer CLI Setup Guide - Terminal Autocomplete Tutorial"
seo_description: "Complete guide to installing Amazon Q Developer CLI for intelligent terminal autocomplete. Step-by-step tutorial with examples for git, npm, docker commands."
date: 2025-09-02
categories:
  - tutorials
tags:
  - amazon-q
  - terminal
  - autocomplete
  - cli-tools
  - macos
  - developer-tools
author_profile: true
toc: true
toc_label: "Table of Contents"
lang: en
permalink: /en/tutorials/amazon-q-developer-cli-setup-guide/
canonical_url: "https://thakicloud.github.io/en/tutorials/amazon-q-developer-cli-setup-guide/"
---

⏱️ **Estimated Reading Time**: 8 minutes

## Introduction

Amazon Q Developer CLI (formerly known as Fig) revolutionizes the command-line experience by providing IDE-style autocomplete for hundreds of popular CLI tools. Instead of memorizing complex commands and options, you can simply start typing and get contextually relevant suggestions for subcommands, options, and arguments.

This comprehensive guide will walk you through installing, configuring, and using Amazon Q Developer CLI to supercharge your terminal productivity.

## What is Amazon Q Developer CLI?

Amazon Q Developer CLI is an intelligent terminal autocomplete tool that transforms your command-line interface into a more intuitive and productive environment. It provides:

- **Smart Autocomplete**: Context-aware suggestions for 400+ CLI tools
- **Real-time Help**: Instant access to command documentation
- **Visual Interface**: Clean, IDE-style completion popups
- **Open Source**: Community-driven completion specifications

### Supported CLI Tools

Amazon Q supports hundreds of popular tools including:
- **Version Control**: `git`, `gh`, `svn`
- **Package Managers**: `npm`, `yarn`, `pip`, `brew`
- **Cloud Services**: `aws`, `gcloud`, `azure`
- **Containers**: `docker`, `kubectl`, `helm`
- **Development**: `node`, `python`, `java`, `go`

## System Requirements

### Supported Platforms
- **macOS**: Primary platform with full feature support
- **Linux**: In development (community beta available)
- **Windows**: In development (community beta available)

### Supported Terminals
- macOS Terminal
- iTerm2
- Tabby
- Hyper
- Kitty
- WezTerm
- Alacritty
- VSCode Integrated Terminal
- JetBrains IDEs
- Android Studio
- Nova

### Prerequisites
- **macOS**: 10.14 or later
- **Shell**: bash, zsh, or fish
- **Node.js**: Required for development (optional for usage)

## Installation Guide

### Method 1: Homebrew (Recommended)

The easiest way to install Amazon Q Developer CLI on macOS:

```bash
# Install Amazon Q via Homebrew
brew install amazon-q
```

### Method 2: Direct Download

1. Visit [aws.amazon.com](https://aws.amazon.com)
2. Download the DMG file
3. Open the downloaded file
4. Drag Amazon Q to Applications folder
5. Launch the application

### Method 3: Manual Installation Script

For advanced users who prefer manual installation:

```bash
#!/bin/bash
# Download and install Amazon Q Developer CLI

# Create temporary directory
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Download latest release
curl -L -o amazon-q.dmg "https://aws.amazon.com/q/developer/cli/download"

# Mount and install
hdiutil mount amazon-q.dmg
cp -R "/Volumes/Amazon Q/Amazon Q.app" /Applications/
hdiutil unmount "/Volumes/Amazon Q"

# Clean up
cd ~
rm -rf "$TEMP_DIR"

echo "Amazon Q Developer CLI installed successfully!"
echo "Please launch the app to complete setup."
```

## Initial Setup and Configuration

### Step 1: Launch Amazon Q

After installation, launch Amazon Q from your Applications folder or Launchpad:

```bash
# Launch via command line
open -a "Amazon Q"
```

### Step 2: Grant Permissions

Amazon Q requires certain permissions to function properly:

1. **Accessibility Permission**:
   - System Preferences → Security & Privacy → Privacy → Accessibility
   - Add Amazon Q and enable it

2. **Input Monitoring Permission**:
   - System Preferences → Security & Privacy → Privacy → Input Monitoring
   - Add Amazon Q and enable it

### Step 3: Shell Integration

Amazon Q automatically integrates with your shell during first launch. If you need to manually configure:

#### For Zsh (Default on macOS)
```bash
# Add to ~/.zshrc
echo 'eval "$(q init zsh)"' >> ~/.zshrc
source ~/.zshrc
```

#### For Bash
```bash
# Add to ~/.bashrc or ~/.bash_profile
echo 'eval "$(q init bash)"' >> ~/.bash_profile
source ~/.bash_profile
```

#### For Fish
```bash
# Add to ~/.config/fish/config.fish
echo 'q init fish | source' >> ~/.config/fish/config.fish
```

### Step 4: Verify Installation

Test that Amazon Q is working correctly:

```bash
# Test with git command
git <press-tab>

# Test with npm command
npm <press-tab>

# Test with docker command
docker <press-tab>
```

You should see intelligent autocomplete suggestions appear.

## Basic Usage Examples

### Git Commands

Amazon Q makes git operations much more intuitive:

```bash
# Basic git operations
git add <tab>          # Shows unstaged files
git commit -<tab>      # Shows commit options
git branch <tab>       # Shows available branches
git checkout <tab>     # Shows branches and files
git push origin <tab>  # Shows remote branches

# Advanced git workflows
git rebase -<tab>      # Interactive rebase options
git log --<tab>        # Log formatting options
git merge <tab>        # Shows mergeable branches
```

### NPM and Package Management

Streamline package management workflows:

```bash
# NPM commands
npm install <tab>      # Suggests packages from registry
npm run <tab>          # Shows available scripts
npm update <tab>       # Shows outdated packages

# Yarn commands
yarn add <tab>         # Package suggestions
yarn remove <tab>      # Shows installed packages
yarn workspace <tab>   # Shows workspace names
```

### Docker Operations

Simplify container management:

```bash
# Docker commands
docker run <tab>       # Image suggestions and options
docker exec <tab>      # Running container names
docker ps <tab>        # Container formatting options
docker build <tab>     # Build options and contexts

# Docker Compose
docker-compose up <tab>    # Service names
docker-compose logs <tab>  # Service selection
```

### AWS CLI Integration

Enhanced cloud operations:

```bash
# AWS commands
aws s3 <tab>           # S3 service operations
aws ec2 <tab>          # EC2 service operations
aws configure <tab>    # Configuration options

# Resource-specific suggestions
aws s3 cp <tab>        # Bucket and object names
aws ec2 describe-instances <tab>  # Filtering options
```

## Advanced Configuration

### Customizing Appearance

Configure Amazon Q's appearance to match your terminal theme:

```bash
# Open configuration
q config

# Available themes
q config set theme dark
q config set theme light
q config set theme auto

# Customize colors
q config set color.suggestion "#a8a8a8"
q config set color.description "#666666"
```

### Performance Optimization

Optimize Amazon Q for better performance:

```bash
# Adjust suggestion delay (milliseconds)
q config set suggestion-delay 100

# Limit suggestion count
q config set max-suggestions 10

# Cache management
q cache clear
q cache rebuild
```

### Custom Keybindings

Customize keyboard shortcuts:

```bash
# Configure accept key
q config set key.accept tab

# Configure dismiss key
q config set key.dismiss escape

# Configure navigation keys
q config set key.up "ctrl+p"
q config set key.down "ctrl+n"
```

## Contributing to Completion Specs

Amazon Q's power comes from its community-driven completion specifications. You can contribute new specs or improve existing ones.

### Setting Up Development Environment

```bash
# Clone the repository
git clone https://github.com/withfig/autocomplete.git
cd autocomplete

# Install dependencies
pnpm install

# Create a new spec
pnpm create-spec your-cli-tool

# Enable development mode
pnpm dev
```

### Creating a Simple Completion Spec

Here's an example of a basic completion spec structure:

```typescript
// src/your-tool.ts
const completionSpec: Fig.Spec = {% raw %}{
  name: "your-tool",
  description: "Description of your CLI tool",
  subcommands: [
    {
      name: "start",
      description: "Start the service",
      options: [
        {
          name: "--port",
          description: "Specify port number",
          args: {
            name: "port",
            description: "Port number (1-65535)"
          }
        }
      ]
    }
  ],
  options: [
    {
      name: "--help",
      description: "Show help information"
    }
  ]
}{% endraw %};

export default completionSpec;
```

### Testing Your Contributions

```bash
# Build specifications
pnpm build

# Test your spec
your-tool <tab>

# Run type checking
pnpm test

# Lint and fix issues
pnpm lint:fix
```

## Troubleshooting Common Issues

### Installation Problems

**Issue**: Amazon Q not appearing in terminal
```bash
# Solution: Re-run initialization
q init zsh --force
source ~/.zshrc
```

**Issue**: Permission denied errors
```bash
# Solution: Check and grant permissions
q doctor
```

### Performance Issues

**Issue**: Slow autocomplete suggestions
```bash
# Solution: Clear cache and optimize
q cache clear
q config set suggestion-delay 50
```

**Issue**: High CPU usage
```bash
# Solution: Reduce suggestion count
q config set max-suggestions 5
q config set cache-size 1000
```

### Integration Problems

**Issue**: Not working with specific terminal
```bash
# Solution: Check compatibility
q doctor

# Manual integration
q init bash --force  # or zsh, fish
```

## Best Practices and Pro Tips

### 1. Optimize Your Workflow

- **Learn Common Patterns**: Familiarize yourself with frequently used command patterns
- **Use Fuzzy Matching**: Amazon Q supports fuzzy matching for faster navigation
- **Customize for Your Needs**: Adjust settings based on your specific workflow

### 2. Productivity Shortcuts

```bash
# Quick navigation shortcuts
cd <tab>               # Directory suggestions
cd ../../../<tab>      # Parent directory navigation

# File operations
cp <tab>               # File path completion
mv <tab>               # Source and destination suggestions

# Process management
kill <tab>             # Running process suggestions
ps aux | grep <tab>    # Process name completion
```

### 3. Team Collaboration

- **Share Specs**: Contribute useful completion specs for your team's tools
- **Document Workflows**: Create internal documentation for complex command sequences
- **Standardize Setup**: Use consistent Amazon Q configurations across your team

## Security Considerations

### Data Privacy

Amazon Q operates locally on your machine:
- **No Cloud Processing**: Suggestions are generated locally
- **No Data Collection**: Your commands and files stay on your device
- **Open Source**: Transparent code available for review

### Permission Management

Be mindful of the permissions you grant:
- **Accessibility**: Required for positioning the suggestion window
- **Input Monitoring**: Required for reading your typed commands
- **Minimal Scope**: Amazon Q only accesses what's necessary for autocomplete

## Conclusion

Amazon Q Developer CLI transforms the terminal experience from a memorization-heavy interface to an intuitive, guided environment. By providing intelligent autocomplete for hundreds of CLI tools, it significantly reduces the learning curve for new tools and improves productivity for experienced developers.

The key benefits include:
- **Reduced Cognitive Load**: No need to memorize complex command syntax
- **Faster Command Entry**: Context-aware suggestions speed up typing
- **Learning Accelerator**: Discover new features and options organically
- **Consistent Experience**: Uniform interface across different CLI tools

Start with the basic installation and gradually explore advanced features as you become more comfortable with the tool. The community-driven nature of Amazon Q means it continues to improve with contributions from developers worldwide.

Whether you're a beginner looking to learn command-line tools or an experienced developer seeking to optimize your workflow, Amazon Q Developer CLI offers significant value in making the terminal more accessible and productive.

---

## Additional Resources

- **Official Documentation**: [Amazon Q Developer CLI Docs](https://aws.amazon.com/q/developer/cli/)
- **GitHub Repository**: [withfig/autocomplete](https://github.com/withfig/autocomplete)
- **Community Discussions**: [AWS Q CLI Discussions](https://github.com/aws/q-command-line-discussions)
- **Contributing Guide**: [How to Contribute](https://github.com/withfig/autocomplete/blob/master/CONTRIBUTING.md)
