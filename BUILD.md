# DSP-JUCE Build Instructions

This document provides comprehensive build instructions for the DSP-JUCE audio plugin and
standalone application across Windows, Linux, and macOS platforms.

## Overview

The DSP-JUCE project is configured to build:

- **Plugin formats**: VST3 (all platforms), AU (macOS only)
- **Standalone application**: Cross-platform desktop application
- **Debug and Release configurations**: Optimized for development and distribution

## Quick Start

### Prerequisites

**All Platforms:**

- CMake 3.22 or higher
- C++20 compatible compiler
- Git (for dependency management)

**Linux (Ubuntu/Debian):**

```bash
sudo apt-get install -y libasound2-dev libx11-dev libxcomposite-dev libxcursor-dev \
                        libxinerama-dev libxrandr-dev libfreetype6-dev libfontconfig1-dev \
                        libgl1-mesa-dev libcurl4-openssl-dev libwebkit2gtk-4.1-dev pkg-config \
                        build-essential cmake
```

**macOS:**

```bash
# Install Xcode command line tools
xcode-select --install

# Install CMake (via Homebrew)
brew install cmake
```

**Windows:**

- Visual Studio 2019 or later with C++ workload
- Or Visual Studio Build Tools 2019+
- CMake (download from cmake.org or via Visual Studio installer)

### Build Commands

**Linux & macOS:**

```bash
# Configure (Debug)
cmake --preset=default

# Build
cmake --build --preset=default

# Or for Release
cmake --preset=release
cmake --build --preset=release
```

**Windows:**

```batch
# Configure
cmake --preset=vs2022

# Build Debug
cmake --build --preset=vs2022-debug

# Build Release  
cmake --build --preset=vs2022-release
```

## Detailed Platform Instructions

### Linux

#### System Dependencies

The project requires several audio and graphics libraries:

```bash
# Ubuntu/Debian (required)
sudo apt-get update
sudo apt-get install -y \
    libasound2-dev \          # ALSA audio support
    libx11-dev \              # X11 windowing
    libxcomposite-dev \       # X11 compositing
    libxcursor-dev \          # X11 cursor support
    libxinerama-dev \         # Multi-monitor support
    libxrandr-dev \           # Display configuration
    libfreetype6-dev \        # Font rendering
    libfontconfig1-dev \      # Font configuration
    libgl1-mesa-dev \         # OpenGL support
    libcurl4-openssl-dev \    # HTTP client (optional)
    libwebkit2gtk-4.1-dev \   # Web browser component (optional)
    pkg-config \              # Package configuration
    build-essential \         # C++ compiler and tools
    cmake                     # Build system

# Fedora/CentOS/RHEL equivalent
sudo dnf install -y alsa-lib-devel libX11-devel libXcomposite-devel \
                     libXcursor-devel libXinerama-devel libXrandr-devel \
                     freetype-devel fontconfig-devel mesa-libGL-devel \
                     libcurl-devel webkit2gtk3-devel pkgconfig \
                     gcc-c++ cmake make
```

#### Linux Build Process

```bash
# 1. Configure the build
cmake --preset=default
# This step takes ~90 seconds as it downloads JUCE 8.0.9

# 2. Build the project
cmake --build --preset=default
# This step takes ~2-3 minutes to compile all JUCE modules

# 3. Built artifacts location
ls build/DSPJucePlugin_artefacts/Debug/
# Contains: libDSP-JUCE Plugin_SharedCode.a (shared library)
# Plugin binaries: (if VST3 build is working)
#   - DSP-JUCE_Plugin.vst3/
# Standalone: (if standalone build is working)
#   - DSP-JUCE Plugin (executable)
```

#### Alternative Build Methods

```bash
# Using Ninja (if available)
cmake --preset=ninja
cmake --build --preset=ninja

# Release build
cmake --preset=release
cmake --build --preset=release

# Clean build
rm -rf build
cmake --preset=default
cmake --build --preset=default
```

### macOS

#### System Requirements

- macOS 10.15 (Catalina) or later
- Xcode 11 or later, or Xcode Command Line Tools
- CMake 3.22+ (via Homebrew recommended)

#### Setup

```bash
# Install Xcode Command Line Tools
xcode-select --install

# Install CMake via Homebrew (recommended)
brew install cmake

# Alternative: Download CMake from cmake.org
```

#### macOS Build Process

