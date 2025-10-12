# Ninja Build System Guide

Complete guide to using Ninja for fast JUCE plugin development with this template.

## Overview

Ninja is a fast, minimal build system that provides significantly faster incremental builds
compared to Visual Studio/MSBuild or Make. This template includes pre-configured scripts
and VS Code tasks for Ninja.

## Why Ninja?

### Performance Benefits

**Incremental build speed**:

- Ninja: 1-3 seconds for small changes
- MSBuild (Visual Studio): 10-30 seconds for same changes
- Make: 5-15 seconds for same changes

**Full build speed**:

- Ninja: 2-5 minutes (Debug), 3-7 minutes (Release)
- MSBuild: 3-6 minutes (Debug), 5-10 minutes (Release)
- Make: Similar to Ninja on Unix platforms

### Other Benefits

- Minimal overhead and memory usage
- Parallel builds by default
- Cross-platform consistency
- Excellent CMake integration
- Simple command-line interface

## Installation

### Windows

**Option 1: Visual Studio Installer** (Recommended)

Visual Studio 2022 includes Ninja:

1. Open Visual Studio Installer
2. Modify Visual Studio 2022
3. Under "Individual components", search for "Ninja"
4. Check "C++ CMake tools for Windows"
5. Install

Ninja will be available when using Developer Command Prompt or when scripts
initialize vcvarsall.bat.

#### Option 2: Manual Installation

