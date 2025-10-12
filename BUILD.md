# Build Instructions

Build the project on Windows, macOS, and Linux.

## Prerequisites

Required software:

- CMake 3.22 or higher
- C++20 compiler (MSVC 2019+, GCC 10+, or Clang 11+)
- Git

### Windows

Install Visual Studio 2019 or later with "Desktop development with C++" workload.

Verify installation:

```powershell
cmake --version
cl
```

### macOS

Install Xcode command line tools and CMake:

```bash
xcode-select --install
brew install cmake

cmake --version
clang++ --version
```

### Linux (Ubuntu/Debian)

Install build tools and JUCE dependencies:

```bash
sudo apt-get update && sudo apt-get install -y \
    build-essential cmake git \
    libasound2-dev libx11-dev libxcomposite-dev libxcursor-dev \
    libxinerama-dev libxrandr-dev libfreetype6-dev libfontconfig1-dev \
    libgl1-mesa-dev libwebkit2gtk-4.1-dev pkg-config

cmake --version && g++ --version
```

## Build Steps

### 1. Configure (90 seconds)

Download JUCE and generate build files:

```bash
cmake --preset=default
```

Choose the appropriate preset for your platform:

- `default`: `build/` (Linux/macOS)
- `vs2022`: `build/vs2022/` (Windows)
- `ninja`: `build/ninja/` (all platforms)

### 2. Build (3-5 minutes)

Compile source code and JUCE modules:

```bash
# Debug build
cmake --build --preset=default

# Release build
cmake --preset=release
cmake --build --preset=release
```

### 3. Verify Build

Check build outputs:

```bash
# List artefacts
ls -la build/JucePlugin_artefacts/Debug/

# Run validation
./scripts/validate-builds.sh Debug
```

## Build Outputs

Artefacts are in `build/JucePlugin_artefacts/<config>/`:

- `VST3/DSP-JUCE Plugin.vst3` - VST3 plugin
- `AU/DSP-JUCE Plugin.component` - AU plugin (macOS only)
- `Standalone/DSP-JUCE Plugin[.exe|.app]` - Standalone application

Plugin file names use the `PLUGIN_NAME` variable defined in `CMakeLists.txt`. For example, setting
`PLUGIN_NAME` to "MyPlugin" will produce artefacts like `VST3/MyPlugin.vst3`,
`AU/MyPlugin.component`, and `Standalone/MyPlugin[.exe|.app]`.

## CMake Presets

Available presets in `CMakePresets.json`:

| Preset | Generator | Platform | Build Dir |
|--------|-----------|----------|-----------|
| `default` | Unix Makefiles | Linux/macOS | `build/` |
| `release` | Unix Makefiles | Linux/macOS | `build/release/` |
| `vs2022` | Visual Studio 17 | Windows | `build/vs2022/` |
| `ninja` | Ninja | All | `build/ninja/` |
| `xcode` | Xcode | macOS | `build/xcode/` |

Usage:

```bash
# Configure with preset
cmake --preset=ninja

# Build with preset
cmake --build --preset=ninja
```

## Troubleshooting

### CMake Configure Fails

Check CMake version:

```bash
cmake --version  # Must be 3.22+
```

Clear cache and retry:

```bash
rm -rf build/
cmake --preset=default
```

### Compiler Errors

Verify C++20 support:

```bash
g++ -std=c++20 --version      # Linux
clang++ -std=c++20 --version  # macOS
cl /std:c++20                 # Windows (in Developer Command Prompt)
```

### JUCE Download Fails

Check internet connection and firewall.

Test Git access:

```bash
git clone https://github.com/juce-framework/JUCE.git /tmp/test-juce
```

### Plugin Not Found by DAW

Install plugin to system directory:

- Linux: `~/.vst3/`
- Windows: `%PROGRAMFILES%\Common Files\VST3\`
- macOS: `/Library/Audio/Plug-Ins/VST3/`

Then rescan plugins in your DAW.

### Performance Issues

Use Release builds for production:

```bash
cmake --preset=release
cmake --build --preset=release
```
