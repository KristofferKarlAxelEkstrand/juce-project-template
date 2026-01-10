# Dev Container Implementation Plan for JUCE Project

This document outlines the research findings and implementation plan for creating a dev container that supports JUCE
audio plugin development with Windows cross-compilation capabilities.

## Quick Start (After Implementation)

Once implemented, developers can:

```bash
# 1. Open in VS Code with Dev Containers extension
# 2. Select "Reopen in Container"
# 3. Wait for container build (2-5 minutes first time)
# 4. Build and run:

cmake --build --preset=ninja          # Linux build
./build/ninja/JucePlugin_artefacts/Debug/Standalone/JUCE\ Project\ Template\ Plugin

# Optional: Cross-compile for Windows
cmake --preset=mingw64
cmake --build --preset=mingw64
# Copy build/mingw64/JucePlugin_artefacts/Release/VST3/ to Windows for testing
```

## Objectives

1. Create a Linux-based dev container for JUCE 8.0.10 development
2. Enable Windows cross-compilation for VST3 plugin artifacts
3. Maintain fast build times using Ninja
4. Keep existing GitHub Actions CI/CD builds working
5. Provide a reproducible development environment

## Primary Recommendation

For the best developer experience:

1. **Linux development**: Use the dev container for fast iteration with native Linux builds
2. **Windows validation**: Rely on GitHub Actions for Windows builds, or use cross-compilation for quick checks
3. **Production releases**: Always use native platform builds from CI/CD

The cross-compilation feature is a convenience for rapid feedback, not a replacement for native builds.

## Research Summary

### Base Image Selection

The recommended base image is `mcr.microsoft.com/devcontainers/cpp`:

| Image Variant        | Description          | Recommendation                   |
| -------------------- | -------------------- | -------------------------------- |
| `cpp:1-debian-12`    | Debian 12 (Bookworm) | Stable, well-tested              |
| `cpp:1-ubuntu-24.04` | Ubuntu 24.04 LTS     | Latest LTS, good package support |
| `cpp:1-ubuntu-22.04` | Ubuntu 22.04 LTS     | Broader compatibility            |

The cpp dev container image includes:

- GCC and Clang compilers
- CMake (latest version)
- vcpkg package manager
- Common development utilities

**Recommendation**: Use `mcr.microsoft.com/devcontainers/cpp:1-debian-12` for stability and broad package availability.

**Note for Apple Silicon (M1/M2/M3) users**: Dev containers run under Rosetta 2 emulation or native ARM64. The container
will use the host architecture. Cross-compiling Windows x86_64 from ARM64 Linux works correctly with MinGW-w64.

### JUCE Linux Dependencies

Required packages from JUCE documentation:

```bash
# Core audio/MIDI support
libasound2-dev
libjack-jackd2-dev

# Plugin hosting (LADSPA)
ladspa-sdk

# Network and data
libcurl4-openssl-dev

# Font rendering
libfreetype-dev
libfontconfig1-dev

# X11 display (required for GUI)
libx11-dev
libxcomposite-dev
libxcursor-dev
libxext-dev
libxinerama-dev
libxrandr-dev
libxrender-dev

# WebKit (for web views)
libwebkit2gtk-4.1-dev

# OpenGL
libglu1-mesa-dev
mesa-common-dev
```

### Windows Cross-Compilation

MinGW-w64 provides Windows cross-compilation from Linux:

```bash
# Core packages
mingw-w64
g++-mingw-w64-x86-64-posix
gcc-mingw-w64-x86-64-posix

# Additional tools
binutils-mingw-w64-x86-64
```

**Key findings from JUCE community**:

1. Use POSIX threading model (`-posix` suffix) for C++ standard library compatibility
2. JUCE 8.x has improved MinGW support compared to earlier versions
3. Historical issues with `__mingw_uuidof` macro have been resolved in recent versions
4. Cross-compiled VST3 plugins require testing on actual Windows hosts
5. VST3 format is preferred; AU format is macOS-only and not cross-compilable

**CMake Changes Required**: The project's CMakeLists.txt may need adjustments:

