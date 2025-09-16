# CMake in this Project

CMake is a cross-platform tool that manages the build process. It uses a file named `CMakeLists.txt` to generate native build files (like Visual Studio projects or Makefiles) for your specific platform.

## Role of CMake

In this project, CMake is responsible for:

- **Configuring the Build**: It defines the source files, compiler settings, and project options.
- **Managing Dependencies**: It automatically downloads and links the JUCE framework using the `FetchContent` module. This means you don't need to manually install JUCE.
- **Cross-Platform Compatibility**: It ensures the project can be built on Windows, macOS, and Linux from the same source code.
- **Defining Build Presets**: The `CMakePresets.json` file contains pre-configured settings for different build types (e.g., `Debug`, `Release`), simplifying the build process.

## Key Concepts Used

- **`project(...)`**: Defines the project name and version.
- **`FetchContent`**: Manages external dependencies like JUCE, making the project self-contained.
- **`juce_add_plugin(...)`**: A JUCE-provided function that configures the build for various plugin formats (VST3, AU) and the standalone application.
- **`target_sources(...)`**: Specifies the source files (`.cpp`, `.h`) for the project.
- **`target_link_libraries(...)`**: Links the necessary JUCE modules to the project.

By using CMake, this project provides a consistent and reliable build experience across different development environments. For detailed build steps, see [**BUILD.md**](../../BUILD.md).