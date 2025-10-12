# Development Workflow

Fast iterative development with Ninja and VS Code.

## Quick Start

Edit-build-test cycle in VS Code:

1. Edit source files in `src/`
2. Press `Ctrl+Shift+B` to build (1-3 seconds)
3. Run task "Run Standalone" to test (`Ctrl+Shift+P` → Tasks: Run Task → Run Standalone)

## VS Code Tasks

Five tasks in `.vscode/tasks.json`:

### 1. Build Standalone (Ninja Debug)

Default build task. Press `Ctrl+Shift+B`.

Runs: `./scripts/build-ninja.bat` (Windows) or `./scripts/build-ninja.sh` (macOS/Linux)

Output: `build/ninja/JucePlugin_artefacts/Debug/Standalone/Your Plugin[.exe|.app]`

### 2. Run Standalone

Build and launch the Debug standalone application.

Access: `Ctrl+Shift+P` → Tasks: Run Task → Run Standalone

Depends on: Build Standalone task (runs automatically first)

### 3. Build Standalone (Ninja Release)

Build Release configuration with optimizations.

Access: `Ctrl+Shift+P` → Tasks: Run Task → Build Standalone (Ninja Release)

Output: `build/ninja/JucePlugin_artefacts/Release/Standalone/Your Plugin[.exe|.app]`

### 4. Run Standalone (Release)

Build and launch the Release standalone application.

Access: `Ctrl+Shift+P` → Tasks: Run Task → Run Standalone (Release)

Depends on: Build Standalone (Ninja Release) task

### 5. Configure Ninja

Reconfigure CMake. Run when:

- Changing `CMakeLists.txt`
- Adding/removing source files
- Changing build options

Access: `Ctrl+Shift+P` → Tasks: Run Task → Configure Ninja

See [docs/VSCODE_INTEGRATION.md](docs/VSCODE_INTEGRATION.md) for debugging setup and more VS Code features.

## Build Scripts

Cross-platform scripts for Ninja builds.

### Windows

Scripts initialize Visual Studio environment automatically:

```cmd
scripts\\configure-ninja.bat  # Configure
scripts\\build-ninja.bat      # Build
```

The scripts automatically detect your installed version of Visual Studio 2022 (Community,
Professional, or Enterprise), set up the required build environment by running `vcvarsall.bat x64`,
and then proceed with the build process.

### macOS/Linux

Shell scripts use system tools:

```bash
./scripts/configure-ninja.sh  # Configure
./scripts/build-ninja.sh      # Build
```

Requires:

- CMake 3.22+
- Ninja (install via `brew install ninja` or `apt-get install ninja-build`)
- Clang or GCC with C++20

## Common Tasks

### Edit-Build-Test Cycle

```bash
# 1. Edit MainComponent.cpp, PluginEditor.cpp, etc.
# 2. Press Ctrl+Shift+B
# 3. Run "Run Standalone" task
# Total time: 1-3 seconds for small changes
```

### Add New Files

```bash
# 1. Create files in src/
# 2. Add to target_sources() in CMakeLists.txt
# 3. Run "Configure Ninja" task
# 4. Press Ctrl+Shift+B
```

### Change Plugin Metadata

Edit `CMakeLists.txt`:

```cmake
set(PLUGIN_NAME "My Plugin")
set(PLUGIN_VERSION "1.0.0")
```

Then:

```bash
# 1. Run "Configure Ninja" task
# 2. Press Ctrl+Shift+B
```

### Build Release Version

From command line:

```bash
./scripts/build-ninja.bat --config Release  # Windows
./scripts/build-ninja.sh --config Release   # macOS/Linux
```

Or from VS Code:
- `Ctrl+Shift+P` → Tasks: Run Task → Build Standalone (Ninja Release)

Output: `build/ninja/JucePlugin_artefacts/Release/`

## Build Configurations

### Debug (Default)

- Optimizations: Disabled
- Debug symbols: Full
- Binary size: Large (~12MB)
- Build speed: Fast
- Use for: Daily development

### Release

- Optimizations: Maximum
- Debug symbols: Minimal
- Binary size: Smaller (~8MB)
- Build speed: Slower
- Use for: Performance testing, distribution

## Validation Scripts

### validate-builds.sh

Check build artefacts exist:

```bash
./scripts/validate-builds.sh Debug
./scripts/validate-builds.sh Release
```

Verifies:

- VST3 plugin
- Standalone application
- Shared code library

### validate-setup.sh

Check development environment:

```bash
./scripts/validate-setup.sh
```

Verifies:

- CMake version
- Compiler availability
- Git configuration
- JUCE dependencies (Linux)

## Plugin Metadata Flow

Plugin metadata is centralized in `CMakeLists.txt`:

```cmake
set(PLUGIN_NAME "Your Plugin Name")
set(PLUGIN_TARGET "JucePlugin")
set(PLUGIN_VERSION "1.0.0")
```

Metadata propagates to:

- JUCE plugin macros (`JucePlugin_Name`, `JucePlugin_VersionString`)
- Build artefact paths (`build/.../JucePlugin_artefacts/`)
- Generated metadata file (`build/*/plugin_metadata.sh`)
- CI/CD workflows
- DAW plugin info

See [docs/VERSION_MANAGEMENT.md](docs/VERSION_MANAGEMENT.md) for version workflow.

## Troubleshooting

### Build Fails

Ensure latest changes:

```bash
git pull
./scripts/configure-ninja.sh  # or .bat on Windows
./scripts/build-ninja.sh
```

### Tasks Not Found in VS Code

Check `.vscode/tasks.json` exists. Reopen VS Code if recently added.

### Ninja Not Found (Windows)

Ninja is included with Visual Studio 2022. Verify:

```cmd
where ninja
# Should show: C:\Program Files\Microsoft Visual Studio\2022\...\ninja.exe
```

### Ninja Not Found (macOS/Linux)

Install Ninja:

```bash
brew install ninja           # macOS
sudo apt-get install ninja-build  # Linux
```

### Slow Incremental Builds

Ninja should rebuild in 1-3 seconds for small changes. If slow:

- Check if editing headers included by many files
- Consider splitting large source files
- Use `ninja -v` to see what is rebuilding

## Testing Plugins in DAW

### VST3 Plugin

Built to: `build/ninja/JucePlugin_artefacts/Debug/VST3/Your Plugin.vst3/`

To test in a DAW:

1. Copy the `.vst3` folder to system VST3 directory:
   - Windows: `C:\Program Files\Common Files\VST3\`
   - macOS: `/Library/Audio/Plug-Ins/VST3/`
   - Linux: `~/.vst3/`
2. Rescan plugins in DAW
3. Load plugin

For development, use standalone application for faster iteration.

## See Also

- [BUILD.md](BUILD.md) - Initial build setup
- [docs/VSCODE_INTEGRATION.md](docs/VSCODE_INTEGRATION.md) - VS Code debugging and tasks
- [docs/NINJA.md](docs/NINJA.md) - Ninja build system guide
- [docs/LOCAL_CI_TESTING.md](docs/LOCAL_CI_TESTING.md) - Local CI validation
- [docs/VERSION_MANAGEMENT.md](docs/VERSION_MANAGEMENT.md) - Version and release workflow
- [docs/CI.md](docs/CI.md) - CI/CD overview
- [docs/CROSS_PLATFORM_BUILDS.md](docs/CROSS_PLATFORM_BUILDS.md) - Platform-specific details
