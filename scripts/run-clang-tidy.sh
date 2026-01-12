#!/usr/bin/env bash
# Run clang-tidy static analysis on source files
#
# Usage: ./scripts/run-clang-tidy.sh [file...]
#        If no files specified, runs on all source files.
#
# Prerequisites:
#   - clang-tidy installed
#   - compile_commands.json generated (run cmake --preset=ninja first)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="${PROJECT_ROOT}/build/ninja"
COMPILE_COMMANDS="${BUILD_DIR}/compile_commands.json"

# Error handler
trap 'echo "Error on line $LINENO. Exit code: $?" >&2' ERR

show_help() {
    echo "Usage: $(basename "$0") [OPTIONS] [file...]"
    echo ""
    echo "Run clang-tidy static analysis on source files."
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -f, --fix      Apply suggested fixes automatically"
    echo ""
    echo "Examples:"
    echo "  $(basename "$0")                    # Analyze all source files"
    echo "  $(basename "$0") src/Main.cpp       # Analyze specific file"
    echo "  $(basename "$0") --fix              # Analyze and apply fixes"
}

# Check for clang-tidy
if ! command -v clang-tidy &>/dev/null; then
    echo "Error: clang-tidy not found. Install it with:" >&2
    echo "  apt-get install clang-tidy" >&2
    exit 1
fi

# Check for compile_commands.json
if [[ ! -f "$COMPILE_COMMANDS" ]]; then
    echo "Error: compile_commands.json not found at ${COMPILE_COMMANDS}" >&2
    echo "Run 'cmake --preset=ninja' first to generate it." >&2
    exit 1
fi

FIX_FLAG=""
FILES=()

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        -f|--fix)
            FIX_FLAG="--fix"
            shift
            ;;
        *)
            FILES+=("$1")
            shift
            ;;
    esac
done

# Default to all source files if none specified
if [[ ${#FILES[@]} -eq 0 ]]; then
    FILES=("${PROJECT_ROOT}/src")
fi

echo "Running clang-tidy..."
echo "  Build directory: ${BUILD_DIR}"
echo "  Files: ${FILES[*]}"
if [[ -n "$FIX_FLAG" ]]; then
    echo "  Mode: Fix mode enabled"
fi
echo ""

# Collect source files from directories or use specified files directly
SOURCE_FILES=()
for item in "${FILES[@]}"; do
    if [[ -d "$item" ]]; then
        while IFS= read -r -d '' f; do
            SOURCE_FILES+=("$f")
        done < <(find "$item" -type f \( -name "*.cpp" -o -name "*.h" \) -print0)
    else
        SOURCE_FILES+=("$item")
    fi
done

if [[ ${#SOURCE_FILES[@]} -eq 0 ]]; then
    echo "No source files found."
    exit 0
fi

# Run clang-tidy on each file
EXIT_CODE=0
for f in "${SOURCE_FILES[@]}"; do
    echo "Analyzing: $f"
    if ! clang-tidy -p "$BUILD_DIR" ${FIX_FLAG:+"$FIX_FLAG"} "$f"; then
        EXIT_CODE=1
    fi
done

echo ""
if [[ $EXIT_CODE -eq 0 ]]; then
    echo "clang-tidy analysis complete. No issues found."
else
    echo "clang-tidy analysis complete. Issues found (see above)."
fi

exit $EXIT_CODE
