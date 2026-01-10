#!/bin/bash
# .devcontainer/post-create.sh
# Post-creation setup script for JUCE development container
set -euo pipefail

echo "Setting up JUCE development environment..."

# Configure git safe directories to prevent "unsafe repository" errors
# This is needed because the workspace and fetched dependencies may be
# owned by different users in container environments
echo "Configuring git safe directories..."
git config --global --add safe.directory /workspaces/juce-project-template
git config --global --add safe.directory '*'

# Fix ccache directory ownership if mounted as volume
if [ -d "$HOME/.ccache" ]; then
    sudo chown -R "$(id -u):$(id -g)" "$HOME/.ccache"
fi

# Enable VS Code shell integration for improved command detection
# This enables features like command decorations, navigation, and sticky scroll
# See: https://code.visualstudio.com/docs/terminal/shell-integration
ZSHRC="$HOME/.zshrc"
if [ -f "$ZSHRC" ] && ! grep -q "TERM_PROGRAM.*vscode" "$ZSHRC"; then
    echo "" >> "$ZSHRC"
    echo "# VS Code shell integration" >> "$ZSHRC"
    echo '[[ "$TERM_PROGRAM" == "vscode" ]] && . "$(code --locate-shell-integration-path zsh)"' >> "$ZSHRC"
    echo "Added VS Code shell integration to .zshrc"
fi

# Update npm to latest version
echo "Updating npm to latest version..."
npm install -g npm@latest

# Install npm dependencies for linting tools
# Skip husky install in devcontainer (hooks are already committed to .husky/)
if [ -f "package.json" ]; then
    echo "Installing npm dependencies..."
    HUSKY=0 npm install
fi

# Initialize git submodules if not already done
if [ -f ".gitmodules" ] && [ ! -f "third_party/JUCE/CMakeLists.txt" ]; then
    echo "Initializing git submodules..."
    git submodule update --init --recursive
fi

# Configure with Ninja preset for fast builds
echo "Configuring CMake with Ninja..."
cmake --preset=ninja

echo ""
echo "Dev container setup complete."
echo ""
echo "Build commands:"
echo "  cmake --build --preset=ninja"
echo ""
echo "Note: Windows builds require GitHub Actions CI or a Windows machine with Visual Studio."