```cmake
# In CMakeLists.txt, ensure formats are platform-appropriate
if(CMAKE_CROSSCOMPILING AND CMAKE_SYSTEM_NAME STREQUAL "Windows")
    set(PLUGIN_FORMATS VST3 Standalone)
    message(STATUS "Cross-compiling for Windows: VST3, Standalone")
elseif(APPLE)
    set(PLUGIN_FORMATS VST3 Standalone AU)
else()
    set(PLUGIN_FORMATS VST3 Standalone)
endif()
```

**CMake Toolchain File Required**: Create a toolchain file for cross-compilation:

```cmake
# toolchain-mingw64.cmake
set(CMAKE_SYSTEM_NAME Windows)
set(CMAKE_SYSTEM_PROCESSOR x86_64)

set(CMAKE_C_COMPILER x86_64-w64-mingw32-gcc-posix)
set(CMAKE_CXX_COMPILER x86_64-w64-mingw32-g++-posix)
set(CMAKE_RC_COMPILER x86_64-w64-mingw32-windres)

set(CMAKE_FIND_ROOT_PATH /usr/x86_64-w64-mingw32)
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
```

### Existing JUCE Docker Projects

Reviewed projects for reference patterns:

| Project                      | Base Image          | Key Features                       |
| ---------------------------- | ------------------- | ---------------------------------- |
| eyalamirmusic/JuceDevMachine | ubuntu:latest       | Clang, CMake, Ninja, multi-arch    |
| eyalamirmusic/JuceDocker     | JuceDevMachine      | CPM.cmake for JUCE                 |
| docker-juce-build-windows    | Windows Server 2019 | Native Windows (not cross-compile) |

**JuceDevMachine Dockerfile Pattern**:

```dockerfile
FROM ubuntu:latest AS base
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    git clang cmake ninja-build pkg-config \
    # JUCE dependencies...

# Set Clang as default compiler
RUN update-alternatives --install /usr/bin/cc cc /usr/bin/clang 100
RUN update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang++ 100
```

### Dev Container Features

Available features to enhance the container:

| Feature      | Reference                                       | Purpose         |
| ------------ | ----------------------------------------------- | --------------- |
| common-utils | `ghcr.io/devcontainers/features/common-utils:2` | Zsh, utilities  |
| node         | `ghcr.io/devcontainers/features/node:1`         | For npm tooling |
| github-cli   | `ghcr.io/devcontainers/features/github-cli:1`   | gh commands     |

## Implementation Plan

### Phase 1: Directory Structure

Create the following structure:

```text
.devcontainer/
├── devcontainer.json       # Main configuration
├── Dockerfile              # Custom image build
├── post-create.sh          # Post-creation setup
└── toolchains/
    └── mingw64.cmake       # Windows cross-compile toolchain
```

### Phase 2: Dockerfile

```dockerfile
# .devcontainer/Dockerfile
FROM mcr.microsoft.com/devcontainers/cpp:1-debian-12

# Install JUCE dependencies
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get install -y --no-install-recommends \
    # Audio/MIDI
    libasound2-dev \
    libjack-jackd2-dev \
    # Plugin hosting
    ladspa-sdk \
    # Network
    libcurl4-openssl-dev \
    # Fonts
    libfreetype-dev \
    libfontconfig1-dev \
    # X11
    libx11-dev \
    libxcomposite-dev \
    libxcursor-dev \
    libxext-dev \
    libxinerama-dev \
    libxrandr-dev \
    libxrender-dev \
    # WebKit
    libwebkit2gtk-4.1-dev \
    # OpenGL
    libglu1-mesa-dev \
    mesa-common-dev \
    # Build tools
    ninja-build \
    pkg-config \
    clang-format \
    ccache \
    lldb \
    gdb \
    # Headless GUI testing
    xvfb \
    # MinGW for Windows cross-compilation
    mingw-w64 \
    g++-mingw-w64-x86-64-posix \
    && apt-get autoremove -y && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Set Clang as default compiler (matches JuceDevMachine pattern)
RUN update-alternatives --install /usr/bin/cc cc /usr/bin/clang 100 \
    && update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang++ 100

# Enable ccache for faster rebuilds
ENV PATH="/usr/lib/ccache:${PATH}"
```

