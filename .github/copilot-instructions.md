# DSP-JUCE Development Environment

**ALWAYS follow these instructions first and fallback to search or bash commands only when you
encounter unexpected information that does not match the info here.**

This repository is a modern JUCE 8.0.9 audio development environment for creating professional
audio applications with CMake build system integration.

## Working Effectively

### Bootstrap and Build Process

**CRITICAL TIMING NOTE:** Build processes take significant time. **NEVER CANCEL** any build commands.

1. **Install Linux Dependencies (Ubuntu/Debian only):**

    ```bash
    sudo apt-get update
    sudo apt-get install -y libasound2-dev libx11-dev libxcomposite-dev libxcursor-dev \
                            libxinerama-dev libxrandr-dev libfreetype6-dev libfontconfig1-dev \
                            libgl1-mesa-dev libcurl4-openssl-dev libwebkit2gtk-4.1-dev pkg-config \
                            build-essential
    ```

2. **Install NPM Dependencies:**

    ```bash
    npm install
    ```

    - Takes ~10 seconds
    - Required for documentation linting only

3. **Configure Build:**

    ```bash
    cmake --preset=default
    ```

    - **NEVER CANCEL:** Takes 90+ seconds to complete. Set timeout to 180+ seconds.
    - Downloads JUCE 8.0.9 automatically via FetchContent
    - Generates working build files successfully

4. **Build Application:**

    ```bash
    cmake --build --preset=default
    ```

    - **NEVER CANCEL:** Takes 2m45s to complete. Set timeout to 300+ seconds.
    - **BUILD SUCCESS:** Creates both VST3 plugin and standalone application
    - **Auto-installs:** VST3 plugin to ~/.vst3/ directory

### Current Build Status

#### Build Works Successfully on All Platforms

- **Linux:** Builds completely successfully, creates VST3 plugin and standalone application
- **Windows:** Builds successfully when using Visual Studio generator (`--preset=vs2022`)
- **macOS:** Builds successfully with both VST3 and AU plugin formats

The build system is fully functional across all supported platforms.

### Validation and Testing

After building, you can test the applications:

1. **Validate Dependencies:**

    ```bash
    ./scripts/validate-setup.sh
    ```

    - Checks all required tools and dependencies
    - Runs in ~30 seconds

2. **Test Documentation:**

    ```bash
    npm test
    ```

    - Runs markdown linting
    - Takes <1 second
    - Always run before committing changes

3. **Code Formatting:**

    ```bash
    clang-format -i src/*.cpp src/*.h
    ```

4. **Test Standalone Application:**

    ```bash
    # Will start but fail in headless environment (expected)
    ./build/DSPJucePlugin_artefacts/Debug/Standalone/DSP-JUCE\ Plugin
    ```

## Project Structure

```text
dsp-juce/
├── src/                     # JUCE application source code
│   ├── Main.cpp            # Plugin entry point for both standalone and plugin formats
│   ├── MainComponent.h     # AudioProcessor interface for audio processing
│   ├── MainComponent.cpp   # Real-time audio processing with DSP
│   ├── PluginEditor.h      # AudioProcessorEditor interface for GUI
│   └── PluginEditor.cpp    # GUI implementation with parameter controls
├── .github/                # GitHub configuration and instructions
├── CMakeLists.txt          # Modern CMake with JUCE 8.0.9 FetchContent
├── CMakePresets.json       # Cross-platform build presets
├── package.json           # NPM tooling for documentation linting
├── scripts/               # Setup validation scripts
└── build/                 # Auto-generated build directory (ignored by git)
    └── DSPJucePlugin_artefacts/Debug/
        ├── VST3/           # VST3 plugin bundle
        ├── Standalone/     # Standalone application
        └── libDSP-JUCE Plugin_SharedCode.a  # Shared library
```

## Key Technologies

- **JUCE 8.0.9:** Modern audio framework with real-time DSP capabilities
- **CMake 3.22+:** Cross-platform build system with FetchContent for dependencies
- **C++20:** Modern language features with RAII and smart pointers
- **Real-time Audio:** Thread-safe audio processing with proper buffer management

## Development Workflow

### Before Making Changes

