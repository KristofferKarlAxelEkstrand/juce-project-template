#!/usr/bin/env bash
# Run all static analysis tools (cppcheck and clang-tidy)
#
# Usage: ./scripts/run-static-analysis.sh
#
# Prerequisites:
#   - cppcheck and clang-tidy installed
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
    echo "Usage: $(basename "$0") [OPTIONS]"
    echo ""
    echo "Run all static analysis tools (cppcheck and clang-tidy)."
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo ""
    echo "Output:"
    echo "  Results are saved to analysis-cppcheck.log and analysis-clang-tidy.log"
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            show_help
            exit 1
            ;;
    esac
done

# Check for compile_commands.json
if [[ ! -f "$COMPILE_COMMANDS" ]]; then
    echo "compile_commands.json not found. Running cmake --preset=ninja..."
    cmake --preset=ninja
fi

CPPCHECK_LOG="${PROJECT_ROOT}/analysis-cppcheck.log"
CLANG_TIDY_LOG="${PROJECT_ROOT}/analysis-clang-tidy.log"
EXIT_CODE=0

echo "=== Running cppcheck ==="
if command -v cppcheck &>/dev/null; then
    # Note: unusedFunction is suppressed because cppcheck cannot see JUCE framework calls
    if cppcheck \
        --enable=all \
        --suppress=missingIncludeSystem \
        --suppress=unmatchedSuppression \
        --suppress=unusedFunction \
        --inline-suppr \
        --std=c++20 \
        "$SRC_DIR" 2>&1 | tee "$CPPCHECK_LOG"; then
        echo "cppcheck: PASSED"
    else
        echo "cppcheck: FAILED (see ${CPPCHECK_LOG})"
        EXIT_CODE=1
    fi
else
    echo "Warning: cppcheck not found, skipping..."
fi

echo ""
echo "=== Running clang-tidy ==="
if command -v clang-tidy &>/dev/null; then
    # Check if run-clang-tidy is available
    if command -v run-clang-tidy &>/dev/null; then
        if run-clang-tidy -p "$BUILD_DIR" "$SRC_DIR" 2>&1 | tee "$CLANG_TIDY_LOG"; then
            echo "clang-tidy: PASSED"
        else
            echo "clang-tidy: FAILED (see ${CLANG_TIDY_LOG})"
            EXIT_CODE=1
        fi
    else
        # Fall back to running clang-tidy on each file
        if find "$SRC_DIR" -type f \( -name "*.cpp" -o -name "*.h" \) -print0 | \
            xargs -0 clang-tidy -p "$BUILD_DIR" 2>&1 | tee "$CLANG_TIDY_LOG"; then
            echo "clang-tidy: PASSED"
        else
            echo "clang-tidy: FAILED (see ${CLANG_TIDY_LOG})"
            EXIT_CODE=1
        fi
    fi
else
    echo "Warning: clang-tidy not found, skipping..."
fi

echo ""
echo "=== Analysis complete ==="
echo "Log files:"
echo "  - ${CPPCHECK_LOG}"
echo "  - ${CLANG_TIDY_LOG}"

exit $EXIT_CODE
