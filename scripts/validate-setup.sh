#!/bin/bash

# JUCE Project Template Setup Validation Script
# This script validates that the development environment is properly configured

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

# --- Help Message ---
HELP_MESSAGE=$(cat << EOF
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
)
show_help "${1:-}" "$HELP_MESSAGE"

info "JUCE Project Template Setup Validation"
echo "============================="
echo

# Check required tools
info "Checking Required Tools..."
echo "-------------------------------"

command_exists cmake && success "CMake found: $(cmake --version | head -n1)" || { error "CMake not found"; exit 1; }
if [[ "$OSTYPE" != "msys" && "$OSTYPE" != "cygwin" ]]; then
    command_exists g++ && success "GCC found: $(g++ --version | head -n1)" || { error "GCC not found"; exit 1; }
    command_exists make && success "Make found: $(make --version | head -n1)" || { error "Make not found"; exit 1; }
fi
command_exists node && success "Node.js found: $(node --version)" || { error "Node.js not found"; exit 1; }
command_exists npm && success "NPM found: $(npm --version)" || { error "NPM not found"; exit 1; }

echo

# Check Linux audio dependencies
 if [[ "$OSTYPE" == "linux-gnu"* ]]; then
-    echo "🔊 Checking Linux Audio Dependencies..."
+    info "Checking Linux Audio Dependencies..."
    echo "--------------------------------------"
    
    pkg-config --exists alsa && success "ALSA development libraries found" || { error "ALSA development libraries missing"; exit 1; }
    pkg-config --exists x11 && success "X11 development libraries found" || { error "X11 development libraries missing"; exit 1; }
    pkg-config --exists freetype2 && success "FreeType development libraries found" || { error "FreeType development libraries missing"; exit 1; }
    pkg-config --exists fontconfig && success "FontConfig development libraries found" || { error "FontConfig development libraries missing"; exit 1; }
    
    echo
fi

# Check project files
info "Checking Project Structure..."
echo "--------------------------------"

[ -f "CMakeLists.txt" ] && success "CMakeLists.txt found" || { error "CMakeLists.txt missing"; exit 1; }
[ -f "CMakePresets.json" ] && success "CMakePresets.json found" || { error "CMakePresets.json missing"; exit 1; }
[ -f "package.json" ] && success "package.json found" || { error "package.json missing"; exit 1; }
[ -d "src" ] && success "src/ directory found" || { error "src/ directory missing"; exit 1; }
[ -d ".github/workflows" ] && success ".github/workflows/ directory found" || { error ".github/workflows/ directory missing"; exit 1; }

echo

# Test NPM setup
info "Testing NPM Setup..."
echo "-----------------------"

if [ -d "node_modules" ]; then
    success "Node modules directory exists"
else
    info "Installing NPM dependencies..."
    npm install && success "NPM dependencies installed" || { error "NPM install failed"; exit 1; }
fi

npm test && success "Documentation linting passed" || { error "Documentation linting failed"; exit 1; }

echo

# Test CMake configuration
info "Testing CMake Configuration..."
echo "--------------------------------"

# Determine preset based on OS
case "$(uname -s)" in
    CYGWIN*|MINGW*|MSYS*)
        preset="vs2022"
        ;;
    *)
        preset="default"
        ;;
esac


# Try to configure with the determined preset
info "Attempting to configure with CMake using preset '$preset'..."
if cmake --preset="$preset" >/dev/null 2>&1; then
    success "CMake configuration successful"
    
    build_dir="build/$preset"
    # Check if we can generate build files
    if [ "$preset" = "vs2022" ]; then
        # On Windows, check for the solution file
        if [ -d "$build_dir" ] && [ -f "$build_dir/JuceProject.sln" ]; then
            success "Build files generated successfully"
        else
            error "Build files not generated properly"
            exit 1
        fi
    else
        # On Linux/macOS, check for the Makefile
        if [ -d "$build_dir" ] && [ -f "$build_dir/Makefile" ]; then
            success "Build files generated successfully"
        else
            error "Build files not generated properly"
            exit 1
        fi
    fi
else
    error "CMake configuration failed"
    warn "  Note: This may be due to missing system dependencies"
    warn "  Note: Check the BUILD.md for platform-specific requirements"
    exit 1
fi

echo

# Summary
info "✅ Validation Summary"
echo "===================="
success "If all items above show [SUCCESS], your development environment is ready!"
echo
info "Next steps:"
echo "1. Run: cmake --preset=default"
echo "2. Run: cmake --build --preset=default"
echo "3. Run the built application from the build/default/JucePlugin_artefacts/Debug/Standalone directory"
echo
info "For help, see QUICKSTART.md or open an issue on GitHub."