### Phase 3: devcontainer.json

```json
{
  "name": "JUCE Development",
  "build": {
    "dockerfile": "Dockerfile"
  },
  "hostRequirements": {
    "cpus": 4,
    "memory": "8gb",
    "storage": "32gb"
  },
  "features": {
    "ghcr.io/devcontainers/features/common-utils:2": {
      "installZsh": true,
      "configureZshAsDefaultShell": true
    },
    "ghcr.io/devcontainers/features/node:1": {
      "version": "lts"
    },
    "ghcr.io/devcontainers/features/github-cli:1": {}
  },
  "mounts": ["source=juce-ccache,target=/home/vscode/.ccache,type=volume"],
  "containerEnv": {
    "CCACHE_DIR": "/home/vscode/.ccache"
  },
  "customizations": {
    "vscode": {
      "extensions": [
        "ms-vscode.cpptools",
        "ms-vscode.cpptools-extension-pack",
        "ms-vscode.cmake-tools",
        "llvm-vs-code-extensions.vscode-clangd",
        "twxs.cmake",
        "vadimcn.vscode-lldb",
        "xaver.clang-format"
      ],
      "settings": {
        "cmake.generator": "Ninja",
        "cmake.configureOnOpen": true,
        "cmake.useCMakePresets": "always",
        "C_Cpp.default.configurationProvider": "ms-vscode.cmake-tools",
        "files.associations": {
          "*.h": "cpp",
          "*.hpp": "cpp",
          "*.cpp": "cpp"
        }
      }
    }
  },
  "postCreateCommand": ".devcontainer/post-create.sh",
  "remoteUser": "vscode"
}
```

### Phase 4: Post-Create Script

Create with executable permissions (`chmod +x .devcontainer/post-create.sh`):

```bash
#!/bin/bash
# .devcontainer/post-create.sh
set -euo pipefail

echo "Setting up JUCE development environment..."

# Install npm dependencies for linting tools
if [ -f "package.json" ]; then
    echo "Installing npm dependencies..."
    npm install
fi

# Initialize git submodules if not already done
if [ -f ".gitmodules" ] && [ ! -f "third_party/JUCE/CMakeLists.txt" ]; then
    echo "Initializing git submodules..."
    git submodule update --init --recursive
fi

# Configure with Ninja preset for fast builds
echo "Configuring CMake with Ninja..."
cmake --preset=ninja

# Verify MinGW is available for cross-compilation
if command -v x86_64-w64-mingw32-g++-posix &> /dev/null; then
    echo "MinGW-w64 available for Windows cross-compilation"
    echo "  Configure with: cmake --preset=mingw64"
else
    echo "Warning: MinGW-w64 not found, Windows cross-compilation unavailable"
fi

echo ""
echo "Dev container setup complete."
echo ""
echo "Build commands:"
echo "  Linux:   cmake --build --preset=ninja"
echo "  Windows: cmake --preset=mingw64 && cmake --build --preset=mingw64"
```

### Phase 5: Windows Cross-Compile Toolchain

```cmake
# .devcontainer/toolchains/mingw64.cmake
set(CMAKE_SYSTEM_NAME Windows)
set(CMAKE_SYSTEM_PROCESSOR x86_64)

# Use POSIX threading model
set(CMAKE_C_COMPILER x86_64-w64-mingw32-gcc-posix)
set(CMAKE_CXX_COMPILER x86_64-w64-mingw32-g++-posix)
set(CMAKE_RC_COMPILER x86_64-w64-mingw32-windres)

# Find libraries in MinGW sysroot
set(CMAKE_FIND_ROOT_PATH /usr/x86_64-w64-mingw32)
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

# C++ standard library
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -static-libgcc -static-libstdc++")
```

### Phase 6: CMake Preset for Windows

Add to `CMakePresets.json` in the `configurePresets` array:

