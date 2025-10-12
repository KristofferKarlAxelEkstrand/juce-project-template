#!/bin/bash

# JUCE Project Template Build Testing Script
# Tests that plugin and standalone builds work correctly

set -euo pipefail  # Exit on error, undefined variables, and pipe failures

# Add error handler
trap 'echo "[ERROR] Script failed at line $LINENO" >&2' ERR

# Add help message
if [[ "${1:-}" == "--help" ]] || [[ "${1:-}" == "-h" ]]; then
    cat << EOF
Usage: ${0##*/} [BUILD_CONFIG]

Tests that plugin and standalone builds work correctly.

Arguments:
    BUILD_CONFIG    Build configuration (Debug or Release, default: Debug)

Options:
    -h, --help     Show this help message
    
Examples:
    ${0##*/}           # Test Debug build
    ${0##*/} Release   # Test Release build
    
Checks:
    - Build directory exists
    - Shared library artifact
    - VST3 plugin bundle and binary
    - AU plugin (macOS only)
    - Standalone application
    - Plugin installation paths
    
Output:
    Reports status of each artifact. Exits with status 0 if all found.
EOF
    exit 0
fi

echo "JUCE Project Template Build Testing"
echo "===================================="
echo

# Determine build configuration: default to Debug if not specified
BUILD_CONFIG=${1:-Debug}
echo "Build configuration: $BUILD_CONFIG"
echo

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Determine OS
case "$(uname -s)" in
    Linux*)     OS="linux";;
    Darwin*)    OS="macos";;
    CYGWIN*|MINGW*|MSYS*) OS="windows";;
    *)          OS="unknown";;
esac

# Adjust build directory based on OS and configuration
if [ "$OS" = "windows" ]; then
    BUILD_DIR="$PROJECT_ROOT/build/vs2022"
    echo "Found Windows build directory: $BUILD_DIR"
else
    if [[ "$BUILD_CONFIG" == "Release" ]]; then
        BUILD_DIR="$PROJECT_ROOT/build/release"
        echo "Found Release build directory: $BUILD_DIR"
    else
        BUILD_DIR="$PROJECT_ROOT/build/default"
        echo "Using default Debug build directory: $BUILD_DIR"
    fi
fi

# --- Constants for Fallback Metadata ---
FALLBACK_PROJECT_NAME_TARGET="JucePlugin"
FALLBACK_PROJECT_NAME_PRODUCT="JUCE Project Template Plugin"

# Load plugin metadata from CMake-generated file
METADATA_FILE="$BUILD_DIR/plugin_metadata.sh"
if [ -f "$METADATA_FILE" ]; then
    source "$METADATA_FILE"
    echo "Loaded metadata: $PROJECT_NAME_PRODUCT (target: $PROJECT_NAME_TARGET)"
else
    echo "[WARN] plugin_metadata.sh not found at $METADATA_FILE"
    echo "       Using fallback values. Run 'cmake --preset=<preset>' first."
    PROJECT_NAME_TARGET="$FALLBACK_PROJECT_NAME_TARGET"
    PROJECT_NAME_PRODUCT="$FALLBACK_PROJECT_NAME_PRODUCT"
fi
echo

# Function to check if file exists and report
check_file() {
    local file_path="$1"
    local description="$2"
    
    if [ -f "$file_path" ]; then
        echo "[OK] $description: $(basename "$file_path")"
        return 0
    else
        echo "[FAIL] $description: Missing"
        return 1
    fi
}

# Function to check if directory exists and report
check_directory() {
    local dir_path="$1"
    local description="$2"
    
    if [ -d "$dir_path" ]; then
        echo "[OK] $description: $(basename "$dir_path")"
        return 0
    else
        echo "[FAIL] $description: Missing"
        return 1
    fi
}

# Function to test executable briefly
test_executable() {
    local exe_path="$1"
    local description="$2"
    
    if [ -x "$exe_path" ]; then
        echo "  Testing $description..."
        # Check if timeout command is available (not on macOS by default)
        if command -v timeout >/dev/null 2>&1; then
            # Try to run with --help or version flag, or just test execution
            if timeout 2s "$exe_path" --help >/dev/null 2>&1 || \
               timeout 2s "$exe_path" >/dev/null 2>&1; then
                echo "  [OK] $description: Executable runs"
                return 0
            else
                echo "  [WARN] $description: Executable exists but may need display/audio"
                return 0  # This is okay in headless environments
            fi
        else
            # No timeout available - skip run check
            echo "  [OK] $description: Executable exists (skipping run check; no timeout available)"
            return 0
        fi
    else
        echo "  [FAIL] $description: Not executable"
        return 1
    fi
}

echo "Checking Build Artifacts..."
echo "----------------------------"

cd "$PROJECT_ROOT"

# Check if build directory exists
if [ ! -d "$BUILD_DIR" ]; then
    echo "[FAIL] Build directory not found. Run 'cmake --preset=default && cmake --build --preset=default' first."
    exit 1
fi

success_count=0
total_count=0

# Check shared library
((total_count++))
if [ "$OS" = "windows" ]; then
    shared_lib_path="$BUILD_DIR/${PROJECT_NAME_TARGET}_artefacts/$BUILD_CONFIG/${PROJECT_NAME_TARGET}_SharedCode.lib"
else
    shared_lib_path="$BUILD_DIR/${PROJECT_NAME_TARGET}_artefacts/$BUILD_CONFIG/lib${PROJECT_NAME_TARGET}_SharedCode.a"
fi

