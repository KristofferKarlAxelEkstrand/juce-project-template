#!/bin/bash
# Launch standalone application using metadata from CMake configuration
# This script reads plugin metadata dynamically to avoid hardcoded names

set -euo pipefail

# Add error handler
trap 'echo "[ERROR] Script failed at line $LINENO" >&2' ERR

# Add help message
if [[ "${1:-}" == "--help" ]] || [[ "${1:-}" == "-h" ]]; then
    cat << EOF
Usage: ${0##*/} [BUILD_CONFIG] [BUILD_DIR]

Launch the standalone application using metadata from CMake.

Arguments:
    BUILD_CONFIG    Build configuration (Debug or Release, default: Debug)
    BUILD_DIR       Build directory (default: build/ninja)

Options:
    -h, --help     Show this help message

Examples:
    ${0##*/}                    # Launch Debug build from build/ninja
    ${0##*/} Release            # Launch Release build from build/ninja
    ${0##*/} Debug build/default  # Launch Debug build from build/default

Note:
    This script reads plugin metadata from the generated plugin_metadata.sh
    file in the build directory, so it works regardless of plugin name changes.
EOF
    exit 0
fi

# Determine build configuration and directory
BUILD_CONFIG=${1:-Debug}
BUILD_DIR=${2:-build/ninja}

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_PATH="$PROJECT_ROOT/$BUILD_DIR"

# Source metadata file
METADATA_FILE="$BUILD_PATH/plugin_metadata.sh"

if [ ! -f "$METADATA_FILE" ]; then
    echo "[ERROR] Metadata file not found: $METADATA_FILE" >&2
    echo "Run configure-ninja.sh or cmake --preset=default first." >&2
    exit 1
fi

# Source metadata utility script
# shellcheck source=./metadata-utils.sh
source "$(dirname "${BASH_SOURCE[0]}")/metadata-utils.sh"

# Safely extract expected variables from metadata file
if ! extract_metadata_vars "$METADATA_FILE" PROJECT_NAME_TARGET PROJECT_NAME_PRODUCT; then
    exit 1
fi

# Construct path to standalone application
STANDALONE_DIR="$BUILD_PATH/${PROJECT_NAME_TARGET}_artefacts/$BUILD_CONFIG/Standalone"

# Determine OS and executable path
case "$(uname -s)" in
    Darwin*)
        # macOS: .app bundle
        STANDALONE_APP="$STANDALONE_DIR/${PROJECT_NAME_PRODUCT}.app"
        if [ ! -d "$STANDALONE_APP" ]; then
            echo "[ERROR] Standalone app not found: $STANDALONE_APP" >&2
            echo "Build the project first with build-ninja.sh" >&2
            exit 1
        fi
        echo "Launching $PROJECT_NAME_PRODUCT ($BUILD_CONFIG)..."
        open "$STANDALONE_APP"
        ;;
    Linux*)
        # Linux: executable
        STANDALONE_APP="$STANDALONE_DIR/$PROJECT_NAME_PRODUCT"
        if [ ! -f "$STANDALONE_APP" ]; then
            echo "[ERROR] Standalone app not found: $STANDALONE_APP" >&2
            echo "Build the project first with build-ninja.sh" >&2
            exit 1
        fi
        echo "Launching $PROJECT_NAME_PRODUCT ($BUILD_CONFIG)..."
        "$STANDALONE_APP" &
        ;;
    CYGWIN*|MINGW*|MSYS*)
        # Windows (Git Bash): executable
        STANDALONE_APP="$STANDALONE_DIR/${PROJECT_NAME_PRODUCT}.exe"
        if [ ! -f "$STANDALONE_APP" ]; then
            echo "[ERROR] Standalone app not found: $STANDALONE_APP" >&2
            echo "Build the project first with build-ninja.bat" >&2
            exit 1
        fi
        echo "Launching $PROJECT_NAME_PRODUCT ($BUILD_CONFIG)..."
        "$STANDALONE_APP" &
        ;;
    *)
        echo "[ERROR] Unsupported operating system" >&2
        exit 1
        ;;
esac

echo "Launched successfully."
