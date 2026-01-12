#!/usr/bin/env bash
# Run cppcheck static analysis on source files
#
# Usage: ./scripts/run-cppcheck.sh [file...]
#        If no files specified, runs on all source files.
#
# Prerequisites:
#   - cppcheck installed
#   - compile_commands.json generated (run cmake --preset=ninja first)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="${PROJECT_ROOT}/build/ninja"
COMPILE_COMMANDS="${BUILD_DIR}/compile_commands.json"
SRC_DIR="${PROJECT_ROOT}/src"

# Error handler
trap 'echo "Error on line $LINENO. Exit code: $?" >&2' ERR

show_help() {
    echo "Usage: $(basename "$0") [OPTIONS] [directory...]"
    echo ""
    echo "Run cppcheck static analysis on source files."
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -v, --verbose  Enable verbose output"
    echo ""
    echo "Examples:"
    echo "  $(basename "$0")                    # Analyze all source files"
    echo "  $(basename "$0") src/               # Analyze specific directory"
    echo "  $(basename "$0") --verbose          # Verbose analysis"
}

# Check for cppcheck
if ! command -v cppcheck &>/dev/null; then
    echo "Error: cppcheck not found. Install it with:" >&2
    echo "  apt-get install cppcheck" >&2
    exit 1
fi

VERBOSE=""
DIRS=()

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        -v|--verbose)
            VERBOSE="--verbose"
            shift
            ;;
        *)
            DIRS+=("$1")
            shift
            ;;
    esac
done

# Default to src directory if none specified
if [[ ${#DIRS[@]} -eq 0 ]]; then
    DIRS=("$SRC_DIR")
fi

echo "Running cppcheck..."
echo "  Directories: ${DIRS[*]}"
echo ""

# Run cppcheck directly on source files (not via compile_commands.json)
# This avoids analyzing third-party JUCE sources
# Note: unusedFunction is suppressed because cppcheck cannot see JUCE framework calls
cppcheck \
    --enable=all \
    --suppress=missingIncludeSystem \
    --suppress=unmatchedSuppression \
    --suppress=unusedFunction \
    --inline-suppr \
    --std=c++20 \
    --error-exitcode=1 \
    ${VERBOSE:+"$VERBOSE"} \
    "${DIRS[@]}" 2>&1

echo ""
echo "cppcheck analysis complete."