1. Download from [Ninja releases](https://github.com/ninja-build/ninja/releases)
2. Extract `ninja.exe` to a folder (e.g., `C:\Tools\Ninja`)
3. Add folder to system PATH:
   - Open Start → Search "Environment Variables"
   - Edit "Path" variable
   - Add folder path (e.g., `C:\Tools\Ninja`)
4. Verify installation:

   ```cmd
   ninja --version
   ```

### macOS

Install via Homebrew:

```bash
brew install ninja
```

Verify installation:

```bash
ninja --version
```

### Linux (Ubuntu/Debian)

Install via package manager:

```bash
sudo apt-get install ninja-build
```

Verify installation:

```bash
ninja --version
```

**Note**: On some Linux distributions, the command is `ninja-build` instead of `ninja`.

### Linux (Other Distributions)

**Fedora/RHEL**:

```bash
sudo dnf install ninja-build
```

**Arch Linux**:

```bash
sudo pacman -S ninja
```

## Using Ninja with This Template

### Quick Start

**Configure once**:

```bash
# Windows
scripts\configure-ninja.bat

# macOS/Linux
./scripts/configure-ninja.sh
```

**Build repeatedly**:

```bash
# Windows
scripts\build-ninja.bat

# macOS/Linux
./scripts/build-ninja.sh
```

**VS Code**: Press `Ctrl+Shift+B` to build (runs build-ninja script automatically)

### Configuration Options

**Debug build** (default):

```bash
./scripts/build-ninja.sh
# Output: build/ninja/JucePlugin_artefacts/Debug/
```

**Release build**:

```bash
./scripts/build-ninja.sh --config Release
# Output: build/ninja/JucePlugin_artefacts/Release/
```

**Both configurations** (share same build directory):

```bash
# Configure once
./scripts/configure-ninja.sh

# Build both
./scripts/build-ninja.sh                    # Debug
./scripts/build-ninja.sh --config Release   # Release
```

### Direct CMake Usage

Instead of scripts, you can use CMake directly:

**Configure**:

```bash
cmake --preset=ninja
```

**Build Debug**:

```bash
cmake --build build/ninja --config Debug
```

**Build Release**:

```bash
cmake --build build/ninja --config Release
```

## Ninja vs Other Build Systems

### Comparison Table

| Feature | Ninja | MSBuild | Unix Make | Xcode |
|---------|-------|---------|-----------|-------|
| Incremental build speed | Fastest | Slow | Fast | Medium |
| Full build speed | Fast | Medium | Fast | Medium |
| Cross-platform | Yes | No (Windows) | Yes | No (macOS) |
| IDE integration | Via tasks | Native (VS) | Via tasks | Native |
| Memory usage | Low | High | Low | Medium |
| Build file readability | Low | Medium | Medium | N/A |
| CMake support | Excellent | Excellent | Excellent | Excellent |

### When to Use Each

**Use Ninja when**:

- Fast iteration is priority
- Cross-platform development
- CI/CD automation
- Command-line or VS Code workflow

**Use MSBuild/Visual Studio when**:

- Visual Studio IDE is primary environment
- Windows-only development
- Need Visual Studio debugger integration
- Prefer GUI build tools

**Use Unix Make when**:

- Traditional Unix workflow
- Ninja not available
- Simple build requirements

**Use Xcode when**:

- macOS-only development
- Xcode IDE is primary environment
- Need Xcode-specific features

## Build Directory Structure

Ninja builds output to `build/ninja/`:

```text
build/ninja/
├── CMakeCache.txt
├── build.ninja              # Ninja build file (auto-generated)
├── compile_commands.json    # For IDE IntelliSense
├── plugin_metadata.sh       # Generated metadata
└── JucePlugin_artefacts/    # Build outputs (name from PLUGIN_TARGET)
    ├── Debug/
    │   ├── VST3/
    │   ├── Standalone/
    │   └── lib*.a
    └── Release/
        ├── VST3/
        ├── Standalone/
        └── lib*.a
```

**Note**: `JucePlugin` is the default `PLUGIN_TARGET`. Change in `CMakeLists.txt` to customize.

## VS Code Integration

### Tasks

Pre-configured tasks in `.vscode/tasks.json`:

1. **Build Standalone (Ninja Debug)** - Default build task (`Ctrl+Shift+B`)
2. **Build Standalone (Ninja Release)** - Release build
3. **Run Standalone** - Build and run Debug
4. **Run Standalone (Release)** - Build and run Release
5. **Configure Ninja** - Reconfigure CMake

See [VSCODE_INTEGRATION.md](VSCODE_INTEGRATION.md) for complete VS Code setup.

### IntelliSense

Ninja generates `compile_commands.json` for IntelliSense:

- VS Code C/C++ extension auto-detects this file
- Provides accurate code completion and navigation
- Updates automatically on CMake reconfiguration

## Workflow Examples

### Daily Development

Fast edit-build-test cycle:

```bash
# 1. Edit source files
# 2. Build (1-3 seconds for small changes)
./scripts/build-ninja.sh

# 3. Test
./scripts/run-standalone.sh Debug
```

**Or in VS Code**:

1. Edit files
2. Press `Ctrl+Shift+B`
3. Run "Run Standalone" task

### Pre-Release Testing

Build and test Release configuration:

```bash
# Build Release
./scripts/build-ninja.sh --config Release

# Validate artifacts
./scripts/validate-builds.sh Release

# Test Release build
./scripts/run-standalone.sh Release
```

### Multi-Configuration Development

Work on both Debug and Release:

```bash
# Configure once
./scripts/configure-ninja.sh

# Build Debug (fast iteration)
./scripts/build-ninja.sh

# Build Release (periodic testing)
./scripts/build-ninja.sh --config Release

# Both share build/ninja/ directory
```

### Clean Rebuild

Force complete rebuild:

```bash
# Delete build directory
rm -rf build/ninja

# Reconfigure
./scripts/configure-ninja.sh

# Build
./scripts/build-ninja.sh
```

## Troubleshooting

### Ninja Not Found

**Symptom**: `ninja: command not found` or `'ninja' is not recognized`

**Windows fix**:

1. Use Visual Studio Developer Command Prompt, or
2. Run scripts (they initialize VS environment), or
3. Install Ninja and add to PATH

**macOS fix**:

```bash
brew install ninja
```

**Linux fix**:

```bash
sudo apt-get install ninja-build
```

### Build Fails with "No rule to make target"

**Symptom**: Ninja reports missing dependencies or targets

**Fix**: Reconfigure CMake:

```bash
./scripts/configure-ninja.sh
```

### Incremental Build Not Working

**Symptom**: Ninja rebuilds everything on every build

**Causes**:

- CMakeLists.txt timestamp changed (expected)
- Source file moved or renamed (expected)
- Build system corruption (needs clean rebuild)

**Fix**: If corruption suspected:

```bash
rm -rf build/ninja
./scripts/configure-ninja.sh
./scripts/build-ninja.sh
```

### VS Code Tasks Fail

**Symptom**: VS Code tasks cannot find Ninja or build fails

**Fix**:

1. Ensure Ninja is installed
2. Run "Configure Ninja" task first
3. Check task output for specific errors
4. Restart VS Code

### Slow Builds

**Symptom**: Ninja builds are slower than expected

**Possible causes**:

1. **Antivirus scanning**: Exclude `build/` directory from real-time scanning
2. **HDD instead of SSD**: Use SSD for build directory
3. **Low RAM**: Close other applications during build
4. **Debug build**: Use Release for faster runtime (slower compile)

**Check parallel builds**:

```bash
# Ninja auto-detects CPU cores
# Force specific job count if needed
cmake --build build/ninja -j4  # Use 4 parallel jobs
```

## Advanced Usage

### Verbose Build Output

See actual commands executed:

```bash
cmake --build build/ninja --verbose
```

### Build Specific Target

Build only specific component:

```bash
# Build only VST3
cmake --build build/ninja --target JucePlugin_VST3

# Build only Standalone
cmake --build build/ninja --target JucePlugin_Standalone
```

**Note**: Replace `JucePlugin` with your `PLUGIN_TARGET` from CMakeLists.txt.

### Parallel Build Control

Control parallelism:

```bash
# Auto-detect (default)
cmake --build build/ninja

# Force specific job count
cmake --build build/ninja -j4

# Single-threaded (for debugging)
cmake --build build/ninja -j1
```

### CMake Reconfiguration

Force CMake reconfiguration without full clean:

```bash
cmake --preset=ninja --fresh
```

This regenerates build files but keeps build artifacts.

## Performance Optimization Tips

### Build Directory Location

**Best**: SSD with high IOPS
**Good**: Local SSD or HDD
**Avoid**: Network drives, cloud-synced folders

### Antivirus Exclusions

Add to antivirus exclusions:

- `build/` directory
- `ninja.exe` (Windows)
- Project source directory during builds

### Parallel Job Count

Ninja auto-detects optimal job count. Override only if:

- Running out of RAM: Use `-j2` or `-j4`
- Want faster builds on high-core CPU: Use `-j$(nproc)` (Linux) or `-j8` (manual)

### Precompiled Headers

JUCE uses precompiled headers automatically. Ensure they are enabled:

- First build will be slower (generates PCH)
- Subsequent builds much faster (uses PCH)

## See Also

- [DEVELOPMENT_WORKFLOW.md](../DEVELOPMENT_WORKFLOW.md) - Development workflow
- [VSCODE_INTEGRATION.md](VSCODE_INTEGRATION.md) - VS Code setup and debugging
- [BUILD.md](../BUILD.md) - Build system overview
- [CROSS_PLATFORM_BUILDS.md](CROSS_PLATFORM_BUILDS.md) - Platform-specific builds
- [Official Ninja Manual](https://ninja-build.org/manual.html) - Ninja documentation
