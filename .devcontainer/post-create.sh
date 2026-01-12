#!/bin/bash
# .devcontainer/post-create.sh
# Post-creation setup script for JUCE development container
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Setting up JUCE development environment..."

# Load local environment variables if .env exists
if [ -f "$SCRIPT_DIR/.env" ]; then
    echo "Loading environment from .devcontainer/.env..."
    # shellcheck source=/dev/null
    source "$SCRIPT_DIR/.env"
fi

# Configure git identity if provided via .env
if [ -n "${GIT_USER_NAME:-}" ] && [ -n "${GIT_USER_EMAIL:-}" ]; then
    echo "Configuring git identity..."
    git config --global user.name "$GIT_USER_NAME"
    git config --global user.email "$GIT_USER_EMAIL"
else
    echo "Note: Git identity not configured. Copy .devcontainer/.env.example to .devcontainer/.env"
fi

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
if [ -f "$ZSHRC" ] && ! grep -q "VSCODE_SHELL_INTEGRATION" "$ZSHRC"; then
    echo "" >> "$ZSHRC"
    echo "# VS Code shell integration for improved command detection" >> "$ZSHRC"
    echo "# Provides command decorations, navigation between commands, and sticky scroll" >> "$ZSHRC"
    cat >> "$ZSHRC" << 'EOF'
if [[ "$TERM_PROGRAM" == "vscode" ]]; then
    if [[ -n "${VSCODE_SHELL_INTEGRATION:-}" ]]; then
        # VS Code automatically injects shell integration script path
        . "$VSCODE_SHELL_INTEGRATION"
    elif command -v code &>/dev/null; then
        # Fallback: locate shell integration via code CLI
        VSCODE_ZSH_INTEGRATION="$(code --locate-shell-integration-path zsh 2>/dev/null)"
        [[ -f "$VSCODE_ZSH_INTEGRATION" ]] && . "$VSCODE_ZSH_INTEGRATION"
    fi
fi
EOF
    echo "Added VS Code shell integration to .zshrc"
fi

# Also configure bash shell integration for users who prefer bash
BASHRC="$HOME/.bashrc"
if [ -f "$BASHRC" ] && ! grep -q "VSCODE_SHELL_INTEGRATION" "$BASHRC"; then
    echo "" >> "$BASHRC"
    echo "# VS Code shell integration for improved command detection" >> "$BASHRC"
    cat >> "$BASHRC" << 'EOF'
if [[ "$TERM_PROGRAM" == "vscode" ]]; then
    if [[ -n "${VSCODE_SHELL_INTEGRATION:-}" ]]; then
        . "$VSCODE_SHELL_INTEGRATION"
    elif command -v code &>/dev/null; then
        VSCODE_BASH_INTEGRATION="$(code --locate-shell-integration-path bash 2>/dev/null)"
        [[ -f "$VSCODE_BASH_INTEGRATION" ]] && . "$VSCODE_BASH_INTEGRATION"
    fi
fi
EOF
    echo "Added VS Code shell integration to .bashrc"
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

# Clean stale CMake caches (from different source paths, e.g., Windows vs container)
if [ -f "build/ninja/CMakeCache.txt" ]; then
    CACHED_SOURCE=$(grep "CMAKE_HOME_DIRECTORY:INTERNAL=" build/ninja/CMakeCache.txt 2>/dev/null | cut -d= -f2)
    if [ -n "$CACHED_SOURCE" ] && [ "$CACHED_SOURCE" != "/workspaces/juce-project-template" ]; then
        echo "Cleaning stale CMake cache (was: $CACHED_SOURCE)..."
        rm -rf build/ninja
    fi
fi

# Configure with Ninja preset for fast builds
echo "Configuring CMake with Ninja..."
cmake --preset=ninja

echo ""
echo "Dev container setup complete."
echo ""
echo "Build commands:"
echo "  cmake --build --preset=ninja         # Fast debug build"
echo "  cmake --build --preset=ninja-release # Release build"
echo ""
echo "Static analysis:"
echo "  ./scripts/run-clang-tidy.sh          # Run clang-tidy"
echo "  ./scripts/run-cppcheck.sh            # Run cppcheck"
echo "  ./scripts/run-static-analysis.sh     # Run all analysis"
echo ""
echo "Sanitizer builds (runtime error detection):"
echo "  ./scripts/run-with-sanitizer.sh asan # AddressSanitizer"
echo "  ./scripts/run-with-sanitizer.sh ubsan # UndefinedBehaviorSanitizer"
echo "  ./scripts/run-with-sanitizer.sh tsan # ThreadSanitizer"
echo ""
echo "Note: Windows builds require GitHub Actions CI or a Windows machine with Visual Studio."