1. **Always validate current state:**

    ```bash
    ./scripts/validate-setup.sh
    npm test
    ```

2. **Understand build capabilities:**
    - The project builds successfully and creates working executables
    - Both VST3 plugin and standalone application are built
    - Focus on testing changes through complete build and run cycles

### Making Changes

1. **Follow JUCE patterns** in MainComponent.h/cpp and PluginEditor.h/cpp:

    - Real-time safe audio processing in `getNextAudioBlock()`
    - Thread-safe parameter handling between GUI and audio threads
    - Proper resource management in `prepareToPlay()` and `releaseResources()`

2. **Always format code:**

    ```bash
    clang-format -i src/*.cpp src/*.h
    ```

3. **Validate changes compile and build:**

    ```bash
    cmake --preset=default          # 90+ seconds, NEVER CANCEL
    cmake --build --preset=default  # 2m45s, NEVER CANCEL, builds successfully
    ```

4. **Test your changes:**

    ```bash
    # Test standalone (will fail in headless environment but validates binary)
    ./build/DSPJucePlugin_artefacts/Debug/Standalone/DSP-JUCE\ Plugin
    
    # Check VST3 plugin was built
    ls -la ~/.vst3/DSP-JUCE\ Plugin.vst3/
    ```

### Release Builds

For optimized release builds:

```bash
cmake --preset=release
cmake --build --preset=release  # Takes ~4m30s, NEVER CANCEL, set timeout to 600+ seconds
```

### Code Quality Standards

- **Real-Time Safety:** No dynamic memory allocation in audio callbacks
- **Thread Safety:** Use atomic operations for parameter access between threads
- **Modern C++20:** Use auto, constexpr, smart pointers, structured bindings
- **JUCE Conventions:** Follow camelCase for methods, PascalCase for classes
- **Documentation:** Add Doxygen-style comments for public APIs

## Common Tasks and Outputs

### Repository Root Contents

```text
ls -la /home/runner/work/dsp-juce/dsp-juce
total 152
drwxr-xr-x 9 runner runner  4096 Sep 16 18:05 .
drwxr-xr-x 3 runner runner  4096 Sep 16 18:04 ..
-rw-rw-r-- 1 runner runner  5082 Sep 16 18:05 .clang-format
drwxrwxr-x 7 runner runner  4096 Sep 16 18:06 .git
drwxrwxr-x 6 runner runner  4096 Sep 16 18:05 .github
-rw-rw-r-- 1 runner runner   902 Sep 16 18:05 .gitignore
drwxrwxr-x 2 runner runner  4096 Sep 16 18:05 .husky
-rw-rw-r-- 1 runner runner   239 Sep 16 18:05 .markdownlint-cli2.jsonc
-rw-rw-r-- 1 runner runner   201 Sep 16 18:05 .prettierignore.example
-rw-rw-r-- 1 runner runner   247 Sep 16 18:05 .prettierrc.example
drwxrwxr-x 2 runner runner  4096 Sep 16 18:05 .vscode
-rw-rw-r-- 1 runner runner 12173 Sep 16 18:05 BUILD.md
-rw-rw-r-- 1 runner runner  3893 Sep 16 18:05 CMakeLists.txt
-rw-rw-r-- 1 runner runner  2340 Sep 16 18:05 CMakePresets.json
-rw-rw-r-- 1 runner runner  9018 Sep 16 18:05 README.md
drwxrwxr-x 5 runner runner  4096 Sep 16 18:05 docs
-rw-rw-r-- 1 runner runner 55064 Sep 16 18:05 package-lock.json
-rw-rw-r-- 1 runner runner   524 Sep 16 18:05 package.json
drwxrwxr-x 2 runner runner  4096 Sep 16 18:05 scripts
drwxrwxr-x 2 runner runner  4096 Sep 16 18:05 src
```

### Source Code Structure

```text
ls -la src/
total 36
drwxrwxr-x 2 runner runner 4096 Sep 16 18:05 .
drwxrwxr-x 9 runner runner 4096 Sep 16 18:05 ..
-rw-rw-r-- 1 runner runner  301 Sep 16 18:05 Main.cpp
-rw-rw-r-- 1 runner runner 4254 Sep 16 18:05 MainComponent.cpp
-rw-rw-r-- 1 runner runner 1675 Sep 16 18:05 MainComponent.h
-rw-rw-r-- 1 runner runner 3905 Sep 16 18:05 PluginEditor.cpp
-rw-rw-r-- 1 runner runner 1562 Sep 16 18:05 PluginEditor.h
```