```json
{
  "name": "mingw64",
  "displayName": "MinGW-w64 Windows Cross-Compile",
  "description": "Cross-compile for Windows from Linux",
  "generator": "Ninja",
  "binaryDir": "${sourceDir}/build/mingw64",
  "toolchainFile": "${sourceDir}/.devcontainer/toolchains/mingw64.cmake",
  "cacheVariables": {
    "CMAKE_BUILD_TYPE": "Release"
  },
  "condition": {
    "type": "equals",
    "lhs": "${hostSystemName}",
    "rhs": "Linux"
  }
}
```

And add to the `buildPresets` array:

```json
{
  "name": "mingw64",
  "configurePreset": "mingw64"
}
```

## Build Workflows

### Using Existing Project Scripts

The project includes cross-platform build scripts that work inside the container:

```bash
# Configure with Ninja (uses scripts/configure-ninja.sh on Linux)
./scripts/configure-ninja.sh

# Build (uses scripts/build-ninja.sh on Linux)
./scripts/build-ninja.sh

# Validate build artifacts (works in container for Linux builds)
./scripts/validate-builds.sh
```

Note: `run-standalone.sh` requires a display. Use `xvfb-run` for headless testing:

```bash
xvfb-run ./build/ninja/JucePlugin_artefacts/Debug/Standalone/JUCE\ Project\ Template\ Plugin
```

### Linux Native Build

```bash
# Fast incremental builds (1-3 seconds)
cmake --preset=ninja
cmake --build --preset=ninja
```

### Windows Cross-Compile Build

**Important**: Cross-compilation is experimental. Native Windows builds via GitHub Actions remain the recommended
approach for production releases.

```bash
# Cross-compile for Windows
cmake --preset=mingw64
cmake --build --preset=mingw64

# Artifacts in build/mingw64/JucePlugin_artefacts/Release/VST3/
```

## Known Limitations

### Cross-Compilation Constraints

1. **No GUI testing**: Cross-compiled Windows executables cannot run in Linux container
2. **VST3 validation**: Requires actual Windows host to test plugin loading
3. **Audio device testing**: No Windows audio devices available in container
4. **DAW testing**: Must transfer artifacts to Windows for real-world testing

### JUCE MinGW Known Issues

Based on JUCE GitHub issues and forum discussions:

1. **COM interface issues**: Historical `__mingw_uuidof` problems in `juce_win32_ComInterfaces.h`
   - Status: Resolved in JUCE 7.0.8+ and 8.x
   - Workaround if encountered: Add `-D__uuidof=__mingw_uuidof` to compiler flags

2. **VST3 SDK compatibility**: Some VST3 SDK headers may require patches
   - Status: JUCE 8.0.10 includes fixes
   - Verify: Check `third_party/JUCE/modules/juce_audio_plugin_client/VST3/`

3. **Static linking requirements**: Windows DLLs must be statically linked
   - Already handled in toolchain via `-static-libgcc -static-libstdc++`

4. **Resource compilation**: `.rc` files need `x86_64-w64-mingw32-windres`
   - Already configured in toolchain file

### Risk Assessment

| Risk                           | Likelihood | Impact | Mitigation                          |
| ------------------------------ | ---------- | ------ | ----------------------------------- |
| MinGW build failures           | Medium     | High   | Validate with simple JUCE app first |
| VST3 plugin crashes on Windows | Medium     | High   | Test extensively on Windows hosts   |
| Missing Windows runtime deps   | Low        | Medium | Use static linking                  |
| JUCE version incompatibility   | Low        | High   | Pin to JUCE 8.0.10                  |

### Recommended Workflow

1. Develop and test Linux builds in dev container
2. Cross-compile Windows artifacts
3. Copy artifacts to Windows host for validation
4. Use GitHub Actions for final multi-platform CI/CD

## Alternative Approaches Considered

### Native Windows Container

Not recommended:

- Windows containers require Windows host
- Limited VS Code support
- Does not work on macOS/Linux hosts

### WINE for Testing

Limited utility:

