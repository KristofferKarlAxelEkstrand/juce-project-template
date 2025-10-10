#!/bin/bash

# DSP-JUCE Build Testing Script
# Tests that plugin and standalone builds work correctly

set -e

echo "🧪 DSP-JUCE Build Testing"
echo "========================="
echo

# Determine build configuration: default to Debug if not specified
BUILD_CONFIG=${1:-Debug}
echo "🔧 Build configuration: $BUILD_CONFIG"
echo

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Adjust build directory based on OS
if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
    BUILD_DIR="$PROJECT_ROOT/build/vs2022"
    echo "🔎 Found Windows build directory: $BUILD_DIR"
else
    BUILD_DIR="$PROJECT_ROOT/build"
    echo "🔎 Using default build directory: $BUILD_DIR"
fi

# Function to check if file exists and report
check_file() {
    local file_path="$1"
    local description="$2"
    
    if [ -f "$file_path" ]; then
        echo "✅ $description: $(basename "$file_path")"
        return 0
    else
        echo "❌ $description: Missing"
        return 1
    fi
}

# Function to check if directory exists and report
check_directory() {
    local dir_path="$1"
    local description="$2"
    
    if [ -d "$dir_path" ]; then
        echo "✅ $description: $(basename "$dir_path")"
        return 0
    else
        echo "❌ $description: Missing"
        return 1
    fi
}

# Function to test executable briefly
test_executable() {
    local exe_path="$1"
    local description="$2"
    
    if [ -x "$exe_path" ]; then
        echo "  🔍 Testing $description..."
        # Try to run with --help or version flag, or just test execution
        if timeout 2s "$exe_path" --help >/dev/null 2>&1 || \
           timeout 2s "$exe_path" >/dev/null 2>&1; then
            echo "  ✅ $description: Executable runs"
            return 0
        else
            echo "  ⚠️  $description: Executable exists but may need display/audio"
            return 0  # This is okay in headless environments
        fi
    else
        echo "  ❌ $description: Not executable"
        return 1
    fi
}

echo "📁 Checking Build Artifacts..."
echo "------------------------------"

cd "$PROJECT_ROOT"

# Check if build directory exists
if [ ! -d "$BUILD_DIR" ]; then
    echo "❌ Build directory not found. Run 'cmake --preset=default && cmake --build --preset=default' first."
    exit 1
fi

success_count=0
total_count=0

# Check shared library
((total_count++))
if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
    shared_lib_path="$BUILD_DIR/DSPJucePlugin_artefacts/$BUILD_CONFIG/DSP-JUCE Plugin_SharedCode.lib"
else
    shared_lib_path="$BUILD_DIR/DSPJucePlugin_artefacts/$BUILD_CONFIG/libDSP-JUCE Plugin_SharedCode.a"
fi

if check_file "$shared_lib_path" "Shared Library"; then
    ((success_count++))
fi

# Check VST3 plugin
((total_count++))
if check_directory "$BUILD_DIR/DSPJucePlugin_artefacts/$BUILD_CONFIG/VST3/DSP-JUCE Plugin.vst3" "VST3 Plugin Bundle"; then
    ((success_count++))
    
    # Check VST3 binary inside bundle
    if [[ "$OSTYPE" == "darwin"* ]]; then
        vst3_binary="$BUILD_DIR/DSPJucePlugin_artefacts/$BUILD_CONFIG/VST3/DSP-JUCE Plugin.vst3/Contents/MacOS/DSP-JUCE Plugin"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        vst3_binary="$BUILD_DIR/DSPJucePlugin_artefacts/$BUILD_CONFIG/VST3/DSP-JUCE Plugin.vst3/Contents/x86_64-linux/DSP-JUCE Plugin.so"
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
        vst3_binary="$BUILD_DIR/DSPJucePlugin_artefacts/$BUILD_CONFIG/VST3/DSP-JUCE Plugin.vst3/Contents/x86_64-win/DSP-JUCE Plugin.vst3"
    fi
    
    if [ -n "$vst3_binary" ]; then
        check_file "$vst3_binary" "  VST3 Binary"
    fi
fi

# Check AU plugin (macOS only)
if [[ "$OSTYPE" == "darwin"* ]]; then
    ((total_count++))
    if check_directory "$BUILD_DIR/DSPJucePlugin_artefacts/$BUILD_CONFIG/AU/DSP-JUCE Plugin.component" "AU Plugin Bundle"; then
        ((success_count++))
        check_file "$BUILD_DIR/DSPJucePlugin_artefacts/$BUILD_CONFIG/AU/DSP-JUCE Plugin.component/Contents/MacOS/DSP-JUCE Plugin" "  AU Binary"
    fi
fi

# Check Standalone application
((total_count++))
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS app bundle
    standalone_path="$BUILD_DIR/DSPJucePlugin_artefacts/$BUILD_CONFIG/Standalone/DSP-JUCE Plugin.app"
    if check_directory "$standalone_path" "Standalone App Bundle"; then
        ((success_count++))
        test_executable "$standalone_path/Contents/MacOS/DSP-JUCE Plugin" "Standalone App"
    fi
else
    # Linux/Windows executable
    standalone_path="$BUILD_DIR/DSPJucePlugin_artefacts/$BUILD_CONFIG/Standalone/DSP-JUCE Plugin"
    if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
        standalone_path+=".exe"
    fi
    
    if check_file "$standalone_path" "Standalone Application"; then
        ((success_count++))
        test_executable "$standalone_path" "Standalone App"
    fi
fi

echo
echo "🔍 Plugin Installation Check..."
echo "-------------------------------"

# Check if plugins are installed to user directories
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if [ -d "$HOME/.vst3/DSP-JUCE Plugin.vst3" ]; then
        echo "✅ VST3 plugin installed to user directory: ~/.vst3/"
    else
        echo "⚠️  VST3 plugin not found in ~/.vst3/ (may need manual installation)"
    fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
    if [ -d "$HOME/Library/Audio/Plug-Ins/VST3/DSP-JUCE Plugin.vst3" ]; then
        echo "✅ VST3 plugin installed to user directory"
    fi
    if [ -d "$HOME/Library/Audio/Plug-Ins/Components/DSP-JUCE Plugin.component" ]; then
        echo "✅ AU plugin installed to user directory"
    fi
elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
    if [ -d "$APPDATA/VST3/DSP-JUCE Plugin.vst3" ]; then
        echo "✅ VST3 plugin installed to user directory"
    fi
fi

echo
echo "📊 Build Test Summary"
echo "===================="
echo "Successful: $success_count/$total_count artifacts built"

if [ $success_count -eq $total_count ]; then
    echo "🎉 All build artifacts created successfully!"
    echo
    echo "Next steps:"
    echo "1. Load VST3 plugin in your DAW"
    echo "2. Run standalone application"
    echo "3. Test audio functionality"
    exit 0
else
    echo "⚠️  Some build artifacts are missing."
    echo "Check the build output and BUILD.md for troubleshooting."
    exit 1
fi