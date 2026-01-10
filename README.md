# JUCE Project Template

[![Open in Dev Containers](https://img.shields.io/static/v1?label=Dev%20Containers&message=Open&color=blue&logo=visualstudiocode)](https://vscode.dev/redirect?url=vscode://ms-vscode-remote.remote-containers/cloneInVolume?url=https://github.com/KristofferKarlAxelEkstrand/juce-project-template)
[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/KristofferKarlAxelEkstrand/juce-project-template)

A modern CMake-based template for building cross-platform JUCE audio plugins (VST3, AU, Standalone). Designed for
professional development with fast iteration, CI/CD integration, and deterministic builds.

## Quick Start with Dev Container (Recommended)

The fastest way to start developing is using the pre-configured dev container:

1. **Open in VS Code**: Click the "Open in Dev Containers" badge above, or:
   - Clone this repository
   - Open in VS Code
   - When prompted, click "Reopen in Container"

2. **Build** (already configured, just run):

   ```bash
   cmake --build --preset=ninja
   ```

3. **Your plugin is ready** in `build/ninja/JucePlugin_artefacts/Debug/`

The dev container includes all dependencies, Ninja build system, ccache for fast rebuilds, and VS Code extensions.

## Alternative: Local Development

If you prefer local development, see **[QUICKSTART.md](QUICKSTART.md)** for platform-specific setup.

## What This Template Provides

This template gives you a working JUCE 8.0.10 project with:

- **Multiple plugin formats** from a single codebase (VST3, AU on macOS, Standalone)
- **Modern CMake build system** with automatic JUCE dependency management
- **Cross-platform presets** for Windows (Visual Studio), macOS (Xcode), and Linux
- **Fast development workflow** using Ninja (1-3 second incremental builds)
- **GitHub Actions CI/CD** with multi-platform builds and security scanning
- **Single-source metadata** system for plugin name, version, and company info
- **Example plugin** implementing a sine-wave synthesizer with thread-safe parameters

## Who Should Use This Template

Use this template if you want:

- A professional development environment for JUCE plugins
- Version-controlled build configuration (no GUI-generated files)
- Deterministic, reproducible builds across platforms
- Integration with modern IDEs (VS Code, Visual Studio, CLion)
- CI/CD pipeline for automated testing and releases
- Fast edit-compile-test cycles during development

## Why This Template Approach

Different JUCE workflows have different trade-offs:

### Projucer (JUCE's GUI Tool)

**Strengths:**

- Visual interface for project configuration
- Built-in IDE project generation
- Easy for beginners to start quickly

**Limitations:**

- GUI-generated files difficult to version control and merge
- Limited flexibility for complex build setups
- Harder to integrate with CI/CD pipelines
- Manual project regeneration needed when switching platforms

### CMake (This Template)

**Strengths:**

- Text-based configuration works well with version control
- Powerful scripting for complex build requirements
- Excellent CI/CD and automation support
- Cross-platform builds without manual regeneration
- Better IDE integration (IntelliSense, code navigation)

**Trade-offs:**

- Steeper initial learning curve
- More manual configuration required

### Manual Makefiles

**Strengths:**

- Complete control over build process
- No external build tool dependencies

**Limitations:**

- Platform-specific (separate files for Windows, macOS, Linux)
- Difficult to maintain as projects grow
- No automatic dependency management
- Time-consuming to set up correctly

This template uses CMake because it provides the best balance of power, automation, and maintainability for professional
plugin development.

## Getting Started

### Prerequisites

Install the following tools before building:

- **CMake**: Version 3.22 or higher
- **C++ Compiler**: C++20 support (MSVC 2019+, GCC 10+, Clang 11+)
- **Git**: For cloning the repository
- **Platform Dependencies**: See [BUILD.md](BUILD.md) for OS-specific libraries

### Using This Template

1. **Use as GitHub Template** (Recommended):
   - Click "Use this template" on GitHub
   - Create your own repository
   - Clone your new repository locally

2. **Direct Clone**:

   ```bash
   git clone https://github.com/KristofferKarlAxelEkstrand/juce-project-template.git
   cd juce-project-template
   ```

### Build Your Plugin

Two simple commands build everything:

1. **Configure** (downloads JUCE automatically, takes ~90 seconds first time):

   ```bash
   cmake --preset=default
   ```

2. **Build** (compiles VST3 and standalone, takes 3-5 minutes):

   ```bash
   cmake --build --preset=default
   ```

**Output location**: `build/default/JucePlugin_artefacts/Debug/`

- `VST3/Your Plugin.vst3` - VST3 plugin (name from PLUGIN_NAME in CMakeLists.txt)
- `Standalone/Your Plugin` - Standalone application

### Customize Your Plugin

Follow the step-by-step guide in **[CUSTOMIZATION.md](CUSTOMIZATION.md)** to make this template your own.

Quick start: Edit these values in `CMakeLists.txt`:

```cmake
set(PLUGIN_NAME "Your Plugin Name")
set(PLUGIN_VERSION "1.0.0")
set(PLUGIN_COMPANY_NAME "Your Company")
```

All build outputs, metadata, and branding will update automatically.

### Next Steps

Once you have a successful build:

1. **Fast development setup**: See [DEVELOPMENT_WORKFLOW.md](DEVELOPMENT_WORKFLOW.md) for 1-3 second builds
2. **Platform-specific builds**: See [BUILD.md](BUILD.md) for Windows, macOS, and Linux details
3. **Start coding**: Modify `src/MainComponent.cpp` for audio processing, `src/PluginEditor.cpp` for GUI

## Template Features

### Build System

- **Automatic JUCE download**: CMake FetchContent downloads JUCE 8.0.10 (no manual setup)
- **Cross-platform presets**: Pre-configured for Visual Studio, Xcode, Unix Makefiles, and Ninja
- **Single-source metadata**: Edit plugin name/version once in CMakeLists.txt, updates everywhere
- **Fast incremental builds**: Ninja preset enables 1-3 second rebuild cycles
- **Multiple configurations**: Debug and Release builds with appropriate optimizations

### CI/CD Integration

- **GitHub Actions workflows**: Automated builds on Windows, macOS, and Linux
- **Security scanning**: CodeQL integration for C++ and JavaScript
- **Smart CI strategy**: Fast checks on feature branches, comprehensive validation before release
- **Automated validation**: Scripts verify build outputs and dependencies

### Developer Experience

- **VS Code integration**: Pre-configured tasks for one-keystroke builds (`Ctrl+Shift+B`)
- **Cross-platform scripts**: Build scripts work on Windows, macOS, and Linux
- **Real-time safe example**: Demonstrates thread-safe parameter handling with `std::atomic`
- **Modern C++20**: Uses lambdas, `constexpr`, structured bindings, and RAII patterns
- **Comprehensive documentation**: Guides for building, development workflow, and JUCE concepts

### Dev Container Support

- **One-click setup**: Open in VS Code with Dev Containers extension, select "Reopen in Container"
- **Pre-configured environment**: All JUCE dependencies, Ninja, ccache, clang-format included
- **Windows cross-compilation**: MinGW-w64 toolchain for building Windows VST3 from Linux
- **GitHub Codespaces compatible**: Develop in the browser with full build capabilities
- **Fast rebuilds**: ccache volume persists between container sessions

```bash
# Inside dev container:
cmake --build --preset=ninja          # Linux build (1-3 sec incremental)
cmake --preset=mingw64 && cmake --build --preset=mingw64  # Windows cross-compile
```

### Example Plugin

The template includes a working sine-wave synthesizer that demonstrates:

- Real-time audio processing with `juce::dsp::Oscillator` and `juce::dsp::Gain`
- Thread-safe GUI-to-audio parameter communication
- Plugin state persistence (save/restore parameters)
- Cross-platform GUI with frequency and gain controls

## Development Workflow

### Fast Iteration (Recommended)

For the fastest edit-build-test cycle:

1. **One-time setup**: Configure Ninja preset (see [DEVELOPMENT_WORKFLOW.md](DEVELOPMENT_WORKFLOW.md))
2. **Daily workflow**: Press `Ctrl+Shift+B` in VS Code to build (1-3 seconds)
3. **Test changes**: Run standalone application or load plugin in DAW

### Standard CMake Workflow

**Build Debug version**:

```bash
cmake --preset=default
cmake --build --preset=default
```

**Build Release version**:

```bash
cmake --preset=release
cmake --build --preset=release
```

**Platform-specific presets**:

- Windows: `--preset=vs2022`
- macOS: `--preset=xcode`
- All platforms: `--preset=ninja` (fastest)

### Code Quality

```bash
# Format source code
clang-format -i src/*.cpp src/*.h

# Lint documentation
npm test

# Validate setup
./scripts/validate-setup.sh
```

## Project Structure

```text
juce-project-template/
├── src/                     # Plugin source code
│   ├── Main.cpp             # Plugin entry point
│   ├── MainComponent.{h,cpp}# Audio processor (DSP logic)
│   └── PluginEditor.{h,cpp} # GUI editor (controls)
├── .github/
│   └── workflows/           # CI/CD automation
├── docs/                    # Learning resources
│   ├── JUCE/                # JUCE framework concepts
│   ├── cmake/               # CMake build system
│   └── C++/                 # Modern C++ patterns
├── scripts/                 # Build and validation scripts
├── CMakeLists.txt           # Build configuration (edit plugin metadata here)
├── CMakePresets.json        # Cross-platform build presets
├── BUILD.md                 # Platform-specific build instructions
└── DEVELOPMENT_WORKFLOW.md  # Fast development setup guide
```

## Documentation

This template includes comprehensive guides:

- **[docs/DEV_CONTAINER.md](docs/DEV_CONTAINER.md)**: Dev container setup and usage (recommended)
- **[BUILD.md](BUILD.md)**: Platform-specific build instructions and troubleshooting
- **[DEVELOPMENT_WORKFLOW.md](DEVELOPMENT_WORKFLOW.md)**: Fast Ninja-based workflow setup
- **[CUSTOMIZATION.md](CUSTOMIZATION.md)**: Step-by-step plugin customization guide
- **[CONTRIBUTING.md](CONTRIBUTING.md)**: Git workflow, coding standards, and PR process
- **[docs/VSCODE_INTEGRATION.md](docs/VSCODE_INTEGRATION.md)**: VS Code debugging and task usage
- **[docs/NINJA.md](docs/NINJA.md)**: Ninja build system guide
- **[docs/LOCAL_CI_TESTING.md](docs/LOCAL_CI_TESTING.md)**: Local validation before pushing
- **[docs/PLUGIN_FORMATS.md](docs/PLUGIN_FORMATS.md)**: VST3, AU, and Standalone format guide
- **[docs/COPILOT_INSTRUCTIONS.md](docs/COPILOT_INSTRUCTIONS.md)**: GitHub Copilot custom instructions setup
- **[docs/JUCE/](docs/JUCE/)**: JUCE framework concepts and real-time audio safety
- **[docs/cmake/](docs/cmake/)**: CMake build system and dependency management
- **[docs/C++/](docs/C++/)**: Modern C++20 features for audio development

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for:

- Development setup and workflow
- Coding standards and best practices
- Git branching strategy (Git Flow-inspired)
- Pull request process
- Testing requirements

## License

This project is open source. The JUCE framework is subject to its own licensing terms. See the
[JUCE website](https://juce.com/get-juce) for details.

## Related Resources

- [JUCE Framework](https://juce.com/) - Official JUCE website and documentation
- [JUCE Forum](https://forum.juce.com/) - Community support and discussions
- [JUCE GitHub](https://github.com/juce-framework/JUCE) - JUCE source code and examples
- [CMake Documentation](https://cmake.org/documentation/) - CMake reference