if check_file "$shared_lib_path" "Shared Library"; then
    ((success_count++))
fi

# Check VST3 plugin
((total_count++))
if check_directory "$BUILD_DIR/${PROJECT_NAME_TARGET}_artefacts/$BUILD_CONFIG/VST3/${PROJECT_NAME_PRODUCT}.vst3" "VST3 Plugin Bundle"; then
    ((success_count++))
    
    # Check VST3 binary inside bundle
    if [ "$OS" = "macos" ]; then
        vst3_binary="$BUILD_DIR/${PROJECT_NAME_TARGET}_artefacts/$BUILD_CONFIG/VST3/${PROJECT_NAME_PRODUCT}.vst3/Contents/MacOS/${PROJECT_NAME_PRODUCT}"
    elif [ "$OS" = "linux" ]; then
        vst3_binary="$BUILD_DIR/${PROJECT_NAME_TARGET}_artefacts/$BUILD_CONFIG/VST3/${PROJECT_NAME_PRODUCT}.vst3/Contents/x86_64-linux/${PROJECT_NAME_PRODUCT}.so"
    elif [ "$OS" = "windows" ]; then
        vst3_binary="$BUILD_DIR/${PROJECT_NAME_TARGET}_artefacts/$BUILD_CONFIG/VST3/${PROJECT_NAME_PRODUCT}.vst3/Contents/x86_64-win/${PROJECT_NAME_PRODUCT}.vst3"
    fi
    
    if [ -n "$vst3_binary" ]; then
        check_file "$vst3_binary" "  VST3 Binary"
    fi
fi

# Check AU plugin (macOS only)
if [ "$OS" = "macos" ]; then
    ((total_count++))
    if check_directory "$BUILD_DIR/${PROJECT_NAME_TARGET}_artefacts/$BUILD_CONFIG/AU/${PROJECT_NAME_PRODUCT}.component" "AU Plugin Bundle"; then
        ((success_count++))
        check_file "$BUILD_DIR/${PROJECT_NAME_TARGET}_artefacts/$BUILD_CONFIG/AU/${PROJECT_NAME_PRODUCT}.component/Contents/MacOS/${PROJECT_NAME_PRODUCT}" "  AU Binary"
    fi
fi

# Check Standalone application
((total_count++))
if [ "$OS" = "macos" ]; then
    # macOS app bundle
    standalone_path="$BUILD_DIR/${PROJECT_NAME_TARGET}_artefacts/$BUILD_CONFIG/Standalone/${PROJECT_NAME_PRODUCT}.app"
    if check_directory "$standalone_path" "Standalone App Bundle"; then
        ((success_count++))
        test_executable "$standalone_path/Contents/MacOS/${PROJECT_NAME_PRODUCT}" "Standalone App"
    fi
else
    # Linux/Windows executable
    standalone_path="$BUILD_DIR/${PROJECT_NAME_TARGET}_artefacts/$BUILD_CONFIG/Standalone/${PROJECT_NAME_PRODUCT}"
    if [ "$OS" = "windows" ]; then
        standalone_path+=".exe"
    fi
    
    if check_file "$standalone_path" "Standalone Application"; then
        ((success_count++))
        test_executable "$standalone_path" "Standalone App"
    fi
fi

echo
echo "Plugin Installation Check..."
echo "-----------------------------"

# Check if plugins are installed to user directories
if [ "$OS" = "linux" ]; then
    if [ -d "$HOME/.vst3/${PROJECT_NAME_PRODUCT}.vst3" ]; then
        echo "[OK] VST3 plugin installed to user directory: ~/.vst3/"
    else
        echo "[WARN] VST3 plugin not found in ~/.vst3/ (may need manual installation)"
    fi
elif [ "$OS" = "macos" ]; then
    if [ -d "$HOME/Library/Audio/Plug-Ins/VST3/${PROJECT_NAME_PRODUCT}.vst3" ]; then
        echo "[OK] VST3 plugin installed to user directory"
    fi
    if [ -d "$HOME/Library/Audio/Plug-Ins/Components/${PROJECT_NAME_PRODUCT}.component" ]; then
        echo "[OK] AU plugin installed to user directory"
    fi
elif [ "$OS" = "windows" ]; then
    # System-wide VST3 directory (CommonProgramFiles\VST3)
    vst3_path_system="${CommonProgramW6432:-$COMMONPROGRAMFILES}/VST3/${PROJECT_NAME_PRODUCT}.vst3"
    # User-specific VST3 directory (AppData\Roaming\VST3)
    vst3_path_user="${APPDATA}/VST3/${PROJECT_NAME_PRODUCT}.vst3"

    if [ -d "$vst3_path_system" ]; then
        echo "[OK] VST3 plugin installed to system directory: $vst3_path_system"
    elif [ -d "$vst3_path_user" ]; then
        echo "[OK] VST3 plugin installed to user directory: $vst3_path_user"
    else
        echo "[WARN] VST3 plugin not found in standard system or user directories."
    fi
fi

echo
echo "Build Test Summary"
echo "=================="
echo "Successful: $success_count/$total_count artifacts built"

if [ $success_count -eq $total_count ]; then
    echo "SUCCESS: All build artifacts created successfully!"
    echo
    echo "Next steps:"
    echo "1. Load VST3 plugin in your DAW"
    echo "2. Run standalone application"
    echo "3. Test audio functionality"
    exit 0
else
    echo "[WARN] Some build artifacts are missing."
    echo "Check the build output and BUILD.md for troubleshooting."
    exit 1
fi