#!/usr/bin/env bash
# Build and run with a sanitizer for runtime error detection
#
# Usage: ./scripts/run-with-sanitizer.sh [asan|ubsan|tsan|rtsan] [args...]
#
# Sanitizers:
#   asan  - AddressSanitizer: detects memory errors (use-after-free, buffer overflow)
#   ubsan - UndefinedBehaviorSanitizer: detects undefined behavior
#   tsan  - ThreadSanitizer: detects data races between threads
#   rtsan - RealtimeSanitizer: detects allocations/locks in real-time callbacks (Clang 18+)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Error handler
trap 'echo "Error on line $LINENO. Exit code: $?" >&2' ERR

show_help() {
    echo "Usage: $(basename "$0") [OPTIONS] [sanitizer] [-- app_args...]"
    echo ""
    echo "Build and run with a sanitizer for runtime error detection."
    echo ""
    echo "Sanitizers:"
    echo "  asan   AddressSanitizer: memory errors (default)"
    echo "  ubsan  UndefinedBehaviorSanitizer: undefined behavior"
    echo "  tsan   ThreadSanitizer: data races"
    echo "  rtsan  RealtimeSanitizer: real-time violations (Clang 18+)"
    echo ""
    echo "Options:"
    echo "  -h, --help      Show this help message"
    echo "  -b, --build     Build only, do not run"
    echo ""
    echo "Examples:"
    echo "  $(basename "$0")                 # Build and run with AddressSanitizer"
    echo "  $(basename "$0") tsan            # Build and run with ThreadSanitizer"
    echo "  $(basename "$0") asan --build    # Build with AddressSanitizer only"
}

SANITIZER="asan"
BUILD_ONLY=false
APP_ARGS=()

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        -b|--build)
            BUILD_ONLY=true
            shift
            ;;
        asan|ubsan|tsan|rtsan)
            SANITIZER="$1"
            shift
            ;;
        --)
            shift
            APP_ARGS=("$@")
            break
            ;;
        *)
            echo "Unknown option: $1" >&2
            show_help
            exit 1
            ;;
    esac
done

# Validate sanitizer
case "$SANITIZER" in
    asan|ubsan|tsan|rtsan) ;;
    *)
        echo "Error: Unknown sanitizer: $SANITIZER" >&2
        echo "Valid options: asan, ubsan, tsan, rtsan" >&2
        exit 1
        ;;
esac

BUILD_DIR="${PROJECT_ROOT}/build/${SANITIZER}"

echo "=== Building with ${SANITIZER} ==="

# Configure
cmake --preset="${SANITIZER}"

# Build standalone only (VST3 plugin linking with sanitizers is problematic)
cmake --build --preset="${SANITIZER}" --target JucePlugin_Standalone

if [[ "$BUILD_ONLY" == true ]]; then
    echo ""
    echo "Build complete. Artifacts in: ${BUILD_DIR}/JucePlugin_artefacts/"
    exit 0
fi

echo ""
echo "=== Running with ${SANITIZER} ==="

# Find the standalone executable
# shellcheck disable=SC1091
source "${BUILD_DIR}/plugin_metadata.sh"
STANDALONE_DIR="${BUILD_DIR}/JucePlugin_artefacts/Debug/Standalone"
EXECUTABLE="${STANDALONE_DIR}/${PLUGIN_NAME}"

if [[ ! -f "$EXECUTABLE" ]]; then
    echo "Error: Standalone executable not found at ${EXECUTABLE}" >&2
    exit 1
fi

# Set up sanitizer environment
export ASAN_OPTIONS="detect_leaks=1:abort_on_error=1:print_stats=1"
export UBSAN_OPTIONS="print_stacktrace=1:halt_on_error=1"
export TSAN_OPTIONS="second_deadlock_stack=1"
export RTSAN_OPTIONS="halt_on_error=1:print_stats_on_exit=1"

# Find symbolizer for better error messages
if command -v llvm-symbolizer &>/dev/null; then
    export ASAN_SYMBOLIZER_PATH="$(command -v llvm-symbolizer)"
fi

echo "Running: ${EXECUTABLE} ${APP_ARGS[*]:-}"
echo ""

"$EXECUTABLE" "${APP_ARGS[@]:-}"
