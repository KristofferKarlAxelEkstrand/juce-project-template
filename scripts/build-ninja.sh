#!/bin/bash
# Build with Ninja
# Cross-platform wrapper for build-ninja.bat (Windows) equivalent

set -e  # Exit on error

echo "Building with Ninja..."

# Run Ninja build
cmake --build build/ninja

echo ""
echo "Build successful! Artifacts are in: build/ninja/JucePlugin_artefacts/Debug/"
