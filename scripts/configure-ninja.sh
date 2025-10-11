#!/bin/bash
# Configure CMake with Ninja preset
# Cross-platform wrapper for configure-ninja.bat (Windows) equivalent

set -e  # Exit on error

echo "Configuring CMake with Ninja preset..."

# Run CMake configuration
cmake --preset=ninja

echo ""
echo "Configuration successful! Build directory: build/ninja"
echo "You can now build with: scripts/build-ninja.sh"
