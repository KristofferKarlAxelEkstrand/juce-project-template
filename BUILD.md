# Build Instructions

Complete build setup for DSP-JUCE on Windows, macOS, and Linux.

## Prerequisites

**Required Software**:

- **CMake**: 3.22 or higher
- **C++20 Compiler**: MSVC 2019+, GCC 10+, or Clang 11+
- **Git**: For dependency management

### Platform Setup

#### Windows

Install Visual Studio 2019+ with "Desktop development with C++" workload.

```powershell
# Verify installation
cmake --version
cl  # MSVC compiler check
```

#### macOS

```bash
# Install Xcode tools and Homebrew
xcode-select --install
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install cmake

# Verify installation  
cmake --version
clang++ --version
```

#### Linux (Ubuntu/Debian)

```bash
# Install dependencies
sudo apt-get update && sudo apt-get install -y \
    build-essential cmake git \
    libasound2-dev libx11-dev libxcomposite-dev libxcursor-dev \
    libxinerama-dev libxrandr-dev libfreetype6-dev libfontconfig1-dev \
    libgl1-mesa-dev libwebkit2gtk-4.1-dev pkg-config

# Verify installation
cmake --version && g++ --version
```

## Build Process

**IMPORTANT**: Each step takes significant time. Do not cancel operations.

### Step 1: Configure (90+ seconds)

Downloads JUCE 8.0.10 and generates platform-specific build files.

```bash
cmake --preset=default
```

### Step 2: Build (2m45s+ Debug, 4m30s+ Release)  

Compiles all source code and JUCE modules.

```bash
# Debug build (faster compilation, larger binaries)
cmake --build --preset=default

# Release build (optimized, smaller binaries)
cmake --preset=release && cmake --build --preset=release
```

### Step 3: Validation

```bash
# Check build artifacts exist
ls -la build/DSPJucePlugin_artifacts/Debug/

# Run validation script
./scripts/validate-setup.sh
```

### Build Artifacts

The compiled binaries are placed in the `build/DSPJucePlugin_artifacts/` directory,
organized by build configuration (e.g., `Debug`, `Release`).

- **VST3 Plugin**: `VST3/DSP-JUCE Plugin.vst3`
- **AU Plugin** (macOS): `AU/DSP-JUCE Plugin.component`
- **Standalone Application**: `Standalone/DSP-JUCE Plugin` (or `.exe` on Windows)

## Troubleshooting

### Build Failures

**CMake Configure Fails**:

```bash
# Check CMake version
cmake --version  # Must be 3.22+

# Clear cache and retry
rm -rf build/ && cmake --preset=default
```

**Compiler Errors**:

```bash  
# Verify C++20 support
g++ -std=c++20 --version  # Linux
clang++ -std=c++20 --version  # macOS
cl /std:c++20  # Windows (in Developer Command Prompt)
```

**JUCE Download Fails**:

- Check internet connection and firewall settings
- Verify Git can access GitHub: `git clone https://github.com/juce-framework/JUCE.git /tmp/test-juce`

### Plugin Installation

**VST3 Not Found by DAW**:

1. **Linux**: Check `~/.vst3/DSP-JUCE Plugin.vst3/` exists
2. **Windows**: Copy to `%PROGRAMFILES%\Common Files\VST3\`  
3. **macOS**: Copy to `/Library/Audio/Plug-Ins/VST3/`
4. Rescan plugins in your DAW

**Performance Issues**:

- Use Release builds for production: `cmake --preset=release`
- Ensure no debug symbols in audio thread
- Check sample rate and buffer size compatibility
