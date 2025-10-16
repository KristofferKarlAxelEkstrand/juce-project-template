#!/bin/bash
#
# Shared utility functions for reading plugin metadata.
# This script is intended to be sourced by other scripts.

# Function to extract variables from metadata file
# Usage: extract_metadata_vars METADATA_FILE VAR1 VAR2 ...
extract_metadata_vars() {
    local metadata_file="$1"
    shift
    if [ ! -f "$metadata_file" ]; then
        echo "[ERROR] Metadata file not found: $metadata_file" >&2
        return 1
    fi

    for var in "$@"; do
        local value
        value=$(grep -E "^export ${var}=\"[^\"]*\"" "$metadata_file" | head -n1 | cut -d'=' -f2- | tr -d '"')
        if [ -z "$value" ]; then
            echo "[ERROR] Variable $var not found or empty in $metadata_file" >&2
            return 1
        fi
        # Export the variable to make it available in the calling script's environment
        export "$var=$value"
    done
    return 0
}
