#!/bin/bash

# JUCE Project Template Build Validation Script
# Validates that plugin and standalone builds exist.

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

# --- Help Message ---
HELP_MESSAGE=$(cat << EOF
Usage: ${0##*/} [BUILD_CONFIG] [BUILD_DIR_OVERRIDE]

Validates that plugin and standalone builds exist in the expected locations.

Arguments:
    BUILD_CONFIG         Build configuration (Debug or Release, default: Debug)
    BUILD_DIR_OVERRIDE   Optional: Override build directory (used by CI)

Options:
    -h, --help          Show this help message
    
Examples:
    ${0##*/}                    # Validate Debug build
    ${0##*/} Release            # Validate Release build
    ${0##*/} Debug /custom/dir  # Validate with custom build directory
    
Output:
    Checks for VST3 plugin, standalone app, and shared library artifacts.
    Exits with status 0 if all critical artifacts found, 1 otherwise.
EOF
)
show_help "${1:-}" "$HELP_MESSAGE"

info "JUCE Project Template Build Validation"
echo "======================================="
echo

# --- Configuration ---
BUILD_CONFIG=${1:-Debug}
OVERRIDE_BUILD_DIR=${2:-}  # Optional: override build directory from CI
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# --- OS Detection ---
case "$(uname -s)" in
    Linux*)     OS="linux";;
    Darwin*)    OS="macos";;
    CYGWIN*|MINGW*|MSYS*) OS="windows";;
    *)          OS="unknown";;
esac