```bash
# 1. Configure build (Unix Makefiles)
cmake --preset=default

# 2. Build
cmake --build --preset=default

# Alternative: Use Xcode generator
cmake --preset=xcode
cmake --build --preset=xcode-debug
# or
cmake --build --preset=xcode-release

# 3. Built artifacts location
ls build/DSPJucePlugin_artefacts/Debug/
# Contains:
#   - libDSP-JUCE Plugin_SharedCode.a
#   - DSP-JUCE Plugin.vst3/ (VST3 plugin bundle)
#   - DSP-JUCE Plugin.component/ (AU plugin bundle)
#   - DSP-JUCE Plugin.app/ (Standalone application bundle)
```

#### macOS Installation

```bash
# Install VST3 plugin (system-wide)
sudo cp -r "build/DSPJucePlugin_artefacts/Debug/DSP-JUCE Plugin.vst3" \
           "/Library/Audio/Plug-Ins/VST3/"

# Install AU plugin (system-wide) 
sudo cp -r "build/DSPJucePlugin_artefacts/Debug/DSP-JUCE Plugin.component" \
           "/Library/Audio/Plug-Ins/Components/"

# Install VST3 plugin (user-only)
mkdir -p "~/Library/Audio/Plug-Ins/VST3"
cp -r "build/DSPJucePlugin_artefacts/Debug/DSP-JUCE Plugin.vst3" \
      "~/Library/Audio/Plug-Ins/VST3/"
```

### Windows

#### Windows System Requirements

- Windows 10 or later (x64)
- Visual Studio 2019 or later with C++ workload, OR
- Visual Studio Build Tools 2019+ (command line only)
- CMake 3.22+ (can be installed via Visual Studio)

#### Setup Options

##### Option 1: Visual Studio IDE

1. Install Visual Studio 2019/2022 Community (free)
2. Select "Desktop development with C++" workload
3. Ensure CMake is included in the installation

##### Option 2: Build Tools Only

1. Download Visual Studio Build Tools
2. Install C++ build tools
3. Download and install CMake separately

#### Windows Build Process

**Command Line (Recommended):**

```batch
# 1. Open "x64 Native Tools Command Prompt" from Start Menu

# 2. Navigate to project directory
cd path\to\dsp-juce

# 3. Configure
cmake --preset=vs2022

# 4. Build Debug
cmake --build --preset=vs2022-debug

# 5. Build Release
cmake --build --preset=vs2022-release

# 6. Built artifacts location
dir build\DSPJucePlugin_artefacts\Debug\
# Contains:
#   - libDSP-JUCE Plugin_SharedCode.lib
#   - DSP-JUCE Plugin.vst3\ (VST3 plugin)
#   - DSP-JUCE Plugin.exe (Standalone application)
```

**Visual Studio IDE:**

```batch
# 1. Configure to generate .sln file
cmake --preset=vs2022

# 2. Open the solution
start build\vs2022\DSPJucePlugin.sln

# 3. Build using Visual Studio:
#    - Select Debug or Release configuration
#    - Build > Build Solution (Ctrl+Shift+B)
```

#### Windows Installation

```batch
# Install VST3 plugin (system-wide, requires Administrator)
xcopy "build\DSPJucePlugin_artefacts\Debug\DSP-JUCE Plugin.vst3" ^
      "%ProgramFiles%\Common Files\VST3\" /E /I

# Install VST3 plugin (user-only)
xcopy "build\DSPJucePlugin_artefacts\Debug\DSP-JUCE Plugin.vst3" ^
      "%APPDATA%\VST3\" /E /I
```

## Configuration Options

### CMake Presets

The project includes several predefined build configurations:

| Preset | Platform | Generator | Use Case |
|--------|----------|-----------|----------|
| `default` | Linux/macOS | Unix Makefiles | Debug development |
| `release` | Linux/macOS | Unix Makefiles | Release builds |
| `vs2022` | Windows | Visual Studio 17 2022 | Windows development |
| `ninja` | All | Ninja | Fast incremental builds |
| `xcode` | macOS | Xcode | macOS IDE development |

### Custom Configuration

```bash
# Custom build directory
cmake -B custom_build -DCMAKE_BUILD_TYPE=Release

# Specify compiler
cmake --preset=default -DCMAKE_CXX_COMPILER=clang++

# Enable additional warnings (advanced users)
cmake --preset=default -DENABLE_EXTRA_WARNINGS=ON
```

## Validation and Testing

### Build Validation

```bash
# Run the validation script
./scripts/validate-setup.sh

# Test documentation linting
npm install  # Install Node.js dependencies
npm test     # Run markdown linting
```

