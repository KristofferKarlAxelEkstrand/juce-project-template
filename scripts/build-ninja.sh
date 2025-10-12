#!/bin/bash
# Build with Ninja
# Cross-platform wrapper for build-ninja.bat (Windows) equivalent

set -euo pipefail  # Exit on error, undefined variables, and pipe failures

# Add error handler
trap 'echo "[ERROR] Script failed at line $LINENO" >&2' ERR

# Add help message
if [[ "${1:-}" == "--help" ]] || [[ "${1:-}" == "-h" ]]; then
    cat << EOF
Usage: ${0##*/} [OPTIONS]

Build the project using Ninja build system for fast incremental builds.

Options:
    -h, --help      Show this help message
    
Examples:
    ${0##*/}
    
Prerequisites:
    Run 'scripts/configure-ninja.sh' first to configure the build.
    
Output:
    Build artifacts in build/ninja/JucePlugin_artefacts/
EOF
    exit 0
fi

echo "Building with Ninja..."

# Run Ninja build
cmake --build build/ninja

echo ""
echo "Build successful! Artifacts are in: build/ninja/JucePlugin_artefacts/"