- Cannot fully test VST3 plugin hosting
- Audio drivers not available
- DAW simulation not possible

### Docker-in-Docker with Windows VM

Complex and slow:

- Requires nested virtualization
- Significant resource overhead
- Not practical for development workflow

## Fast Build Optimization

### ccache Integration

Already configured in the main Dockerfile with a persistent volume mount in devcontainer.json. ccache statistics:

```bash
ccache -s   # Show statistics
ccache -C   # Clear cache if needed
```

### Ninja Generator

Already configured:

- 1-3 second incremental builds
- Parallel compilation
- Minimal rebuild on changes

### Precompiled Headers

JUCE supports PCH for faster rebuilds:

```cmake
target_precompile_headers(${PLUGIN_TARGET} PRIVATE
    <juce_audio_processors/juce_audio_processors.h>
)
```

## VS Code Extensions

### Required

- `ms-vscode.cpptools`: C++ IntelliSense
- `ms-vscode.cpptools-extension-pack`: Additional C++ tools
- `ms-vscode.cmake-tools`: CMake integration
- `llvm-vs-code-extensions.vscode-clangd`: Clangd language server

### Recommended

- `twxs.cmake`: CMake syntax highlighting
- `vadimcn.vscode-lldb`: LLDB debugging (included in devcontainer.json)
- `xaver.clang-format`: Code formatting (included in devcontainer.json)
- `cschlosser.doxdocgen`: Documentation generation

### VS Code Tasks

The project's `.vscode/tasks.json` includes platform-specific commands that work automatically in the container.
Available tasks (press `Ctrl+Shift+B` for build):

- **Build Standalone (Ninja Debug)**: Uses `scripts/build-ninja.sh`
- **Build Standalone (Ninja Release)**: Uses `scripts/build-ninja.sh --config Release`
- **Configure Ninja**: Uses `scripts/configure-ninja.sh`
- **Run Standalone**: Runs the standalone app (requires display)

### Debugging in Container

The dev container includes GDB and LLDB for debugging. The existing `.vscode/launch.json` has a "(Linux) Debug
Standalone" configuration that uses GDB:

1. Build with Debug preset: `cmake --build --preset=ninja`
2. Select "(Linux) Debug Standalone" in the Run and Debug view
3. Set breakpoints in source files
4. Press F5 to start debugging

For command-line debugging:

```bash
# Using GDB (matches launch.json)
gdb ./build/ninja/JucePlugin_artefacts/Debug/Standalone/JUCE\ Project\ Template\ Plugin

# Or using LLDB
lldb ./build/ninja/JucePlugin_artefacts/Debug/Standalone/JUCE\ Project\ Template\ Plugin
```

## Testing Strategy

### In-Container Testing

1. Build Linux standalone application
2. Run basic functionality tests
3. Validate build artifacts exist
4. Run clang-format and linting

### Windows Validation

1. Transfer cross-compiled VST3 to Windows
2. Run pluginval for automated validation (download from GitHub)
3. Load in DAW (Reaper, Cubase, etc.)
4. Test plugin functionality
5. Validate audio processing

### CI/CD Integration

Keep existing GitHub Actions:

- Native Windows builds for release artifacts
- Native macOS builds for AU format
- Linux builds for validation
- Cross-compile as supplementary check

## Audio and MIDI Testing Workflow

Testing audio plugins in a container requires virtual audio/MIDI devices. This section describes how to set up a
complete testing environment using JUCE AudioPluginHost.

### Additional Dockerfile Dependencies

Add these packages to the main Dockerfile (Phase 2) for audio testing:

```dockerfile
# Add to the main apt-get install command:
    # Virtual audio/MIDI for testing
    jackd2 \
    alsa-utils \
    pulseaudio \
```

These enable:

- **jackd2**: JACK audio server with dummy driver for virtual audio routing
- **alsa-utils**: ALSA sequencer utilities for MIDI (`aconnect`, `aplaymidi`)
- **pulseaudio**: Optional, for applications that require PulseAudio

### Building JUCE AudioPluginHost

