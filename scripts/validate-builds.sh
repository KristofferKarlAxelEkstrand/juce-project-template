#!/bin/bash

# DSP-JUCE Build Validation Script
# Validates that plugin and standalone builds exist.

set -e

echo "🧪 DSP-JUCE Build Validation"
echo "============================"
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
    BUILD_DIR="$OVERRIDE_BUILD_DIR"
elif [ "$OS" = "windows" ]; then
    BUILD_DIR="$PROJECT_ROOT/build/vs2022"
else
    preset_name=$(echo "$BUILD_CONFIG" | tr '[:upper:]' '[:lower:]')
    BUILD_DIR="$PROJECT_ROOT/build/$preset_name"
fi

# --- Load Plugin Metadata from CMake ---
METADATA_FILE="$BUILD_DIR/plugin_metadata.sh"
if [ -f "$METADATA_FILE" ]; then
    source "$METADATA_FILE"
    echo "📦 Plugin: $PROJECT_NAME_PRODUCT v$PROJECT_VERSION"
    echo "🏢 Company: $PROJECT_COMPANY"
else
    # Fallback to hardcoded values if CMake hasn't run yet
    echo "⚠️  Warning: CMake metadata file not found at $METADATA_FILE"
    echo "   Run 'cmake --preset=<preset>' first to generate metadata."
    echo "   Using fallback values for validation..."
    export PROJECT_NAME_TARGET="DSPJucePlugin"
    export PROJECT_NAME_PRODUCT="DSP-JUCE Plugin"
    export PROJECT_VERSION="1.0.0"
    export PROJECT_COMPANY="MyCompany"
fi

echo
ARTEFACTS_DIR="$BUILD_DIR/${PROJECT_NAME_TARGET}_artefacts/$BUILD_CONFIG"

echo "� Configuration: $BUILD_CONFIG on $OS"
echo "📂 Project Root: $PROJECT_ROOT"
echo "📂 Build Directory: $BUILD_DIR"
echo "📂 Artefacts Directory: $ARTEFACTS_DIR"
echo

# --- Validation Functions ---
check_exists() {
    local path="$1"
    local description="$2"
    local type_flag="$3" # -f for file, -d for directory

    if [ "$type_flag" "$path" ]; then
        echo "✅ $description: Found"
        return 0
    else
        echo "❌ $description: Missing at '$path'"
        return 1
    fi
}

# --- Main Execution ---
echo "� Starting validation..."

if ! check_exists "$ARTEFACTS_DIR" "Artefacts directory" -d; then
    exit 1
fi

declare -a missing_artifacts
declare -a missing_optional_artifacts

# --- Artefact Checks ---
# Shared Library (optional - internal build artifact)
if [ "$OS" = "windows" ]; then
    # The VS project is named after the PRODUCT_NAME for the shared library
    shared_lib_path="$ARTEFACTS_DIR/${PROJECT_NAME_PRODUCT}_SharedCode.lib"
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
    check_exists "$au_bundle_path" "AU Plugin" -d || missing_artifacts+=("AU Plugin")
fi

# --- Summary ---
echo
echo "📊 Build Test Summary"
echo "===================="
if [ ${#missing_artifacts[@]} -gt 0 ]; then
    echo "❌ Critical build artifacts are missing: ${missing_artifacts[*]}"
    exit 1
elif [ ${#missing_optional_artifacts[@]} -gt 0 ]; then
    echo "⚠️  Optional artifacts missing (not fatal): ${missing_optional_artifacts[*]}"
    echo "✅ All critical build artifacts found successfully!"
    exit 0
else
    echo "🎉 All expected build artifacts found successfully!"
    exit 0
fi

