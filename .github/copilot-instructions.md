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
                            libgl1-mesa-dev libcurl4-openssl-dev libwebkit2gtk-4.1-dev pkg-config
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
    - May show CMake internal error but generates working Makefiles

4. **Build Application:**

    ```bash
    cmake --build --preset=default
    ```

    - **NEVER CANCEL:** Takes 2+ minutes to complete. Set timeout to 300+ seconds.
    - **KNOWN ISSUE:** Build currently fails at linking step due to Sheenbidi object file issue
    - **Status:** Compiles successfully but linking fails - this is a known JUCE/CMake issue

### Current Build Status

**BUILD STATUS VARIES BY PLATFORM**

-   **Windows:** The application compiles and links successfully when using the Visual Studio generator (`--preset=vs2022`).
-   **Linux:** The build fails at the final linking step with a "cannot find... Sheenbidi.c.o" error. This is a known JUCE framework build system issue.

**DO NOT** attempt to "fix" the Linux linking issue as part of normal development work. This requires investigation by JUCE experts. On Windows, the build is stable.

### Validation and Testing

Since the build currently fails, **DO NOT** attempt to run the application. Instead:

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
    - Takes ~5 seconds
    - Always run before committing changes

3. **Code Formatting:**

    ```bash
    clang-format -i src/*.cpp src/*.h
    ```

## Project Structure

```text
dsp-juce/
├── src/                     # JUCE application source code
│   ├── Main.cpp            # Application entry point and window management
│   ├── MainComponent.h     # Audio component interface
│   └── MainComponent.cpp   # Real-time audio processing with DSP
├── .github/                # GitHub configuration and instructions
├── CMakeLists.txt          # Modern CMake with JUCE 8.0.9 FetchContent
├── CMakePresets.json       # Cross-platform build presets
├── package.json           # NPM tooling for documentation linting
├── scripts/               # Setup validation scripts
└── build/                 # Auto-generated build directory (ignored by git)
```

## Key Technologies

-   **JUCE 8.0.9:** Modern audio framework with real-time DSP capabilities
-   **CMake 3.22+:** Cross-platform build system with FetchContent for dependencies
-   **C++20:** Modern language features with RAII and smart pointers
-   **Real-time Audio:** Thread-safe audio processing with proper buffer management

## Development Workflow

### Before Making Changes

1. **Always validate current state:**

    ```bash
    ./scripts/validate-setup.sh
    npm test
    ```

2. **Understand the build limitation:**
    - The project compiles but does not currently produce a working executable
    - Focus on code quality, structure, and documentation
    - Test changes through compilation only

### Making Changes

1. **Follow JUCE patterns** in MainComponent.h/cpp:

    - Real-time safe audio processing in `getNextAudioBlock()`
    - Thread-safe parameter handling between GUI and audio threads
    - Proper resource management in `prepareToPlay()` and `releaseResources()`

2. **Always format code:**

    ```bash
    clang-format -i src/*.cpp src/*.h
    ```

3. **Validate changes compile:**

    ```bash
    cmake --preset=default  # 90+ seconds, NEVER CANCEL
    cmake --build --preset=default  # 2+ minutes, NEVER CANCEL, will fail at linking but validates compilation
    ```

### Code Quality Standards

-   **Real-Time Safety:** No dynamic memory allocation in audio callbacks
-   **Thread Safety:** Use atomic operations for parameter access between threads
-   **Modern C++20:** Use auto, constexpr, smart pointers, structured bindings
-   **JUCE Conventions:** Follow camelCase for methods, PascalCase for classes
-   **Documentation:** Add Doxygen-style comments for public APIs

## Common Tasks and Outputs

### Repository Root Contents