The JUCE AudioPluginHost is included in `third_party/JUCE/extras/AudioPluginHost/`. Build it separately or add to the
post-create script:

```bash
# Build AudioPluginHost for plugin testing
echo "Building JUCE AudioPluginHost..."
mkdir -p build/pluginhost
cd build/pluginhost

# Configure with full JUCE path
cmake ../../third_party/JUCE/extras/AudioPluginHost \
    -G Ninja \
    -DCMAKE_BUILD_TYPE=Release

# Build
cmake --build . --config Release
cd ../..

echo "AudioPluginHost built at: build/pluginhost/AudioPluginHost_artefacts/Release/AudioPluginHost"
```

Note: Building AudioPluginHost adds 2-3 minutes to container setup. Consider making it optional.

### Starting Virtual Audio/MIDI

Create a helper script `.devcontainer/start-audio.sh`:

```bash
#!/bin/bash
# Start virtual audio and MIDI for plugin testing
set -euo pipefail

echo "Starting JACK with dummy driver..."
# Start JACK with dummy (null) audio driver - no real hardware needed
jackd -d dummy -r 48000 -p 512 &
JACK_PID=$!
sleep 2

# Create virtual MIDI ports using ALSA sequencer
echo "MIDI ports available via ALSA sequencer"
echo "Use 'aconnect -l' to list MIDI connections"

echo ""
echo "Virtual audio/MIDI ready."
echo "  JACK sample rate: 48000 Hz"
echo "  JACK buffer size: 512 samples"
echo ""
echo "To stop: kill $JACK_PID"
```

### Testing Your Plugin

#### Method 1: JUCE AudioPluginHost (Recommended)

```bash
# Start virtual audio
./.devcontainer/start-audio.sh

# Run AudioPluginHost with display
xvfb-run -a build/pluginhost/AudioPluginHost_artefacts/Release/AudioPluginHost

# Or with actual display (if X11 forwarding is configured)
build/pluginhost/AudioPluginHost_artefacts/Release/AudioPluginHost
```

In AudioPluginHost:

1. Options → Edit the list of available plug-ins
2. Scan for: `build/ninja/JucePlugin_artefacts/Debug/VST3/`
3. Create a plugin graph with your plugin
4. Connect MIDI input → Plugin → Audio output
5. Test MIDI input and audio processing

#### Method 2: Automated Testing with pluginval

```bash
# Download pluginval for Linux
curl -L -o pluginval.zip \
    https://github.com/Tracktion/pluginval/releases/latest/download/pluginval_Linux.zip
unzip pluginval.zip
chmod +x pluginval

# Run validation (headless)
xvfb-run -a ./pluginval --validate \
    "build/ninja/JucePlugin_artefacts/Debug/VST3/JUCE Project Template Plugin.vst3"
```

#### Method 3: Headless Audio Processing Test

For CI/CD, create a test that processes audio without GUI. Add to your project:

```cpp
// tests/AudioProcessingTest.cpp
#include "DSPJuceAudioProcessor.h"
#include <juce_audio_basics/juce_audio_basics.h>

int main()
{
    DSPJuceAudioProcessor processor;

    // Prepare with test parameters
    processor.prepareToPlay(48000.0, 512);

    // Create test buffer
    juce::AudioBuffer<float> buffer(2, 512);
    buffer.clear();

    // Create MIDI buffer with test note
    juce::MidiBuffer midiBuffer;
    midiBuffer.addEvent(juce::MidiMessage::noteOn(1, 60, 0.8f), 0);

    // Process
    processor.processBlock(buffer, midiBuffer);

    // Verify output (plugin generates audio)
    float peakLevel = buffer.getMagnitude(0, 512);
    if (peakLevel > 0.0f)
    {
        std::cout << "Audio processing test PASSED (peak: " << peakLevel << ")" << std::endl;
        return 0;
    }
    else
    {
        std::cerr << "Audio processing test FAILED (no output)" << std::endl;
        return 1;
    }
}
```

### X11 Forwarding for GUI Testing

For interactive GUI testing from the container, configure X11 forwarding:

