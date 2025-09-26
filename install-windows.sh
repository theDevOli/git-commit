#!/bin/bash
set -e

echo "🚀 Installing git-commit script for Windows..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_color() {
    echo -e "${1}${2}${NC}"
}

print_banner() {
    echo
    print_color $BLUE "╔══════════════════════════════════════════════════════════════╗"
    print_color $BLUE "║              git-commit Windows Installer                    ║"
    print_color $BLUE "║            https://github.com/theDevOli/git-commit           ║"
    print_color $BLUE "╚══════════════════════════════════════════════════════════════╝"
    echo
}

print_banner

# Detect environment
if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
    # Git Bash environment
    print_color $GREEN "🔧 Detected Git Bash environment"
    
    INSTALL_DIR="/usr/local/bin"
    
    # Download the script
    print_color $YELLOW "📥 Downloading git-commit script..."
    if ! curl -sSL -o /tmp/git-commit.sh "https://raw.githubusercontent.com/theDevOli/git-commit/main/git-commit.sh"; then
        print_color $RED "❌ Failed to download script. Please check your internet connection."
        exit 1
    fi
    
    # Make executable and install
    chmod +x /tmp/git-commit.sh
    mv /tmp/git-commit.sh "$INSTALL_DIR/git-commit"
    
    print_color $GREEN "✅ Installation complete!"
    echo
    print_color $BLUE "🎉 You can now use:"
    print_color $GREEN "   git-commit --help"
    print_color $GREEN "   git-commit -i"
    echo
    
elif [[ "$OSTYPE" == "linux-gnu"* ]] && grep -q microsoft /proc/version 2>/dev/null; then
    # WSL environment
    print_color $GREEN "🔧 Detected WSL environment"
    print_color $YELLOW "📥 Running Linux installer..."
    
    # Download and run Linux installer
    if ! curl -sSL "https://raw.githubusercontent.com/theDevOli/git-commit/main/install.sh" | bash; then
        print_color $RED "❌ Installation failed."
        exit 1
    fi
    
else
    print_color $RED "❌ Unsupported environment detected."
    echo
    print_color $YELLOW "💡 This script is designed for:"
    print_color $GREEN "   - Git Bash (Windows)"
    print_color $GREEN "   - WSL (Windows Subsystem for Linux)"
    echo
    print_color $YELLOW "📥 Download Git for Windows from:"
    print_color $BLUE "   https://git-scm.com/download/win"
    echo
    print_color $YELLOW "🚀 Then run this script again in Git Bash."
    exit 1
fi

echo
print_color $BLUE "╔══════════════════════════════════════════════════════════════╗"
print_color $BLUE "║                    Installation Complete!                    ║"
print_color $BLUE "╚══════════════════════════════════════════════════════════════╝"
echo