```text
ls -la /home/runner/work/dsp-juce/dsp-juce
total 100
drwxr-xr-x 11 runner runner  4096 Sep 14 17:26 .
drwxr-xr-x  3 runner runner  4096 Sep 14 17:26 ..
-rw-r--r--  1 runner runner   602 Sep 14 17:26 .clang-format
drwxr-xr-x  8 runner runner  4096 Sep 14 17:26 .git
drwxr-xr-x  6 runner runner  4096 Sep 14 17:26 .github
-rw-r--r--  1 runner runner   177 Sep 14 17:26 .gitignore
drwxr-xr-x  2 runner runner  4096 Sep 14 17:26 .husky
-rw-r--r--  1 runner runner   285 Sep 14 17:26 .markdownlint-cli2.jsonc
-rw-r--r--  1 runner runner   151 Sep 14 17:26 .prettierignore.example
-rw-r--r--  1 runner runner   151 Sep 14 17:26 .prettierrc.example
drwxr-xr-x  2 runner runner  4096 Sep 14 17:26 .vscode
-rw-r--r--  1 runner runner  4272 Sep 14 17:26 CMakeLists.txt
-rw-r--r--  1 runner runner  1795 Sep 14 17:26 CMakePresets.json
-rw-r--r--  1 runner runner  8358 Sep 14 17:26 README.md
drwxr-xr-x  4 runner runner  4096 Sep 14 17:26 docs
-rw-r--r--  1 runner runner 15621 Sep 14 17:26 package-lock.json
-rw-r--r--  1 runner runner   529 Sep 14 17:26 package.json
drwxr-xr-x  2 runner runner  4096 Sep 14 17:26 scripts
drwxr-xr-x  2 runner runner  4096 Sep 14 17:26 src
```

### Source Code Structure

```text
ls -la src/
total 20
drwxr-xr-x 2 runner runner 4096 Sep 14 17:26 .
drwxr-xr-x 11 runner runner 4096 Sep 14 17:26 ..
-rw-r--r-- 1 runner runner 2737 Sep 14 17:26 Main.cpp
-rw-r--r-- 1 runner runner 3814 Sep 14 17:26 MainComponent.cpp
-rw-r--r-- 1 runner runner 1560 Sep 14 17:26 MainComponent.h
```

### Build Process Output (Expected)

-   **CMake Configuration:** 90+ seconds, generates build files despite internal error message
-   **Compilation:** 2+ minutes, compiles all JUCE modules successfully
-   **Linking:** Fails with Sheenbidi object file error (known issue)
-   **Overall Time:** 3-4 minutes total for full build attempt

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

## Troubleshooting

### CMake Configuration Issues

-   **Error:** "CMAKE_C_COMPILE_OBJECT variable not set"
-   **Status:** Known issue, build files are generated correctly despite this error
-   **Action:** Continue with build process

### Build Linking Failure

-   **Error:** "cannot find juce_graphics_Sheenbidi.c.o"
-   **Status:** Known JUCE framework issue affecting this environment
-   **Action:** Focus on compilation validation, not executable creation

### Missing Dependencies (Linux)

-   Install all packages in the bootstrap section
-   Run `./scripts/validate-setup.sh` to verify installation
-   Missing packages will cause CMake configuration to fail

### Documentation Linting Failures

-   Always run `npm test` before committing
-   Fix issues with `npm run lint:md:fix`
-   Common issues: trailing whitespace, heading levels

## JUCE Development Anti-Patterns

-   Allocating memory in `getNextAudioBlock()` or other real-time contexts
-   Using blocking operations (file I/O, network) in audio threads
-   Ignoring sample rate changes in `prepareToPlay()`
-   Creating audio dropouts through inefficient processing
-   Not handling buffer size variations properly
-   Mixing GUI and audio thread operations without proper synchronization

## Audio Quality Metrics

A successful JUCE audio project should:

-   Process audio without dropouts or glitches
-   Handle all standard sample rates (44.1kHz to 192kHz+)
-   Work with various buffer sizes (32 to 2048 samples)
-   Load properly in major DAWs (Reaper, Pro Tools, Logic, Cubase)
-   Pass real-time safety validation tools
-   Maintain consistent CPU usage under load
