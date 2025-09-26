#!/bin/bash
set -e

echo "🚀 Installing git-commit script from theDevOli/git-commit..."

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
    print_color $BLUE "║                   git-commit Installer                       ║"
    print_color $BLUE "║                 https://github.com/theDevOli/git-commit      ║"
    print_color $BLUE "╚══════════════════════════════════════════════════════════════╝"
    echo
}

print_banner

# Check if curl is available
if ! command -v curl &> /dev/null; then
    print_color $RED "❌ Error: curl is required but not installed."
    print_color $YELLOW "💡 Install curl with: sudo apt-get install curl (Ubuntu) or brew install curl (macOS)"
    exit 1
fi

# Check if git is available
if ! command -v git &> /dev/null; then
    print_color $RED "❌ Error: Git is required but not installed."
    exit 1
fi

# Download the script
print_color $YELLOW "📥 Downloading git-commit script..."
if ! curl -sSL -o /tmp/git-commit.sh "https://raw.githubusercontent.com/theDevOli/git-commit/main/git-commit.sh"; then
    print_color $RED "❌ Failed to download script. Please check your internet connection."
    exit 1
fi

# Verify the download
if [[ ! -s /tmp/git-commit.sh ]]; then
    print_color $RED "❌ Downloaded file is empty. Please try again."
    exit 1
fi

# Make executable
chmod +x /tmp/git-commit.sh

# Determine install location
INSTALL_DIR=""
if [[ -w /usr/local/bin ]]; then
    INSTALL_DIR="/usr/local/bin"
    print_color $GREEN "📦 Installing system-wide to /usr/local/bin/"
elif [[ -w ~/.local/bin ]]; then
    INSTALL_DIR="$HOME/.local/bin"
    mkdir -p "$INSTALL_DIR"
    print_color $GREEN "📦 Installing to user directory ~/.local/bin/"
else
    INSTALL_DIR="$HOME/bin"
    mkdir -p "$INSTALL_DIR"
    print_color $GREEN "📦 Installing to ~/bin/"
fi

# Install the script
if cp /tmp/git-commit.sh "$INSTALL_DIR/git-commit"; then
    print_color $GREEN "✅ Script installed successfully to $INSTALL_DIR/git-commit"
else
    print_color $RED "❌ Failed to install script. Please check permissions."
    exit 1
fi

# Clean up
rm -f /tmp/git-commit.sh

# Check if install directory is in PATH
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    print_color $YELLOW "⚠️  Note: $INSTALL_DIR is not in your PATH."
    print_color $YELLOW "💡 Add this to your shell profile (~/.bashrc, ~/.zshrc, or ~/.profile):"
    echo "    export PATH=\"\$PATH:$INSTALL_DIR\""
    echo "    Then run: source ~/.bashrc (or your shell config file)"
fi

# Check for spell checker
if ! command -v aspell &> /dev/null && ! command -v hunspell &> /dev/null; then
    print_color $YELLOW "💡 Optional: Install spell checker for enhanced features:"
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "    sudo apt-get install aspell aspell-en"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "    brew install aspell"
    elif [[ "$OSTYPE" == "freebsd"* ]]; then
        echo "    pkg install aspell"
    fi
    echo
fi

# Test installation
print_color $YELLOW "🔍 Testing installation..."
if command -v git-commit &> /dev/null; then
    print_color $GREEN "✅ Installation verified!"
    echo
    print_color $BLUE "🎉 Installation complete! You can now use:"
    print_color $GREEN "   git-commit --help"
    print_color $GREEN "   git-commit -i"
    echo
    print_color $YELLOW "📚 For usage examples, visit:"
    print_color $BLUE "   https://github.com/theDevOli/git-commit"
else
    print_color $YELLOW "⚠️  Script installed but may not be in PATH. Try:"
    print_color $GREEN "   $INSTALL_DIR/git-commit --help"
fi

echo
print_color $BLUE "╔══════════════════════════════════════════════════════════════╗"
print_color $BLUE "║                    Installation Complete!                    ║"
print_color $BLUE "╚══════════════════════════════════════════════════════════════╝"
echo