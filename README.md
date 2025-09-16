# DSP-JUCE Audio Plugin

A cross-platform JUCE 8 audio plugin and standalone application demonstrating modern C++20, CMake, and real-time audio development practices.

This project serves as a template for building professional audio software. It includes a simple sine-wave synthesizer with a clean, real-time safe architecture.

## Quick Start

### Prerequisites

- **CMake**: Version 3.22+
- **C++ Compiler**: C++20 support required
- **Git**: For cloning and dependency management

See [**BUILD.md**](BUILD.md) for detailed, platform-specific dependency and build instructions.

### Build Commands

1.  **Configure the project:**
    ```bash
    # For Linux, macOS, or Windows (using VS Code with default presets)
    cmake --preset=default
    ```

2.  **Build the application:**
    ```bash
    cmake --build --preset=default
    ```

Built artifacts, including the VST3 plugin and Standalone application, will be located in the `build/DSPJucePlugin_artefacts/` directory.

## Project Structure

```
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

- **Multi-Format Audio Plugin**: Builds as VST3, AU (macOS), and a Standalone application.
- **Real-Time Audio**: A simple sine-wave synthesizer with frequency and gain controls, implemented using `juce::dsp` modules.
- **Modern C++20**: Utilizes modern C++ features for clean, efficient, and safe code.
- **CMake Build System**: A robust, cross-platform build system with `FetchContent` for automatic JUCE dependency management.
- **Thread-Safe**: Demonstrates safe communication between the GUI and real-time audio threads using `std::atomic`.

## Development

### Code Formatting

This project uses `clang-format` to maintain a consistent code style.

```bash
# Format all source files
clang-format -i src/*.cpp src/*.h
```

### Validation

A validation script is included to check for common setup issues.

```bash
./scripts/validate-setup.sh
```

## Contributing

Contributions are welcome. Please follow these steps:

1.  Fork the repository.
2.  Create a feature branch (`git checkout -b feature/my-feature`).
3.  Commit your changes (`git commit -m 'feat: Add my feature'`).
4.  Push to the branch (`git push origin feature/my-feature`).
5.  Open a Pull Request.

## License

This project is open source. The JUCE framework is subject to its own licensing terms. See the [JUCE website](https://juce.com/get-juce) for details.
