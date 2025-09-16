# DSP-JUCE Audio Plugin & Standalone Application

A modern, cross-platform JUCE 8.0.9 audio plugin and standalone application demonstrating professional
development practices for C++20, CMake, and real-time audio processing.

## 🎯 Project Overview

This project showcases professional JUCE development patterns:

- **Multi-Format Audio Plugin**: VST3 (all platforms), AU (macOS), Standalone application
- **Modern C++20** with smart pointers, constexpr, atomic operations, and structured bindings
- **JUCE 8.0.9** with latest framework features and DSP modules
- **Cross-platform CMake** with preset configurations for Windows, Linux, and macOS
- **Professional build system** with CI/CD, static analysis, and security scanning
- **Real-time safe architecture** separating GUI and audio processing threads

## 🚀 Quick Start

### Prerequisites

**All Platforms:**

- CMake 3.22+
- C++20 compatible compiler
- Git

**Linux (Ubuntu/Debian):**

```bash
sudo apt-get install -y libasound2-dev libx11-dev libxcomposite-dev libxcursor-dev \
                        libxinerama-dev libxrandr-dev libfreetype6-dev libfontconfig1-dev \
                        libgl1-mesa-dev libcurl4-openssl-dev libwebkit2gtk-4.1-dev pkg-config \
                        build-essential cmake
```

**macOS:**

```bash
xcode-select --install
brew install cmake
```

**Windows:**

- Visual Studio 2019+ with C++ workload
- CMake (via Visual Studio or cmake.org)

### Build Commands

**Linux & macOS:**

```bash
# Configure and build (Debug)
cmake --preset=default
cmake --build --preset=default

# Or for Release
cmake --preset=release
cmake --build --preset=release
```

**Windows:**

```batch
# Configure and build
cmake --preset=vs2022
cmake --build --preset=vs2022-debug

# Or Release
cmake --build --preset=vs2022-release
```

### Built Artifacts

After building, you'll find:

**Linux:**

- **VST3 Plugin**: `build/DSPJucePlugin_artefacts/Debug/VST3/DSP-JUCE Plugin.vst3/`
- **Standalone App**: `build/DSPJucePlugin_artefacts/Debug/Standalone/DSP-JUCE Plugin`
- **Auto-installed to**: `~/.vst3/DSP-JUCE Plugin.vst3`

**macOS:**

- **VST3 Plugin**: `build/DSPJucePlugin_artefacts/Debug/VST3/DSP-JUCE Plugin.vst3/`
- **AU Plugin**: `build/DSPJucePlugin_artefacts/Debug/AU/DSP-JUCE Plugin.component/`
- **Standalone App**: `build/DSPJucePlugin_artefacts/Debug/Standalone/DSP-JUCE Plugin.app/`

**Windows:**

