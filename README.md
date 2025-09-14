# Modern JUCE Audio Development Project

A modern, well-documented JUCE 8.0.9 audio application demonstrating best practices for C++20, CMake, and real-time
audio processing.

## 🎯 Project Overview

This project showcases professional JUCE development patterns:

- **Modern C++20** with smart pointers, constexpr, and structured bindings
- **JUCE 8.0.9** with latest framework features and DSP modules
- **Cross-platform CMake** with preset configurations for all platforms
- **Professional build system** with CI/CD, static analysis, and security scanning
- **Clean architecture** separating GUI and audio processing threads

## 🚀 Quick Start

### Prerequisites

- **CMake 3.22+**
- **C++20 compatible compiler** (GCC 10+, Clang 10+, MSVC 2019+)
- **Platform-specific dependencies**:

**Linux:**

```bash
sudo apt-get install libasound2-dev libx11-dev libxcomposite-dev libxcursor-dev \
                     libxinerama-dev libxrandr-dev libfreetype6-dev libfontconfig1-dev
```

**macOS:**

```bash
# Xcode command line tools required
xcode-select --install
```

**Windows:**

- Visual Studio 2019+ with C++ workload
- Or Visual Studio Build Tools 2019+

### Building

1. **Clone and configure:**

   ```bash
   git clone <repository-url>
   cd dsp-juce
   cmake --preset=default
   ```

2. **Build:**

   ```bash
   cmake --build --preset=default
   ```

3. **Run:**
   - **Linux/macOS:** `./build/SimpleJuceApp_artefacts/Debug/SimpleJuceApp`
   - **Windows:** `build\SimpleJuceApp_artefacts\Debug\SimpleJuceApp.exe`

### Alternative Build Methods

**Platform-specific presets:**

```bash
# Linux/macOS Release build
cmake --preset=release
cmake --build --preset=release

# Windows Visual Studio
cmake --preset=vs2022
cmake --build --preset=vs2022-release

# Ninja build (if available)
cmake --preset=ninja
cmake --build --preset=ninja
```

## 🏗️ Project Structure

```text
dsp-juce/
├── src/                     # Source code
│   ├── Main.cpp            # Application entry and window management
│   ├── MainComponent.h     # Audio component interface
│   └── MainComponent.cpp   # Audio processing implementation
├── .github/                # GitHub configuration
│   ├── workflows/          # CI/CD pipelines
│   ├── dependabot.yml     # Automated dependency updates
│   └── instructions/       # Development guidelines
├── docs/                   # Documentation
├── build/                  # Build output (auto-generated)
├── CMakeLists.txt         # Main CMake configuration
├── CMakePresets.json      # Cross-platform build presets
├── .clang-format          # Code formatting rules
└── README.md              # This file
```

## 🎛️ Features

### Audio Processing

- **Real-time sine wave synthesis** with configurable frequency
- **DSP processing chain** using JUCE's modern `juce::dsp` modules
- **Thread-safe parameter control** between GUI and audio threads
- **Professional audio quality** with proper buffering and sample rate handling

### User Interface

- **Frequency control:** 50Hz - 5kHz with logarithmic scaling
- **Gain control:** 0.0 - 1.0 linear gain
- **Real-time responsiveness** with immediate audio parameter updates
- **Modern visual design** with gradients and proper spacing

### Code Quality

- **Modern C++20 patterns** with constexpr, auto, and structured bindings
- **RAII memory management** with smart pointers and JUCE's lifecycle
- **Thread safety** using JUCE's message manager for parameter updates
- **Comprehensive documentation** with Doxygen-style comments

## 🔧 Development

### Code Formatting

```bash
# Format all source files
clang-format -i src/*.cpp src/*.h
```

### Documentation Linting

```bash
# Install dependencies
npm install

# Run markdown linting
npm test

# Fix formatting issues
npm run lint:md:fix
```

### Static Analysis

The project includes CodeQL security scanning and will run automatically on push/PR.

## 🧪 Testing & Quality Assurance

### Continuous Integration

- **Multi-platform builds** (Ubuntu, Windows, macOS)
- **Multiple configurations** (Debug, Release)
- **Automated testing** with binary verification
- **Security scanning** with CodeQL
- **Dependency updates** via Dependabot

### Local Testing

```bash
# Verify build works
cmake --preset=default
cmake --build --preset=default

# Test documentation
npm test
```

## 📚 JUCE Concepts Demonstrated

### Modern JUCE Patterns

- **AudioAppComponent** for simple audio applications
- **juce::dsp modules** for professional DSP processing
- **ProcessSpec** for configuring DSP chains
- **JUCE_DECLARE_NON_COPYABLE_WITH_LEAK_DETECTOR** for memory safety

### Audio Processing Best Practices

- **Thread separation** between GUI and audio processing
- **Proper resource management** in prepareToPlay/releaseResources
- **Real-time safe operations** avoiding allocations in audio callback
- **Parameter smoothing** for click-free audio changes

### CMake Integration

- **FetchContent** for automatic JUCE download
- **Modern target-based** CMake with proper visibility
- **Cross-platform configuration** with conditional compilation
- **Professional build settings** with warnings and optimizations

## 🤝 Contributing

1. **Fork the repository**
2. **Create a feature branch:** `git checkout -b feature/amazing-feature`
3. **Follow code standards:** Use `.clang-format` and add documentation
4. **Write tests** if adding new functionality
5. **Commit changes:** `git commit -m 'Add amazing feature'`
6. **Push to branch:** `git push origin feature/amazing-feature`
7. **Open a Pull Request**

### Development Guidelines

- **Follow modern C++20 practices**
- **Add comprehensive documentation** for public APIs
- **Ensure thread safety** in audio processing code
- **Test on multiple platforms** before submitting
- **Follow JUCE conventions** for naming and architecture

## 📄 License

This project is open source. JUCE has its own licensing terms - see [JUCE website](https://juce.com/get-juce) for details.

## 🎓 Learning Resources

- [JUCE Documentation](https://docs.juce.com/)
- [JUCE Forum](https://forum.juce.com/)
- [JUCE GitHub](https://github.com/juce-framework/JUCE)
- [Modern CMake Guide](https://cliutils.gitlab.io/modern-cmake/)
- [C++20 Features](https://en.cppreference.com/w/cpp/20)

## 🚨 Troubleshooting

### Build Issues

**CMake not found:**

```bash
# Ubuntu/Debian
sudo apt-get install cmake

# macOS
brew install cmake

# Windows: Download from cmake.org
```

**Compiler not found:**

```bash
# Ubuntu/Debian
sudo apt-get install build-essential

# Windows: Install Visual Studio or Build Tools
```

**JUCE dependencies missing (Linux):**

```bash
sudo apt-get install libasound2-dev libx11-dev libxcomposite-dev \
                     libxcursor-dev libxinerama-dev libxrandr-dev \
                     libfreetype6-dev libfontconfig1-dev
```

### Runtime Issues

**No audio output:**

- Check system audio settings
- Verify audio device permissions
- Try different sample rates/buffer sizes

**Application crashes:**

- Check console output for JUCE assertions
- Verify all dependencies are installed
- Try Debug build for better error information

### Getting Help

1. **Check the troubleshooting section above**
2. **Search existing issues** in the repository
3. **Ask on JUCE Forum** for JUCE-specific questions
4. **Create an issue** with detailed error information

---

*This project demonstrates modern JUCE development practices and serves as a foundation for professional audio applications.*
