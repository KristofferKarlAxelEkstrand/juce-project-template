#!/bin/bash
# Build with Ninja
# Cross-platform wrapper for build-ninja.bat (Windows) equivalent

set -euo pipefail  # Exit on error, undefined variables, and pipe failures

# Add error handler
trap 'echo "[ERROR] Script failed at line $LINENO" >&2' ERR

# Default build configuration
BUILD_CONFIG="Debug"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --help|-h)
            cat << EOF
Usage: ${0##*/} [OPTIONS]

Build the project using Ninja build system for fast incremental builds.

Options:
    --config CONFIG    Build configuration (Debug or Release, default: Debug)
    -h, --help         Show this help message
    
Examples:
    ${0##*/}                    # Build Debug configuration
    ${0##*/} --config Release   # Build Release configuration
    
Prerequisites:
    Run 'scripts/configure-ninja.sh' first to configure the build.
    
Output:
    Build artifacts in build/ninja/JucePlugin_artefacts/[Debug|Release]/
EOF
            exit 0
            ;;
        --config)
            if [[ -z "${2:-}" ]]; then
                echo "[ERROR] --config requires an argument (Debug or Release)" >&2
                exit 1
            fi
            BUILD_CONFIG="$2"
            shift 2
            ;;
        *)
            echo "[ERROR] Unknown option: $1" >&2
            echo "Use --help for usage information" >&2
            exit 1
            ;;
    esac
done

# Validate build configuration
if [[ "$BUILD_CONFIG" != "Debug" && "$BUILD_CONFIG" != "Release" ]]; then
    echo "[ERROR] Invalid build configuration: $BUILD_CONFIG" >&2
    echo "Must be 'Debug' or 'Release'" >&2
    exit 1
fi

echo "Building with Ninja ($BUILD_CONFIG configuration)..."

# Run Ninja build with specified configuration
cmake --build build/ninja --config "$BUILD_CONFIG"

echo ""
echo "Build successful! Artifacts are in: build/ninja/JucePlugin_artefacts/$BUILD_CONFIG/"