- **VST3 Plugin**: `build\DSPJucePlugin_artefacts\Debug\VST3\DSP-JUCE Plugin.vst3\`
- **Standalone App**: `build\DSPJucePlugin_artefacts\Debug\Standalone\DSP-JUCE Plugin.exe`

## 📖 Documentation

- **[BUILD.md](BUILD.md)** - Comprehensive build instructions for all platforms
- **Platform-specific setup** - Dependencies, configuration, and troubleshooting
- **Plugin installation** - System-wide and user-specific installation locations
- **Development tips** - Debugging, testing, and validation

## 🏗️ Project Structure

```text
dsp-juce/
├── src/                         # Source code
│   ├── Main.cpp                # Plugin entry point
│   ├── MainComponent.h         # AudioProcessor interface  
│   ├── MainComponent.cpp       # Audio processing implementation
│   ├── PluginEditor.h         # GUI interface
│   └── PluginEditor.cpp       # GUI implementation
├── build/                      # Build output (auto-generated)
│   └── DSPJucePlugin_artefacts/
│       └── Debug/              
│           ├── VST3/           # VST3 plugin bundle
│           ├── AU/             # AU plugin bundle (macOS)
│           └── Standalone/     # Standalone application
├── .github/                    # GitHub configuration and CI/CD
├── docs/                       # Documentation
├── CMakeLists.txt             # Main CMake configuration
├── CMakePresets.json          # Cross-platform build presets
├── BUILD.md                   # Detailed build instructions
└── README.md                  # This file
```

## 🎛️ Features

### Audio Processing

- **Real-time sine wave synthesis** with configurable frequency (50Hz - 5kHz)
- **DSP processing chain** using JUCE's modern `juce::dsp` modules
- **Thread-safe parameter control** with atomic operations
- **Professional audio quality** with proper buffering and sample rate handling

### User Interface

- **Frequency control** with logarithmic scaling for musical response
- **Gain control** with linear 0.0 - 1.0 range
- **Real-time responsiveness** with immediate audio parameter updates
- **Modern visual design** with gradients and proper spacing
- **Consistent across plugin and standalone** modes

### Code Quality

- **Modern C++20 patterns** with constexpr, auto, and atomic operations
- **RAII memory management** with smart pointers and JUCE's lifecycle
- **Thread safety** using atomic variables for cross-thread communication
- **AudioProcessor architecture** supporting both plugin and standalone builds
- **Comprehensive documentation** with practical examples

## 🔧 Development

### Code Formatting

```bash
clang-format -i src/*.cpp src/*.h
```

### Documentation Linting

```bash
npm install && npm test
```

### Validation

```bash
./scripts/validate-setup.sh
```

## 🧪 Testing & Quality Assurance

### Plugin Testing

- **Load in DAW**: Reaper, Logic Pro, Pro Tools, Cubase, etc.
- **Parameter automation**: Test frequency and gain controls
- **Audio quality**: Check for dropouts, noise, and CPU usage
- **GUI responsiveness**: Verify real-time parameter updates

### Standalone Testing

```bash
# Linux/macOS
./build/DSPJucePlugin_artefacts/Debug/Standalone/DSP-JUCE\ Plugin

# Windows
build\DSPJucePlugin_artefacts\Debug\Standalone\DSP-JUCE Plugin.exe
```

### Continuous Integration

- **Multi-platform builds** (Ubuntu, Windows, macOS)
- **Multiple configurations** (Debug, Release)
- **Automated testing** with binary verification
- **Security scanning** with CodeQL
- **Dependency updates** via Dependabot

## 📚 JUCE Concepts Demonstrated

### Modern JUCE Patterns

- **AudioProcessor** for cross-format plugin/standalone compatibility
- **AudioProcessorEditor** for consistent GUI across formats
- **juce::dsp modules** for professional DSP processing
- **ProcessSpec** for configuring DSP chains
- **Atomic variables** for thread-safe parameter communication

### Audio Processing Best Practices

- **Thread separation** between GUI and audio processing
- **Proper resource management** in prepareToPlay/releaseResources
- **Real-time safe operations** avoiding allocations in audio callback
- **Parameter smoothing** through atomic variable updates
- **Cross-platform compatibility** with conditional AU support

### CMake Integration

- **FetchContent** for automatic JUCE download and integration
- **Modern target-based** CMake with proper visibility
- **Cross-platform configuration** with conditional compilation
- **Multi-format builds** (VST3, AU, Standalone) from single source
- **Automatic plugin installation** to user directories

## 🤝 Contributing

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/amazing-feature`
3. **Follow code standards**: Use `.clang-format` and add documentation
4. **Test on multiple platforms** before submitting
5. **Commit changes**: `git commit -m 'Add amazing feature'`
6. **Push to branch**: `git push origin feature/amazing-feature`
7. **Open a Pull Request**

### Development Guidelines

- **Follow modern C++20 practices** with proper RAII and const correctness
- **Add comprehensive documentation** for public APIs
- **Ensure thread safety** in audio processing code
- **Test plugin and standalone** on multiple platforms
- **Follow JUCE conventions** for naming and architecture

## 🚨 Troubleshooting

### Build Issues

See [BUILD.md](BUILD.md) for comprehensive troubleshooting including:

- Missing dependencies and compiler setup
- Platform-specific configuration issues  
- Plugin installation and DAW recognition
- Performance optimization and debugging

### Quick Fixes

```bash
# Clean rebuild
rm -rf build
cmake --preset=default
cmake --build --preset=default

# Verify setup
./scripts/validate-setup.sh

# Test documentation
npm test
```

## 📄 License

This project is open source. JUCE has its own licensing terms - see [JUCE website](https://juce.com/get-juce) for details.

## 🎓 Learning Resources

- **[JUCE Documentation](https://docs.juce.com/)** - Official JUCE framework documentation
- **[JUCE Forum](https://forum.juce.com/)** - Community support and discussions
- **[JUCE GitHub](https://github.com/juce-framework/JUCE)** - Source code and examples
- **[Modern CMake Guide](https://cliutils.gitlab.io/modern-cmake/)** - CMake best practices
- **[C++20 Features](https://en.cppreference.com/w/cpp/20)** - Modern C++ reference

---

*This project demonstrates modern JUCE development practices and serves as a foundation for professional
cross-platform audio applications and plugins.*
