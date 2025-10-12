# Development Workflow

This document explains the fast, iterative development workflow for DSP-JUCE using VS Code and Ninja.

## Quick Start: Edit → Build → Run

The fastest development loop uses VS Code tasks with Ninja for sub-second incremental builds:

1. **Edit** your source files in `src/`
2. **Build** by pressing `Ctrl+Shift+B` (default build task)
3. **Run** the standalone plugin with `Ctrl+Shift+P` → "Run Task" → "Run Standalone"

## Why Ninja?

Ninja provides dramatically faster incremental builds compared to Visual Studio's MSBuild:

- **Configuration**: 1.2s (vs. 49.6s for initial configure)
- **Full rebuild**: Similar to VS2022 (~2m45s for Debug)
- **Incremental rebuild**: Sub-second for small changes (vs. 10-30s with MSBuild)
- **Parallel compilation**: Optimal CPU utilization on multi-core systems

This "hot-reload-like" experience makes development significantly faster.

## VS Code Tasks

Three automated tasks are configured in `.vscode/tasks.json`:

### 1. Build Standalone (Ninja Debug) - Default Task

**Shortcut**: `Ctrl+Shift+B`

Builds the Debug configuration using Ninja. This is the fastest way to compile changes.

```bash
# What it does internally:
./scripts/build-ninja.bat
```

**Output**: `build/ninja/JucePlugin_artefacts/Debug/Standalone/DSP-JUCE Plugin.exe`

### 2. Run Standalone

Builds and then launches the standalone plugin application. Use this to test your changes immediately.

```bash
# Access via:
Ctrl+Shift+P → Tasks: Run Task → Run Standalone
```

**Auto-runs**: "Build Standalone (Ninja Debug)" task first via `dependsOn`

### 3. Configure Ninja

Reconfigures the CMake build system. Only needed when:

- CMakeLists.txt changes
- Adding/removing source files
- Changing build options

```bash
# Access via:
Ctrl+Shift+P → Tasks: Run Task → Configure Ninja
```

## Build Scripts

The project includes cross-platform build scripts that work on Windows, macOS, and Linux.

### Windows: scripts/configure-ninja.bat & build-ninja.bat

Initializes Visual Studio environment and runs CMake/Ninja.

```cmd
# Configure
scripts\configure-ninja.bat

# Build
scripts\build-ninja.bat
```

**Features**:

- Automatically initializes vcvarsall.bat x64 environment
- Includes Ninja from Visual Studio installation
- No manual environment setup required

### macOS/Linux: scripts/configure-ninja.sh & build-ninja.sh

Shell scripts for Unix-like systems.

```bash
# Configure
./scripts/configure-ninja.sh

# Build
./scripts/build-ninja.sh
```

**Requirements**:

- CMake 3.22+
- Ninja (install via `brew install ninja` or `apt-get install ninja-build`)
- Clang or GCC with C++20 support

### Cross-Platform VS Code Tasks

The `.vscode/tasks.json` automatically selects the correct script based on your OS:

- **Windows**: Uses `.bat` files with MSVC toolchain
- **macOS**: Uses `.sh` files with Clang
- **Linux**: Uses `.sh` files with GCC/Clang

**Output locations** (same structure on all platforms):

- Standalone: `build/ninja/JucePlugin_artefacts/Debug/Standalone/DSP-JUCE Plugin[.exe|.app]`
- VST3: `build/ninja/JucePlugin_artefacts/Debug/VST3/DSP-JUCE Plugin.vst3/`
- Shared Code: `build/ninja/Debug/JucePlugin_SharedCode[.lib|.a]`

## Development Workflow Examples

### Typical Edit-Build-Test Cycle

```bash
# 1. Edit source files (MainComponent.cpp, PluginEditor.cpp, etc.)
# 2. Press Ctrl+Shift+B to build
# 3. Run task "Run Standalone" to test

# Total time for small change: 1-3 seconds
```

### Adding New Files

```bash
# 1. Add files to src/ directory
# 2. Update CMakeLists.txt target_sources()
# 3. Run "Configure Ninja" task
# 4. Build with Ctrl+Shift+B
```

