# Cross-Platform Build System

This document explains how the DSP-JUCE build system works across Windows, macOS, and Linux.

## Overview

The project uses a **dual-script approach** to support all platforms:

- **Windows**: `.bat` batch files that initialize MSVC environment
- **macOS/Linux**: `.sh` shell scripts that use system compilers

VS Code tasks automatically select the correct script based on your operating system.

## Script Organization

### Windows Scripts

Located in `scripts/`:

- `configure-ninja.bat` - Initializes VS environment and configures CMake
- `build-ninja.bat` - Initializes VS environment and builds with Ninja

**Key features**:

```batch
@echo off
call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat" x64
cmake --preset=ninja
```

The scripts automatically:

1. Locate Visual Studio 2022 installation
2. Initialize x64 developer environment via `vcvarsall.bat`
3. Add MSVC compiler, Ninja, and CMake to PATH
4. Run the requested CMake operation

### Unix Scripts

Located in `scripts/`:

- `configure-ninja.sh` - Configures CMake with Ninja preset
- `build-ninja.sh` - Builds using Ninja

**Key features**:

```bash
#!/bin/bash
set -e  # Exit on error
cmake --preset=ninja
```

The scripts:

1. Use system-installed CMake and Ninja
2. Use default system compiler (Clang on macOS, GCC/Clang on Linux)
3. Follow standard Unix conventions

## VS Code Tasks Configuration

`.vscode/tasks.json` uses platform-specific properties:

```json
{
    "label": "Build Standalone (Ninja Debug)",
    "type": "shell",
    "windows": {
        "command": "${workspaceFolder}\\scripts\\build-ninja.bat"
    },
    "linux": {
        "command": "${workspaceFolder}/scripts/build-ninja.sh"
    },
    "osx": {
        "command": "${workspaceFolder}/scripts/build-ninja.sh"
    }
}
```

VS Code automatically selects the correct `windows`, `linux`, or `osx` block based on the host OS.

## Platform Differences

### Executable Extensions

- **Windows**: `DSP-JUCE Plugin.exe`
- **macOS**: `DSP-JUCE Plugin.app` (application bundle)
- **Linux**: `DSP-JUCE Plugin` (no extension)

The "Run Standalone" task handles this:

```json
{
    "windows": {
        "command": "...\\DSP-JUCE Plugin.exe"
    },
    "osx": {
        "command": "open",
        "args": [".../DSP-JUCE Plugin.app"]
    },
    "linux": {
        "command": ".../DSP-JUCE Plugin"
    }
}
```

### Path Separators

- **Windows**: Backslash `\\` in tasks.json
- **macOS/Linux**: Forward slash `/` in tasks.json

VS Code handles this automatically via platform-specific properties.

### Compiler Flags

CMakeLists.txt adapts compiler flags per platform:

```cmake
if(MSVC)
    add_compile_options(/EHsc /W4 /permissive- /Zc:__cplusplus)
else()
    add_compile_options(-Wall -Wextra -Wpedantic)
endif()
```

## Prerequisites by Platform

### Windows

- Visual Studio 2022 Community or higher
- Includes CMake, Ninja, and MSVC automatically
- No additional installations needed

### macOS

```bash
# Install Xcode Command Line Tools
xcode-select --install

# Install Ninja via Homebrew
brew install ninja cmake

# Or via MacPorts
sudo port install ninja cmake
```

### Linux (Ubuntu/Debian)

```bash
sudo apt-get update
sudo apt-get install -y \
    build-essential \
    cmake \
    ninja-build \
    libasound2-dev \
    libx11-dev \
    libxcomposite-dev \
    libxcursor-dev \
    libxinerama-dev \
    libxrandr-dev \
    libfreetype6-dev \
    libfontconfig1-dev \
    libgl1-mesa-dev \
    libcurl4-openssl-dev \
    libwebkit2gtk-4.1-dev \
    pkg-config
```

## Build Output Structure

All platforms use the same output structure:

```text
build/ninja/
├── JucePlugin_artefacts/
│   ├── Debug/
│   │   ├── VST3/
│   │   │   └── DSP-JUCE Plugin.vst3/
│   │   └── Standalone/
│   │       └── DSP-JUCE Plugin[.exe|.app]
│   └── Release/
│       └── (same structure)
└── JuceLibraryCode/
```

## CMake Presets

The `ninja` preset in `CMakePresets.json` works on all platforms:

```json
{
    "name": "ninja",
    "displayName": "Ninja Multi-Config",
    "generator": "Ninja",
    "binaryDir": "${sourceDir}/build/ninja"
}
```

Platform detection happens via CMake's built-in variables:

- `WIN32` - True on Windows
- `APPLE` - True on macOS
- `UNIX` - True on Linux/macOS

## Testing Cross-Platform Builds

### Windows Platform

```cmd
scripts\configure-ninja.bat
scripts\build-ninja.bat
```

### macOS/Linux Platforms

```bash
./scripts/configure-ninja.sh
./scripts/build-ninja.sh
```

### VS Code (All Platforms)

Press `Ctrl+Shift+B` (or `Cmd+Shift+B` on macOS) to build.

## Troubleshooting

### Windows: "vcvarsall.bat not found"

Ensure Visual Studio 2022 is installed with "Desktop development with C++" workload.

### macOS: "ninja: command not found"

Install Ninja: `brew install ninja`

### Linux: Missing JUCE dependencies

Run: `sudo apt-get install -y libasound2-dev libx11-dev ...` (see full list above)

### Scripts not executable (macOS/Linux)

```bash
chmod +x scripts/*.sh
```

## Advantages of This Approach

1. **Native toolchain**: Uses MSVC on Windows, Clang on macOS, GCC/Clang on Linux
2. **No Docker required**: Direct builds on all platforms
3. **IDE integration**: Works seamlessly with VS Code tasks
4. **Minimal configuration**: CMake presets are platform-agnostic
5. **Consistent workflow**: Same keyboard shortcuts on all platforms

## Future Enhancements

- Add CMake toolchain files for cross-compilation
- Support ARM64 builds on macOS and Windows
- Add CI/CD workflows for automated multi-platform builds
- Create universal binaries for macOS (x64 + ARM64)

## Related Documentation

- [DEVELOPMENT_WORKFLOW.md](DEVELOPMENT_WORKFLOW.md) - Daily development workflow
- [BUILD.md](BUILD.md) - Platform-specific build instructions
- [CMakePresets.json](CMakePresets.json) - Available build presets

## Summary

The cross-platform build system provides:

- **Zero manual environment setup** on Windows (uses vcvarsall.bat)
- **Standard Unix conventions** on macOS/Linux
- **Single `Ctrl+Shift+B` workflow** across all platforms
- **Same output structure** regardless of OS

This enables developers to work on any platform without changing their workflow.
