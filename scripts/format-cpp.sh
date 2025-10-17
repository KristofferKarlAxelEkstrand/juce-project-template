#!/bin/bash

# format-cpp.sh - Cross-platform C++ formatting script

# Function to find clang-format executable
find_clang_format() {
    # Check if clang-format is in PATH
    if command -v clang-format >/dev/null 2>&1; then
        echo "clang-format"
        return 0
    fi
    
    # Check common Windows LLVM installation paths
    local windows_paths=(
        "/c/Program Files/LLVM/bin/clang-format.exe"
        "/c/Program Files (x86)/LLVM/bin/clang-format.exe"
        "/c/LLVM/bin/clang-format.exe"
    )
    
    for path in "${windows_paths[@]}"; do
        if [ -f "$path" ]; then
            echo "$path"
            return 0
        fi
    done
    
    return 1
}

CLANG_FORMAT=$(find_clang_format)

if [ $? -eq 0 ]; then
    echo "INFO: Formatting C++ files with clang-format ($CLANG_FORMAT)..."
    
    # Find all .cpp and .h files in src directory
    if [ -d "src" ]; then
        find src -name "*.cpp" -o -name "*.h" | while read -r file; do
            echo "  Formatting: $file"
            "$CLANG_FORMAT" -i "$file" 2>/dev/null || echo "  Warning: Failed to format $file"
        done
        echo "SUCCESS: C++ formatting complete"
    else
        echo "WARNING: No src directory found"
    fi
else
    echo "WARNING: clang-format not found - install LLVM tools for C++ formatting"
    echo "   Windows: winget install LLVM.LLVM (then restart terminal)"
    echo "   Or add LLVM to PATH: C:\\Program Files\\LLVM\\bin"
    echo "   macOS: brew install clang-format"
    echo "   Linux: sudo apt install clang-format"
fi