#### On macOS Host

```bash
# Install XQuartz
brew install --cask xquartz
# Enable network connections in XQuartz preferences
# Restart and allow connections
```

#### On Linux Host

```bash
# X11 forwarding usually works out of the box
# Add to devcontainer.json runArgs:
"runArgs": ["--env", "DISPLAY=${localEnv:DISPLAY}", "-v", "/tmp/.X11-unix:/tmp/.X11-unix"]
```

#### On Windows Host

```bash
# Install VcXsrv or X410
# Configure to allow connections
# Set DISPLAY=host.docker.internal:0
```

### Testing Checklist

| Test              | Method                       | Notes                               |
| ----------------- | ---------------------------- | ----------------------------------- |
| Plugin loads      | AudioPluginHost or pluginval | Basic validation                    |
| MIDI input        | AudioPluginHost              | Send notes, verify response         |
| Audio output      | AudioPluginHost              | Connect to meter, verify levels     |
| Parameter changes | AudioPluginHost              | Automate parameters                 |
| State save/load   | AudioPluginHost              | Save preset, reload, verify         |
| Edge cases        | pluginval                    | Automated stress testing            |
| Real-world        | Windows DAW                  | Final validation on target platform |

## Troubleshooting

### Container Build Fails

**Symptom**: Dockerfile build fails on apt-get

**Solution**: Check package names for your Debian/Ubuntu version

```bash
# Verify package availability
apt-cache search libwebkit2gtk
```

Some older distributions use `libwebkit2gtk-4.0-dev` instead of `4.1`.

### CMake Configure Fails in Container

**Symptom**: `cmake --preset=ninja` fails with missing dependencies

**Solutions**:

1. Verify JUCE submodule is initialized:

   ```bash
   git submodule update --init --recursive
   ```

2. Check pkg-config finds dependencies:

   ```bash
   pkg-config --exists alsa freetype2 x11
   ```

### MinGW Cross-Compilation Fails

**Symptom**: `cmake --preset=mingw64` fails

**Common causes**:

1. MinGW not installed: Install `g++-mingw-w64-x86-64-posix`
2. Toolchain file not found: Verify path in preset
3. JUCE version issue: Ensure JUCE 8.0.10+

### Windows VST3 Fails to Load

**Symptom**: Cross-compiled plugin crashes or fails to scan

**Solutions**:

1. Verify static linking:

   ```bash
   x86_64-w64-mingw32-objdump -p plugin.dll | grep "DLL Name"
   # Should only show Windows system DLLs
   ```

2. Check architecture:

   ```bash
   file build/mingw64/JucePlugin_artefacts/Release/VST3/*.dll
   # Should report: PE32+ executable (DLL) x86-64
   ```

3. Test in pluginval on Windows before DAW testing

### Slow Builds

**Symptom**: Builds take longer than expected

**Solutions**:

1. Enable ccache in Dockerfile
2. Use Ninja generator (already configured)
3. Add precompiled headers for JUCE modules
4. Mount ccache volume between sessions

## Implementation Checklist

### Phase 1: Basic Container Setup

- [ ] Create `.devcontainer/` directory structure
- [ ] Write `Dockerfile` with JUCE dependencies
- [ ] Write `devcontainer.json` with features and settings
- [ ] Create `post-create.sh` setup script
- [ ] Test container builds and opens in VS Code

### Phase 2: Linux Build Validation

- [ ] Verify `cmake --preset=ninja` succeeds
- [ ] Verify `cmake --build --preset=ninja` completes
- [ ] Check Linux standalone executable exists
- [ ] Run `npm test` for linting validation
- [ ] Verify clang-format works

### Phase 3: Audio/MIDI Testing Setup

- [ ] Build JUCE AudioPluginHost
- [ ] Create `start-audio.sh` helper script
- [ ] Test JACK dummy driver starts
- [ ] Load plugin in AudioPluginHost
- [ ] Verify MIDI and audio routing works
- [ ] Download and run pluginval

### Phase 4: Windows Cross-Compilation

