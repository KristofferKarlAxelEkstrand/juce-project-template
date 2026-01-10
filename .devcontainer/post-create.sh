#!/bin/bash
# .devcontainer/post-create.sh
# Post-creation setup script for JUCE development container
set -euo pipefail

echo "Setting up JUCE development environment..."

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

# Verify MinGW is available for cross-compilation
if command -v x86_64-w64-mingw32-g++-posix &> /dev/null; then
    echo "MinGW-w64 available for Windows cross-compilation"
    echo "  Configure with: cmake --preset=mingw64"
else
    echo "Warning: MinGW-w64 not found, Windows cross-compilation unavailable"
fi

echo ""
echo "Dev container setup complete."
echo ""
echo "Build commands:"
echo "  Linux:   cmake --build --preset=ninja"
echo "  Windows: cmake --preset=mingw64 && cmake --build --preset=mingw64"
