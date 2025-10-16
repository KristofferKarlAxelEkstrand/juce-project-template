# CMake Build System

CMake generates platform-specific build files from `CMakeLists.txt`. This project uses modern CMake 3.22+ features with
JUCE integration.

## CMake's Role

**Dependency Management**:

- **FetchContent**: Downloads JUCE 8.0.10 automatically during configure
- **Zero Dependencies**: No manual JUCE installation required
- **Version Locking**: Ensures consistent JUCE version across builds

**Cross-Platform Support**:

- **Windows**: Visual Studio projects (`.sln`, `.vcxproj`)
- **macOS**: Xcode projects or Unix Makefiles
- **Linux**: Unix Makefiles or Ninja builds
- **Build Presets**: `CMakePresets.json` simplifies configuration

## Key CMake Functions Used

**Project Setup**:

```cmake
project(JuceProject VERSION 1.0.0)  # CMake project name
set(CMAKE_CXX_STANDARD 20)  # Enable C++20 features
```

**JUCE Integration**:

```cmake
# Download JUCE automatically
FetchContent_Declare(JUCE
    GIT_REPOSITORY https://github.com/juce-framework/JUCE.git
    GIT_TAG 8.0.10)

# Configure plugin formats and properties
juce_add_plugin(JucePlugin  # Plugin target name (from PLUGIN_TARGET variable)
    FORMATS VST3 AU Standalone
    PRODUCT_NAME "Your Plugin Name")
```

**Modern CMake Benefits**:

- **Target-Based**: Clear dependency relationships
- **Generator Agnostic**: Works with Visual Studio, Xcode, Makefiles, Ninja
- **Preset System**: Standardized configuration across platforms
- **IDE Integration**: Native project file generation

Build commands remain simple: `cmake --preset=default && cmake --build --preset=default`
