# Simple JUCE Project

A clean, simple JUCE development setup for Visual Studio Code that automatically downloads JUCE and doesn't
clutter your git repository.

## What This Is

- **One simple CMakeLists.txt** that handles everything
- **JUCE is fetched automatically** - never added to your git repo
- **Minimal setup** - just source files and configuration
- **Modern CMake** with FetchContent for clean dependency management

## Prerequisites

- **Visual Studio Build Tools 2022** (with C++ workload)
- **CMake 3.22+**
- **Visual Studio Code** with C++ and CMake extensions

## Quick Start

1. **Open this folder in VS Code**
2. **Press Ctrl+Shift+P** and run "CMake: Configure" (or it auto-configures)
3. **Press F7** to build
4. **Run** the built app: `build/SimpleJuceApp_artefacts/Debug/Simple JUCE App.exe`

That's it! JUCE downloads automatically on first configure.

1. **Set up JUCE framework:**

    **Windows:**

    ```batch
    setup-juce.bat
    ```

    **Linux/Mac:**

    ```bash
    chmod +x setup-juce.sh
    ./setup-juce.sh
    ```

    **Manual setup:**

    ```bash
    git clone --recurse-submodules https://github.com/juce-framework/JUCE.git
    ```

2. **Build a project:**

    ```bash
    cd MyJuceApp
    mkdir build && cd build
    cmake ..
    cmake --build . --config Debug
    ```

## Projects

### MyJuceApp

- Basic JUCE audio application
- Demonstrates GUI and audio processing
- Executable output in `build/MyJuceApp_artefacts/Debug/`

### MyJucePlugin

- Audio plugin template (VST3, AU, Standalone)
- Ready for DAW integration
- Plugin output in `build/MyJucePlugin_artefacts/`

## Development Environment

### VS Code Extensions

- C/C++ Extension Pack
- CMake Tools
- CMake Language Support

### Build System

- CMake-based build system
- Cross-platform compatibility
- Visual Studio, MinGW, or Clang compiler support

## Project Structure

```text
dsp-juce/
├── JUCE/                   # JUCE framework (auto-downloaded)
├── MyJuceApp/             # Basic audio application
│   ├── Source/
│   ├── .vscode/          # VS Code configuration
│   └── CMakeLists.txt
├── MyJucePlugin/          # Audio plugin template
│   ├── Source/
│   └── CMakeLists.txt
├── setup-juce.sh         # Linux/Mac setup script
├── setup-juce.bat        # Windows setup script
└── .gitignore            # Excludes build files and JUCE
```

## Why JUCE is Excluded from Git

- **Size**: JUCE is ~267MB with thousands of files
- **External Dependency**: Maintained separately by JUCE team
- **Version Control**: Use setup scripts for consistent versions
- **Clean Repository**: Focus on your audio code, not framework code

## Troubleshooting

### Common Issues

1. **CMake not found**: Install CMake and add to PATH
2. **Compiler not found**: Install Visual Studio Build Tools or MinGW
3. **JUCE missing**: Run the setup script first

### Getting Help

- [JUCE Documentation](https://docs.juce.com/)
- [JUCE Forum](https://forum.juce.com/)
- [JUCE GitHub](https://github.com/juce-framework/JUCE)

## License

Your audio projects are under your chosen license. JUCE has its own licensing terms.