### Manual Testing

**Standalone Application:**

```bash
# Linux/macOS
./build/DSPJucePlugin_artefacts/Debug/DSP-JUCE\ Plugin

# Windows
build\DSPJucePlugin_artefacts\Debug\DSP-JUCE Plugin.exe
```

**Plugin Testing:**

- Load in your DAW (Reaper, Logic Pro, Pro Tools, etc.)
- Verify audio processing and GUI responsiveness
- Test parameter automation
- Check CPU usage and audio dropouts

## Troubleshooting

### Common Issues

#### CMake Not Found

```bash
# Linux: Install via package manager
sudo apt-get install cmake    # Ubuntu/Debian
sudo dnf install cmake        # Fedora

# macOS: Install via Homebrew
brew install cmake

# Windows: Download from cmake.org or use Visual Studio installer
```

#### C++ Compiler Not Found

```bash
# Linux
sudo apt-get install build-essential  # Ubuntu/Debian
sudo dnf groupinstall "Development Tools"  # Fedora

# macOS
xcode-select --install

# Windows: Install Visual Studio with C++ workload
```

#### JUCE Dependencies Missing (Linux)

```bash
# Run the complete dependency installation
sudo apt-get install -y libasound2-dev libx11-dev libxcomposite-dev \
                        libxcursor-dev libxinerama-dev libxrandr-dev \
                        libfreetype6-dev libfontconfig1-dev libgl1-mesa-dev
```

#### Build Fails With 'Generator Not Found'

```bash
# Try alternative generator
cmake --preset=ninja  # If Ninja is available
# or specify manually
cmake -G "Unix Makefiles" -B build
```

#### Plugin Not Recognized by DAW

1. **Check plugin location**: Ensure plugins are in the correct directory
2. **Rescan plugins**: Force DAW to rescan plugin directories  
3. **Check architecture**: Ensure 64-bit plugin for 64-bit DAW
4. **Verify format**: Some DAWs don't support all formats (VST3 vs AU)

### Platform-Specific Issues

**Linux:**

- **Audio Device Access**: Ensure user is in `audio` group
- **Real-time Priority**: May need to configure `/etc/security/limits.conf`
- **Plugin Scanning**: Some DAWs require manual plugin directory configuration

**macOS:**

- **Gatekeeper**: May need to allow unsigned plugins in Security preferences
- **Code Signing**: For distribution, plugins need proper code signing
- **Notarization**: Required for macOS 10.15+ distribution

**Windows:**

- **Antivirus**: Some antivirus software blocks plugin loading
- **Visual C++ Redistributable**: May need to install for end users
- **Windows Defender**: May quarantine newly built plugins

### Performance Issues

**High CPU Usage:**

- Build Release configuration instead of Debug
- Check for audio dropouts in system audio settings
- Adjust audio buffer size in DAW preferences

**GUI Responsiveness:**

- Ensure GUI updates are on message thread only
- Check for blocking operations in audio callback
- Profile with appropriate tools (Instruments, Visual Studio Diagnostics)

## Development Tips

### Code Formatting

```bash
# Format all source files
clang-format -i src/*.cpp src/*.h
```

### Debugging

- Use Debug build configuration for development
- Enable JUCE assertions for runtime checking
- Use appropriate debugger (GDB, LLDB, Visual Studio)

### Continuous Integration

The project includes CI/CD configurations for:

- Multi-platform builds
- Code quality checks
- Security scanning
- Automated testing

## Advanced Configuration

### Custom JUCE Configuration

Modify `CMakeLists.txt` to customize JUCE settings:

```cmake
# Add custom JUCE modules
target_link_libraries(DSPJucePlugin PRIVATE juce::juce_opengl)

# Custom compile definitions
target_compile_definitions(DSPJucePlugin PRIVATE
    JUCE_VST3_CAN_REPLACE_VST2=0
    JUCE_USE_CUSTOM_PLUGIN_STANDALONE_APP=1
)
```

### Cross-Compilation

```bash
# Cross-compile for different architectures (advanced)
cmake --preset=default -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64"  # macOS Universal
```

## Support and Resources

- **JUCE Documentation**: <https://docs.juce.com/>
- **JUCE Forum**: <https://forum.juce.com/>
- **CMake Documentation**: <https://cmake.org/documentation/>
- **Project Issues**: Check GitHub issues for known problems
- **Audio Development**: Real-time audio programming best practices

---

---

Last updated: 2024 - Compatible with JUCE 8.0.9 and CMake 3.22+
