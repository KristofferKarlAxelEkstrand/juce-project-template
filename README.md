# DSP-JUCE Audio Plugin

A cross-platform JUCE 8.0.10 audio plugin demonstrating modern C++20, CMake,
and real-time audio development practices.

This project serves as a production-ready template for professional audio software.
It implements a sine-wave synthesizer with frequency and gain controls, showcasing
thread-safe parameter handling and real-time audio processing.

## Quick Start

### Prerequisites

- **CMake**: Version 3.22 or higher
- **C++ Compiler**: C++20 support (MSVC 2019+, GCC 10+, Clang 11+)
- **Platform Dependencies**: Audio and GUI libraries (see [BUILD.md](BUILD.md))

### Build in 2 Steps

1. **Configure**: Downloads JUCE 8.0.10 and generates build files

   ```bash
   cmake --preset=default
   ```

2. **Build**: Compiles VST3 plugin and standalone application

   ```bash
   cmake --build --preset=default
   ```

**Built Artefacts**: `build/JucePlugin_artefacts/Debug/`

- `VST3/DSP-JUCE Plugin.vst3` - VST3 plugin
- `Standalone/DSP-JUCE Plugin` - Standalone application

## Project Structure

```text
dsp-juce/
├── src/                  # Source code
│   ├── Main.cpp          # Plugin entry point
│   ├── MainComponent.h   # AudioProcessor interface
│   ├── MainComponent.cpp # Audio processing logic
│   ├── PluginEditor.h    # GUI interface
│   └── PluginEditor.cpp  # GUI implementation
├── .github/              # CI/CD and project configuration
├── docs/                 # Extended documentation
├── CMakeLists.txt        # Main CMake configuration
├── CMakePresets.json     # Cross-platform build presets
└── BUILD.md              # Detailed build instructions
```

## Features

- **Cross-Platform Plugin**: VST3, AU (macOS), and standalone application from single codebase
- **Real-Time Audio Processing**: Sine-wave synthesizer using `juce::dsp::Oscillator`
  and `juce::dsp::Gain`
- **Thread-Safe Architecture**: `std::atomic` parameters prevent audio dropouts
  during GUI interaction
- **Modern C++20**: Leverages lambdas, `constexpr`, structured bindings, and RAII patterns
- **Zero-Dependency Build**: CMake `FetchContent` automatically downloads JUCE 8.0.10
- **Professional Template**: Production-ready structure for commercial audio software

## Development

### Development Workflow

**Code Quality**:

```bash
# Format source code
clang-format -i src/*.cpp src/*.h

# Validate setup and dependencies
./scripts/validate-setup.sh

# Test documentation
npm test
```

**Release Builds**:

```bash
cmake --preset=release
cmake --build --preset=release
```

## Learning Resources

- **[docs/JUCE/](docs/JUCE/)**: JUCE framework concepts and real-time safety
- **[docs/cmake/](docs/cmake/)**: CMake build system and dependency management  
- **[docs/C++/](docs/C++/)**: Modern C++20 features used in audio development
- **[BUILD.md](BUILD.md)**: Platform-specific build instructions and troubleshooting

## Contributing

1. Fork the repository
2. Create feature branch: `git checkout -b feature/your-feature`
3. Follow coding standards: Run `clang-format` and `npm test`
4. Commit changes: `git commit -m 'feat: Add your feature'`
5. Submit pull request

## License

This project is open source. The JUCE framework is subject to its own licensing terms.
See the [JUCE website](https://juce.com/get-juce) for details.