### Build Process Output (Expected)

- **CMake Configuration:** 87 seconds, downloads JUCE and generates build files
- **Debug Build:** 2m45s, compiles all JUCE modules and creates executables
- **Release Build:** 4m30s, optimized build with smaller binaries
- **Clean Rebuild:** Full cycle ~4m10s total time

### Built Artifacts Location

```text
build/DSPJucePlugin_artefacts/Debug/
├── VST3/
│   └── DSP-JUCE Plugin.vst3/           # VST3 plugin bundle
├── Standalone/
│   └── DSP-JUCE Plugin                 # Standalone executable
└── libDSP-JUCE Plugin_SharedCode.a     # Static library (~197MB)
```

### NPM Commands Output

```bash
npm test
> dsp-juce-docs@1.0.0 test
> npm run lint:md

> dsp-juce-docs@1.0.0 lint:md
> markdownlint-cli2 "**/*.md" "#node_modules" "#build"

markdownlint-cli2 v0.18.1 (markdownlint v0.38.0)
Summary: 0 error(s)
```

## Manual Validation Scenarios

### Complete User Workflow Testing

After making changes, always test through these scenarios:

1. **Build Validation:**

   ```bash
   # Clean rebuild cycle
   rm -rf build
   cmake --preset=default    # Should complete in ~90s
   cmake --build --preset=default  # Should complete in ~2m45s
   ```

2. **Artifact Verification:**

   ```bash
   # Check all expected files exist
   file "build/DSPJucePlugin_artefacts/Debug/Standalone/DSP-JUCE Plugin"
   ls -la ~/.vst3/DSP-JUCE\ Plugin.vst3/
   ```

3. **Application Startup Test:**

   ```bash
   # Should start and show JUCE version (fails in headless environment)
   timeout 3s ./build/DSPJucePlugin_artefacts/Debug/Standalone/DSP-JUCE\ Plugin
   ```

4. **Plugin Format Validation:**

   ```bash
   # VST3 plugin should be properly structured
   ls -la build/DSPJucePlugin_artefacts/Debug/VST3/DSP-JUCE\ Plugin.vst3/Contents/x86_64-linux/
   ```

## Troubleshooting

### Missing Dependencies (Linux)

Install all packages as shown in bootstrap section:

```bash
sudo apt-get install -y libasound2-dev libx11-dev libxcomposite-dev libxcursor-dev \
                        libxinerama-dev libxrandr-dev libfreetype6-dev libfontconfig1-dev \
                        libgl1-mesa-dev libcurl4-openssl-dev libwebkit2gtk-4.1-dev pkg-config \
                        build-essential
```

- Run `./scripts/validate-setup.sh` to verify installation
- Missing packages will cause CMake configuration to fail

### Documentation Linting Failures

- Always run `npm test` before committing
- Fix issues with `npm run lint:md:fix`
- Common issues: trailing whitespace, heading levels

### Build Performance Issues

- Debug builds are large (~197MB static library) but necessary for development
- Use Release builds for distribution: `cmake --preset=release && cmake --build --preset=release`
- Clean builds take full time; incremental builds are much faster

## JUCE Development Anti-Patterns

- Allocating memory in `getNextAudioBlock()` or other real-time contexts
- Using blocking operations (file I/O, network) in audio threads
- Ignoring sample rate changes in `prepareToPlay()`
- Creating audio dropouts through inefficient processing
- Not handling buffer size variations properly
- Mixing GUI and audio thread operations without proper synchronization

## Audio Quality Metrics

A successful JUCE audio project should:

- Process audio without dropouts or glitches
- Handle all standard sample rates (44.1kHz to 192kHz+)
- Work with various buffer sizes (32 to 2048 samples)
- Load properly in major DAWs (Reaper, Pro Tools, Logic, Cubase)
- Pass real-time safety validation tools
- Maintain consistent CPU usage under load
