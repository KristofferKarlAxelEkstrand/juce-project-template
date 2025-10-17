#!/bin/bash

# format-cpp.sh - Cross-platform C++ formatting script

if command -v clang-format >/dev/null 2>&1; then
    echo "🔧 Formatting C++ files with clang-format..."
    
    # Find all .cpp and .h files in src directory
    if [ -d "src" ]; then
        find src -name "*.cpp" -o -name "*.h" | while read -r file; do
            echo "  Formatting: $file"
            clang-format -i "$file" 2>/dev/null || echo "  Warning: Failed to format $file"
        done
        echo "✅ C++ formatting complete"
    else
        echo "⚠️  No src directory found"
    fi
else
    echo "⚠️  clang-format not found - install LLVM tools for C++ formatting"
    echo "   Windows: winget install LLVM.LLVM"
    echo "   macOS: brew install clang-format"
    echo "   Linux: sudo apt install clang-format"
fi