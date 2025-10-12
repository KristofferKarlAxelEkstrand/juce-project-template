#!/bin/bash

# DSP-JUCE Setup Validation Script
# This script validates that the development environment is properly configured

set -euo pipefail  # Exit on error, undefined variables, and pipe failures

# Add error handler
trap 'echo "[ERROR] Script failed at line $LINENO" >&2' ERR

# Add help message
if [[ "${1:-}" == "--help" ]] || [[ "${1:-}" == "-h" ]]; then
    cat << EOF
Usage: ${0##*/} [OPTIONS]

Validates the development environment is properly configured for JUCE development.

Options:
    -h, --help      Show this help message
    
Examples:
    ${0##*/}
    
Checks:
    - Required tools (CMake, GCC, Make, Node.js, NPM)
    - Linux audio dependencies (ALSA, X11, FreeType, FontConfig)
    - Project structure (CMakeLists.txt, source files, configs)
    - NPM setup and documentation linting
    - CMake configuration test
    
Output:
    Reports status of each check. Exit code 0 if environment is ready.
EOF
    exit 0
fi

echo "🔧 DSP-JUCE Setup Validation"
echo "============================="
echo

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to print status
print_status() {
    if [ $1 -eq 0 ]; then
        echo "✅ $2"
    else
        echo "❌ $2"
        return 1
    fi
}

# Check required tools
echo "📋 Checking Required Tools..."
echo "-------------------------------"

command_exists cmake && print_status 0 "CMake found: $(cmake --version | head -n1)" || print_status 1 "CMake not found"
command_exists g++ && print_status 0 "GCC found: $(g++ --version | head -n1)" || print_status 1 "GCC not found"
command_exists make && print_status 0 "Make found: $(make --version | head -n1)" || print_status 1 "Make not found"
command_exists node && print_status 0 "Node.js found: $(node --version)" || print_status 1 "Node.js not found"
command_exists npm && print_status 0 "NPM found: $(npm --version)" || print_status 1 "NPM not found"

echo

# Check Linux audio dependencies
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "🔊 Checking Linux Audio Dependencies..."
    echo "--------------------------------------"
    
    pkg-config --exists alsa && print_status 0 "ALSA development libraries found" || print_status 1 "ALSA development libraries missing"
    pkg-config --exists x11 && print_status 0 "X11 development libraries found" || print_status 1 "X11 development libraries missing"
    pkg-config --exists freetype2 && print_status 0 "FreeType development libraries found" || print_status 1 "FreeType development libraries missing"
    pkg-config --exists fontconfig && print_status 0 "FontConfig development libraries found" || print_status 1 "FontConfig development libraries missing"
    
    echo
fi

# Check project files
echo "📁 Checking Project Structure..."
echo "--------------------------------"

[ -f "CMakeLists.txt" ] && print_status 0 "CMakeLists.txt found" || print_status 1 "CMakeLists.txt missing"
[ -f "CMakePresets.json" ] && print_status 0 "CMakePresets.json found" || print_status 1 "CMakePresets.json missing"
[ -f "package.json" ] && print_status 0 "package.json found" || print_status 1 "package.json missing"
[ -f ".clang-format" ] && print_status 0 ".clang-format found" || print_status 1 ".clang-format missing"
[ -d "src" ] && print_status 0 "src/ directory found" || print_status 1 "src/ directory missing"
[ -d ".github/workflows" ] && print_status 0 ".github/workflows/ directory found" || print_status 1 ".github/workflows/ directory missing"

echo

# Test NPM setup
echo "📦 Testing NPM Setup..."
echo "-----------------------"

if [ -d "node_modules" ]; then
    print_status 0 "Node modules directory exists"
else
    echo "Installing NPM dependencies..."
    npm install && print_status 0 "NPM dependencies installed" || print_status 1 "NPM install failed"
fi

npm test && print_status 0 "Documentation linting passed" || print_status 1 "Documentation linting failed"

echo

# Test CMake configuration
echo "🔨 Testing CMake Configuration..."
echo "--------------------------------"

# Clean any previous build
rm -rf build

# Try to configure with default preset
if cmake --preset=default >/dev/null 2>&1; then
    print_status 0 "CMake configuration successful"
    
    # Check if we can generate build files
    if [ -d "build" ] && [ -f "build/Makefile" ]; then
        print_status 0 "Build files generated successfully"
    else
        print_status 1 "Build files not generated properly"
    fi
else
    print_status 1 "CMake configuration failed"
    echo "  ℹ️  This may be due to missing system dependencies"
    echo "  ℹ️  Check the README.md for platform-specific requirements"
fi

echo

# Summary
echo "📊 Validation Summary"
echo "===================="
echo "If all items above show ✅, your development environment is ready!"
echo "If any items show ❌, please install the missing dependencies."
echo
echo "Next steps:"
echo "1. Fix any missing dependencies shown above"
echo "2. Run: cmake --preset=default"
echo "3. Run: cmake --build --preset=default"
echo "4. Run the built application"
echo
echo "For help, see README.md or open an issue on GitHub."