#!/bin/bash

# Common utilities for build and validation scripts

set -euo pipefail

# Color codes for logging
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Logging functions
info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

# Error handling
trap 'error "Script failed at line $LINENO"' ERR

# Help message utility
show_help() {
    if [[ "${1:-}" == "--help" ]] || [[ "${1:-}" == "-h" ]]; then
        echo "$2"
        exit 0
    fi
}

# Command existence check
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Status printing utility
print_status() {
    if [ "$1" -eq 0 ]; then
        success "$2"
    else
        error "$3"
        exit 1
    fi
}