### Changing Plugin Metadata

```bash
# 1. Edit PLUGIN_NAME, PLUGIN_VERSION, etc. in CMakeLists.txt
# 2. Run "Configure Ninja" task
# 3. Build with Ctrl+Shift+B
```

## Build Configurations

### Debug (Default)

- Optimizations: Disabled (`/Od`)
- Symbols: Full debug information (`/Zi`)
- Size: Large (~12MB executable)
- Speed: Fastest incremental builds
- Use for: Day-to-day development

### Release

Switch to Release for performance testing or distribution:

```bash
# Using batch scripts directly:
./scripts/build-ninja.bat --config Release

# Output: build/ninja/JucePlugin_artefacts/Release/
```

- Optimizations: Maximum (`/O2`)
- Symbols: Minimal
- Size: Smaller (~8MB)
- Speed: Slower builds but better runtime performance
- Use for: Performance testing, distribution

## Troubleshooting

### Build fails with "exceptions not enabled"

This is already fixed in CMakeLists.txt with `/EHsc` flag. If you see this error:

1. Ensure you've pulled latest CMakeLists.txt changes
2. Reconfigure with "Configure Ninja" task
3. Rebuild

### VS Code tasks not found

Ensure `.vscode/tasks.json` exists. If missing, refer to `plugin-development-roadmap.md` Task 1.1.

### Ninja not found

The batch scripts use vcvarsall.bat which includes Ninja from Visual Studio installation:

```bash
# Verify Ninja is available:
where ninja
# Expected: C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\CommonExtensions\Microsoft\CMake\Ninja\ninja.exe
```

### Slow incremental builds

Ninja should provide sub-second builds for small changes. If slow:

1. Check if you're editing headers included by many files
2. Use `ninja -v` to see compilation command details
3. Consider splitting large translation units

## Performance Comparison

Typical build times on Windows with Visual Studio 2022:

| Configuration | Generator | First Build | Incremental (1 file) | Reconfigure |
|--------------|-----------|-------------|---------------------|-------------|
| Debug | Ninja | ~2m45s | 1-3s | 1.2s |
| Debug | VS2022 | ~2m45s | 10-30s | 49.6s |
| Release | Ninja | ~4m30s | 2-5s | 1.2s |
| Release | VS2022 | ~4m30s | 15-40s | 49.6s |

**Incremental builds are 10-30x faster with Ninja.**

## Advanced Usage

### Build from Command Line

```bash
# Quick rebuild:
./scripts/build-ninja.bat

# Clean rebuild:
rm -rf build/ninja
./scripts/configure-ninja.bat
./scripts/build-ninja.bat

# Build specific target:
cd build/ninja
ninja JucePlugin_Standalone
```

### Parallel Builds

Ninja automatically uses all CPU cores. To limit parallelism:

```bash
# Use only 4 cores:
ninja -j4
```

### Verbose Output

See exact compilation commands:

```bash
ninja -v
```

## Integration with DAWs

### Testing VST3 Plugin

The VST3 plugin is built to:

```text
build/ninja/JucePlugin_artefacts/Debug/VST3/DSP-JUCE Plugin.vst3/
```

To test in a DAW:

1. Copy the `.vst3` folder to your DAW's VST3 directory (e.g., `C:\Program Files\Common Files\VST3\`)
2. Rescan plugins in your DAW
3. Load "DSP-JUCE Plugin"

For development, use the standalone application first for faster iteration.

## Next Steps

- [Task 1.2: Implement Basic UnitTest](plugin-development-roadmap.md#task-12-implement-basic-unittest)
- [Testing with AudioPluginHost](docs/JUCE-AudioPluginHost/basics-JUCE-AudioPluginHost.md)
- [Ninja Build System Basics](docs/ninja/basics-ninja.md)

## Summary

The Ninja-based workflow provides a production-ready development experience with:

- **Speed**: 1-3 second incremental builds
- **Simplicity**: Press `Ctrl+Shift+B` to build
- **Integration**: Native VS Code task automation
- **Reliability**: Proper MSVC toolchain initialization

This is the recommended workflow for daily DSP-JUCE development.
