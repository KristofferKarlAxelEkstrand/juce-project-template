# CMake Basics

CMake is a build system generator that helps manage the build process of software projects. It is widely used
in C++ projects to simplify the process of compiling and linking code across different platforms and environments.

## How CMake Works

1. **CMakeLists.txt**: CMake uses configuration files called `CMakeLists.txt` to define the build process.
   These files specify the source files, dependencies, and build options.
2. **Generate Build Files**: CMake generates platform-specific build files (e.g., Makefiles, Visual Studio
   project files) based on the `CMakeLists.txt` configuration.
3. **Build the Project**: The generated build files are used by the platform's native build tools (e.g., `make`,
   `msbuild`) to compile and link the code into an executable or library.

## Role of CMake in This Project

In this JUCE-based audio development project, CMake is used to:

- **Manage Dependencies**: Automatically fetch and configure the JUCE framework using CMake's `FetchContent` module.
- **Cross-Platform Builds**: Generate build files for Windows, macOS, and Linux, ensuring compatibility across platforms.
- **Plugin Formats**: Configure the project to build audio plugins in multiple formats (VST3, AU, AAX, Standalone).
- **Simplify Configuration**: Provide a unified and easy-to-maintain build configuration for the entire project.

## Key Commands

- **Configure the Project**:

    ```bash
    cmake --preset=default
    ```

    This sets up the build system based on the `CMakeLists.txt` file.

- **Build the Project**:

    ```bash
    cmake --build --preset=default
    ```

    This compiles the code and generates the final executable or plugin files.

CMake ensures that the build process is efficient, consistent, and adaptable to different development environments.