- [ ] Create MinGW toolchain file
- [ ] Add `mingw64` preset to `CMakePresets.json`
- [ ] Test `cmake --preset=mingw64` configures
- [ ] Test `cmake --build --preset=mingw64` completes
- [ ] Verify VST3 bundle structure is correct
- [ ] Transfer VST3 to Windows and test loading

### Phase 5: Documentation and CI

- [ ] Document usage in README
- [ ] Add dev container badge to README
- [ ] Test with GitHub Codespaces
- [ ] Validate existing CI/CD still works

## GitHub Codespaces Compatibility

The dev container should work with GitHub Codespaces with these considerations:

### Supported Features

- Full Linux native builds
- Windows cross-compilation
- npm tooling and linting
- CMake and Ninja builds

### Limitations in Codespaces

- No audio device access (expected)
- No X11 display for GUI testing (use headless builds)
- Cross-compiled Windows binaries cannot be tested
- Large JUCE checkout may require larger machine type

### Recommended Codespace Configuration

The `hostRequirements` in `devcontainer.json` ensures sufficient resources:

- 4 CPUs for parallel compilation
- 8GB RAM for linking large binaries
- 32GB storage for JUCE source and build artifacts

## Validation Test Plan

### Test 1: Container Startup

```bash
# Expected: Container builds and starts without errors
# Time: 2-5 minutes first build, <30 seconds subsequent
```

### Test 2: Linux Debug Build

```bash
cmake --preset=ninja
cmake --build --preset=ninja
# Expected: Build completes, artifacts in build/ninja/

# Validate with project script:
BUILD_DIR=build/ninja ./scripts/validate-builds.sh
# Expected: All artifact checks pass
```

### Test 3: Linux Release Build

```bash
cmake --preset=ninja-release
cmake --build --preset=ninja-release
# Expected: Optimized build completes
```

### Test 4: Windows Cross-Compile

```bash
cmake --preset=mingw64
cmake --build --preset=mingw64
# Expected: Build completes with Windows PE executables

# Verify VST3 bundle structure:
ls -la build/mingw64/JucePlugin_artefacts/Release/VST3/
# Expected structure:
#   "JUCE Project Template Plugin.vst3"/
#   └── Contents/
#       └── x86_64-win/
#           └── "JUCE Project Template Plugin.vst3"  (this is the .dll)

# Verify binary type:
file "build/mingw64/JucePlugin_artefacts/Release/VST3/JUCE Project Template Plugin.vst3/Contents/x86_64-win/"*.vst3
# Should report: PE32+ executable (DLL) x86-64, for MS Windows
```

### Test 5: Linting

```bash
npm test
clang-format --dry-run -Werror src/*.cpp src/*.h
# Expected: No linting errors
```

### Test 6: Windows Plugin Validation

On Windows host:

1. Copy entire VST3 bundle folder to `C:\Program Files\Common Files\VST3\`
2. Download [pluginval](https://github.com/Tracktion/pluginval/releases)
3. Run: `pluginval --validate "C:\Program Files\Common Files\VST3\JUCE Project Template Plugin.vst3"`
4. If pluginval passes, test in DAW (Reaper, Cubase, etc.)
5. Verify plugin loads, processes audio, and UI appears correctly

## References

### JUCE Documentation

- [Linux Dependencies](https://github.com/juce-framework/JUCE/blob/master/docs/Linux%20Dependencies.md)
- [CMake API](https://github.com/juce-framework/JUCE/blob/master/docs/CMake%20API.md)

### Dev Container Specification

- [Dev Container Features](https://containers.dev/features)
- [C++ Dev Container Image](https://github.com/devcontainers/images/tree/main/src/cpp)

### Cross-Compilation

- [MinGW-w64 Project](https://www.mingw-w64.org/)
- [CMake Toolchains](https://cmake.org/cmake/help/latest/manual/cmake-toolchains.7.html)

### Related JUCE Docker Projects

- [JuceDevMachine](https://github.com/eyalamirmusic/JuceDevMachine)
- [JuceDocker](https://github.com/eyalamirmusic/JuceDocker)