# --- Path Definitions ---
if [ -n "$OVERRIDE_BUILD_DIR" ]; then
    # Use build directory provided by CI workflow
    case "$OVERRIDE_BUILD_DIR" in
        /*) BUILD_DIR="$OVERRIDE_BUILD_DIR" ;;  # Absolute path (Unix)
        [A-Za-z]:[\\/]*) BUILD_DIR="$OVERRIDE_BUILD_DIR" ;;  # Absolute path (Windows)
        *) BUILD_DIR="$PROJECT_ROOT/build/$OVERRIDE_BUILD_DIR" ;;  # Relative path
    esac
elif [ "$OS" = "windows" ]; then
    # Prefer Ninja build on Windows, fallback to vs2022 if not available
    if [ -d "$PROJECT_ROOT/build/ninja" ]; then
        BUILD_DIR="$PROJECT_ROOT/build/ninja"
    else
        BUILD_DIR="$PROJECT_ROOT/build/vs2022"
    fi
else
    # On Linux/macOS, preset name matches the lowercase build config, but 'Debug' uses the 'default' preset.
    if [ "$BUILD_CONFIG" = "Debug" ]; then
        preset_name="default"
    else
        preset_name=$(echo "$BUILD_CONFIG" | tr '[:upper:]' '[:lower:]')
    fi
    BUILD_DIR="$PROJECT_ROOT/build/$preset_name"
fi

# --- Constants for Fallback Metadata ---
FALLBACK_PROJECT_NAME_TARGET="JucePlugin"
FALLBACK_PROJECT_NAME_PRODUCT="JUCE Project Template Plugin"
FALLBACK_PROJECT_VERSION="1.0.0"
FALLBACK_PROJECT_COMPANY="MyCompany"

# --- Load Plugin Metadata from CMake ---
METADATA_FILE="$BUILD_DIR/plugin_metadata.sh"
# shellcheck source=./metadata-utils.sh
source "$(dirname "${BASH_SOURCE[0]}")/metadata-utils.sh"

set_fallback_metadata() {
    export PROJECT_NAME_TARGET="$FALLBACK_PROJECT_NAME_TARGET"
    export PROJECT_NAME_PRODUCT="$FALLBACK_PROJECT_NAME_PRODUCT"
    export PROJECT_VERSION="$FALLBACK_PROJECT_VERSION"
    export PROJECT_COMPANY="$FALLBACK_PROJECT_COMPANY"
}

if [ -f "$METADATA_FILE" ]; then
    if extract_metadata_vars "$METADATA_FILE" PROJECT_NAME_PRODUCT PROJECT_VERSION PROJECT_COMPANY PROJECT_NAME_TARGET; then
        echo "Plugin: $PROJECT_NAME_PRODUCT v$PROJECT_VERSION"
        echo "Company: $PROJECT_COMPANY"
    else
        echo "Warning: Failed to extract metadata from $METADATA_FILE. Using fallback values."
        set_fallback_metadata
    fi
else
    # Fallback to hardcoded values if CMake hasn't run yet
    echo "Warning: CMake metadata file not found at $METADATA_FILE"
    if [ "$OS" = "windows" ]; then
        echo "   Run 'cmake --preset=vs2022' first to generate metadata."
    else
        echo "   Run 'cmake --preset=<preset>' first to generate metadata."
    fi
    echo "   Using fallback values for validation..."
    set_fallback_metadata
fi

echo
ARTEFACTS_DIR="$BUILD_DIR/${PROJECT_NAME_TARGET}_artefacts/$BUILD_CONFIG"

echo "Configuration: $BUILD_CONFIG on $OS"
echo "Project Root: $PROJECT_ROOT"
echo "Build Directory: $BUILD_DIR"
echo "Artefacts Directory: $ARTEFACTS_DIR"
echo

# --- Validation Functions ---
check_exists() {
    local path="$1"
    local description="$2"
    local type_flag="$3" # -f for file, -d for directory

    if [ "$type_flag" "$path" ]; then
        echo "[OK] $description: Found"
        return 0
    else
        echo "[FAIL] $description: Missing at '$path'"
        return 1
    fi
}

# --- Main Execution ---
echo "Starting validation..."

if ! check_exists "$ARTEFACTS_DIR" "Artefacts directory" -d; then
    exit 1
fi

declare -a missing_artifacts=()
declare -a missing_optional_artifacts=()

# --- Artefact Checks ---
# Shared Library (optional - internal build artifact)
if [ "$OS" = "windows" ]; then
    # Windows uses target name for SharedCode library (no spaces in filename)
    shared_lib_path="$ARTEFACTS_DIR/${PROJECT_NAME_TARGET}_SharedCode.lib"
else
    shared_lib_path="$ARTEFACTS_DIR/lib${PROJECT_NAME_TARGET}_SharedCode.a"
fi
check_exists "$shared_lib_path" "Shared Library (optional)" -f || missing_optional_artifacts+=("Shared Library")

# VST3 Plugin
vst3_bundle_path="$ARTEFACTS_DIR/VST3/${PROJECT_NAME_PRODUCT}.vst3"
check_exists "$vst3_bundle_path" "VST3 Plugin" -d || missing_artifacts+=("VST3 Plugin")

# Standalone Application
if [ "$OS" = "macos" ]; then
    standalone_path="$ARTEFACTS_DIR/Standalone/${PROJECT_NAME_PRODUCT}.app"
    check_exists "$standalone_path" "Standalone App" -d || missing_artifacts+=("Standalone App")
else
    standalone_path="$ARTEFACTS_DIR/Standalone/${PROJECT_NAME_PRODUCT}"
    [ "$OS" = "windows" ] && standalone_path+=".exe"
    check_exists "$standalone_path" "Standalone App" -f || missing_artifacts+=("Standalone App")
fi

# AU Plugin (macOS only)
if [ "$OS" = "macos" ]; then
    au_bundle_path="$ARTEFACTS_DIR/AU/${PROJECT_NAME_PRODUCT}.component"
    if check_exists "$au_bundle_path" "AU Plugin" -d; then
        : # AU plugin found, all good
    else
        # AU plugin missing - check if we should treat as fatal
        if [ "${ALLOW_MISSING_AU:-false}" = "true" ]; then
            echo "Warning: AU Plugin missing but ALLOW_MISSING_AU is set - continuing"
            missing_optional_artifacts+=("AU Plugin")
        else
            missing_artifacts+=("AU Plugin")
        fi
    fi
fi

# --- Summary ---
echo
echo "Build Test Summary"
echo "=================="
# Use safe array existence/length checks to avoid unbound variable errors
if [ "${missing_artifacts[@]+x}" ] && [ ${#missing_artifacts[@]} -gt 0 ]; then
    echo "ERROR: Critical build artifacts are missing: ${missing_artifacts[*]}"
    exit 1
elif [ "${missing_optional_artifacts[@]+x}" ] && [ ${#missing_optional_artifacts[@]} -gt 0 ]; then
    echo "Warning: Optional artifacts missing (not fatal): ${missing_optional_artifacts[*]}"
    echo "SUCCESS: All critical build artifacts found successfully!"
    exit 0
else
    echo "SUCCESS: All expected build artifacts found successfully!"
    exit 0
fi

