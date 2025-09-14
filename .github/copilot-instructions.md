# JUCE Audio Development Environment

**ALWAYS follow these instructions first and only use additional search or bash commands when the information provided
here is incomplete or found to be in error.**

This repository is a modern JUCE 8.0.9 audio development environment designed for creating professional audio plugins
and applications with CMake build system integration.

## Working Effectively

**Install system dependencies (Linux):**

```bash
sudo apt-get update && sudo apt-get install -y \
  libasound2-dev libjack-jackd2-dev libfreetype-dev libxinerama-dev \
  libxcursor-dev libxrandr-dev libgl1-mesa-dev libglu1-mesa-dev \
  libx11-dev libxext-dev libxft-dev libxss-dev libgtk-3-dev \
  libwebkit2gtk-4.1-dev libcurl4-openssl-dev build-essential ninja-build
```

**Install documentation dependencies:**

```bash
npm install
```

**Configure and build (first time setup):**

```bash
# NEVER CANCEL: Configuration takes ~1.5 minutes to download JUCE 8.0.9 automatically
cmake -B build -DCMAKE_BUILD_TYPE=Debug \
  -DCMAKE_C_COMPILE_OBJECT="<CMAKE_C_COMPILER> <DEFINES> <INCLUDES> <FLAGS> -o <OBJECT> -c <SOURCE>"

# NEVER CANCEL: Full build takes ~4 minutes. Set timeout to 10+ minutes minimum.
cmake --build build --config Debug
```

**Build for release:**

```bash
# NEVER CANCEL: Release build takes ~5.5 minutes total. Set timeout to 10+ minutes minimum.
cmake -B build-release -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_C_COMPILE_OBJECT="<CMAKE_C_COMPILER> <DEFINES> <INCLUDES> <FLAGS> -o <OBJECT> -c <SOURCE>"
cmake --build build-release --config Release
```

**Incremental builds (after changes):**

```bash
cmake --build build --config Debug
# Takes <1 second for small changes
```

**Run the built application:**

```bash
"./build/SimpleJuceApp_artefacts/Debug/Simple JUCE App"
```

Note: Application requires X11 display. In headless environments, it will fail with X11/ALSA errors - this is expected.

## Validation

**Always run linting before committing:**

```bash
npm test                 # Validates markdown - takes <5 seconds
npm run lint:md:fix      # Fixes markdown issues automatically - takes <5 seconds
```

**Build validation workflow:**

1. Clean build: `rm -rf build build-release`
2. Configure: `cmake -B build -DCMAKE_BUILD_TYPE=Debug -DCMAKE_C_COMPILE_OBJECT="<CMAKE_C_COMPILER> <DEFINES> <INCLUDES>
<FLAGS> -o <OBJECT> -c <SOURCE>"`
3. Build: `cmake --build build --config Debug`
4. Test application startup (will fail without display but validates binary)

**ALWAYS test the complete build cycle after making changes to CMakeLists.txt or source files.**

## Platform Differences

**Windows:** Use CMake presets are configured for Visual Studio 17 2022. Run:

-   `cmake --preset=default`
-   `cmake --build --preset=default`
-   Run: `build\SimpleJuceApp_artefacts\Debug\Simple JUCE App.exe`

**Linux:** Manual CMake configuration required (presets don't work):

-   Use the commands shown in "Working Effectively" section above
-   Install system dependencies first

**macOS:** Similar to Linux but with different system dependencies (use Homebrew)

## Project Structure

```text
dsp-juce/
├── src/                          # Source code
│   ├── Main.cpp                  # Application entry point and main window
│   ├── MainComponent.h           # Audio component header with oscillator/sliders
│   └── MainComponent.cpp         # Audio processing implementation
├── CMakeLists.txt                # Build configuration using JUCE FetchContent
├── CMakePresets.json             # VS Code/Windows build presets
├── package.json                  # NPM tooling for documentation
├── .github/                      # Repository configuration
│   ├── copilot-instructions.md   # This file
│   ├── instructions/             # File-specific coding guidelines
│   └── prompts/                  # Development prompt templates
├── build/                        # Debug build output (auto-generated)
├── build-release/                # Release build output (auto-generated)
└── node_modules/                 # NPM dependencies (auto-generated)
```

## Key Technologies

-   **JUCE Framework 8.0.9**: Automatically downloaded via CMake FetchContent
-   **CMake 3.22+**: Modern build system with cross-platform support
-   **C++17**: Modern C++ standard required
-   **NPM tooling**: Markdown linting and documentation validation
-   **VS Code integration**: CMake Tools extension support

## Build System Details

**Never manually clone JUCE** - the project uses CMake FetchContent to automatically download JUCE 8.0.9. The CMakeLists.txt
handles:

-   JUCE framework acquisition and setup
-   Audio module linking (juce_audio_utils, juce_dsp, juce_gui_basics, etc.)
-   Cross-platform build configuration
-   Proper compile definitions and flags

**CRITICAL:** The CMake workaround setting CMAKE_C_COMPILE_OBJECT is required due to a CMake internal variable issue.
Without this, configuration will fail with "CMake Error: Error required internal CMake variable not set".

## Audio Development Focus

This is a **real-time audio application** that demonstrates:

-   **AudioAppComponent**: Proper JUCE audio component inheritance
-   **DSP Processing**: Oscillator and gain processing using juce_dsp
-   **GUI Integration**: Sliders for frequency and gain control
-   **Thread Safety**: Proper separation of audio and GUI threads
-   **Real-time Constraints**: No allocations in audio callbacks

**When modifying audio code:**

-   Test with different buffer sizes and sample rates
-   Verify no dropouts or glitches occur
-   Ensure parameter changes are smooth (no clicks/pops)
-   Validate real-time safety (no blocking operations in processBlock)

## Common Build Issues

**"Visual Studio 17 2022 generator not found"**: Use manual CMake commands instead of presets on Linux/Mac

**"X11/Xlib.h: No such file or directory"**: Install Linux development dependencies as shown above

**"CMAKE_C_COMPILE_OBJECT not set"**: Use the CMake workaround command provided above

**Segmentation fault when running app**: Expected in headless environments - application needs display

## Timing Expectations

Based on validation with JUCE 8.0.9 download and compilation:

-   **Initial CMake configure**: 1.5 minutes (downloads ~267MB JUCE framework)
-   **Full Debug build**: 4 minutes total (configure + compile)
-   **Full Release build**: 5.5 minutes total (configure + compile)
-   **Incremental builds**: <1 second
-   **NPM install**: 10 seconds
-   **Markdown linting**: <5 seconds

**NEVER CANCEL builds or long-running commands.** Always set timeouts of 10+ minutes minimum for full builds.

## Audio Development Standards

**Real-Time Safety Rules:**

-   No dynamic allocation in processBlock() or getNextAudioBlock()
-   No file I/O, network operations, or blocking calls in audio threads
-   Use atomic operations for parameter access from GUI thread
-   Implement proper prepareToPlay() and releaseResources() lifecycle

**JUCE Best Practices:**

-   Follow JUCE naming conventions (camelCase for methods, PascalCase for classes)
-   Use JUCE's AudioBuffer and AudioBlock for processing
-   Implement proper Component paint() and resized() methods
-   Use JUCE's parameter automation system for plugin development

**Code Quality Requirements:**

-   Modern C++17 features and RAII patterns
-   Proper const-correctness and immutable data where possible
-   Use JUCE's reference counting and smart pointers
-   Cross-platform compatible code (Windows, macOS, Linux)
