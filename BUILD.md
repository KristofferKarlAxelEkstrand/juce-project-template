# Build Instructions

This document provides detailed build instructions for the DSP-JUCE project on Windows, macOS, and Linux.

## Prerequisites

Ensure you have the following software installed:

- **CMake**: Version 3.22 or higher.
- **C++ Compiler**: A compiler with C++20 support (e.g., MSVC, GCC, Clang).
- **Git**: For cloning the repository and managing dependencies.

### Platform-Specific Dependencies

#### Windows

- **Visual Studio**: 2019 or later with the "Desktop development with C++" workload. The Community edition is sufficient.

#### macOS

- **Xcode Command Line Tools**: Install by running `xcode-select --install` in your terminal.
- **Homebrew**: Used for installing CMake.

#### Linux (Ubuntu/Debian)

- **Build Essentials**: A set of core development tools.
- **Libraries**: Various libraries for audio, GUI, and web functionality.

```bash
sudo apt-get update
sudo apt-get install -y \
    build-essential cmake \
    libasound2-dev libx11-dev libxcomposite-dev libxcursor-dev \
    libxinerama-dev libxrandr-dev libfreetype6-dev libfontconfig1-dev \
    libgl1-mesa-dev libwebkit2gtk-4.1-dev pkg-config
```

## Build Process

The project uses a preset-based CMake configuration for simplified building.

### 1. Configure the Project

This step generates the native build files for your platform. It also downloads the JUCE dependency via `FetchContent`.

```bash
# For Linux, macOS, or Windows using the default preset
cmake --preset=default
```

### 2. Build the Project

This compiles the source code and creates the plugin and standalone application.

```bash
# This command works for all default presets
cmake --build --preset=default
```

For **Release** builds, use the `release` preset:

```bash
cmake --preset=release
cmake --build --preset=release
```

### Build Artifacts

The compiled binaries are placed in the `build/DSPJucePlugin_artefacts/` directory, organized by build configuration (e.g., `Debug`, `Release`).

- **VST3 Plugin**: `VST3/DSP-JUCE Plugin.vst3`
- **AU Plugin** (macOS): `AU/DSP-JUCE Plugin.component`
- **Standalone Application**: `Standalone/DSP-JUCE Plugin` (or `.exe` on Windows)

## Troubleshooting

### Common Build Issues

- **CMake Not Found**: Ensure CMake is installed and its location is in your system's `PATH`.
- **Compiler Not Found**: Make sure you have a C++20 compatible compiler installed (Visual Studio, Xcode, or GCC/Clang).
- **JUCE Download Fails**: Check your internet connection. If you are behind a firewall, you may need to configure Git to use a proxy.
- **Plugin Not Found by DAW**:
    - Ensure the plugin is installed in a directory that your DAW scans.
    - Verify that the plugin architecture (e.g., 64-bit) matches your DAW.
    - Force your DAW to rescan for new plugins.

For more detailed troubleshooting, refer to the official JUCE and CMake documentation.
