#!/bin/bash
# Configure CMake with Ninja preset
# Cross-platform wrapper for configure-ninja.bat (Windows) equivalent

set -euo pipefail  # Exit on error, undefined variables, and pipe failures

# Add error handler
trap 'echo "[ERROR] Script failed at line $LINENO" >&2' ERR

# Add help message
if [[ "${1:-}" == "--help" ]] || [[ "${1:-}" == "-h" ]]; then
    cat << EOF
Usage: ${0##*/} [OPTIONS]

Configure CMake with Ninja preset for fast incremental builds.

Options:
    -h, --help      Show this help message
    
Examples:
    ${0##*/}
    
Output:
    Creates build/ninja directory with Ninja build files.
EOF
    exit 0
fi

echo "Configuring CMake with Ninja preset..."

# Run CMake configuration
cmake --preset=ninja

echo ""
echo "Configuration successful! Build directory: build/ninja"
echo "You can now build with: scripts/build-ninja.sh"
