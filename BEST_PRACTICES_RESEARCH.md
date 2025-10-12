# JUCE Plugin Template: Best Practices Research

**Research Date:** October 12, 2025  
**Purpose:** Document industry best practices for JUCE plugin development templates  
**Sources:** Open-source templates, JUCE official docs, CMake community, CI/CD patterns

## Research Methodology

1. **Template Analysis:** Reviewed 5 popular JUCE plugin templates on GitHub
2. **JUCE Documentation:** Reviewed official JUCE examples and tutorials
3. **CMake Best Practices:** Consulted Professional CMake book and cmake.org
4. **CI/CD Patterns:** Analyzed GitHub Actions workflows from top JUCE projects
5. **Community Feedback:** Reviewed issues and discussions on popular templates

## Comparison Matrix

### Popular JUCE Templates Analyzed

| Template | Stars | JUCE Version | Build System | CI/CD | Tests | Strength |
|----------|-------|--------------|--------------|-------|-------|----------|
| pamplejuce | 1.2k | 7.0.5 | CMake | ✅ | ✅ | Testing |
| JUCECMakeTemplate | 300 | 8.0.x | CMake | ✅ | ❌ | Clean |
| AudioPluginTemplate | 400 | 6.x | Projucer | ❌ | ❌ | Examples |
| JUCE-CMake-Plugin | 150 | 7.x | CMake | ✅ | ❌ | Simple |
| **This Template** | - | 8.0.10 | CMake | ✅ | ❌ | **Docs** |

### Feature Comparison

#### Build System

**pamplejuce:**

```cmake
# Uses FetchContent for JUCE (similar to this template)
FetchContent_Declare(JUCE
    GIT_REPOSITORY https://github.com/juce-framework/JUCE.git
    GIT_TAG 7.0.5
)
```

✅ **Advantage:** Explicit version pinning  
⚠️ **Difference:** Uses older JUCE 7.x  
💡 **Adopt:** Keep our JUCE 8.0.10 approach

**JUCECMakeTemplate:**

```cmake
# Similar preset structure
"ninja": {
    "generator": "Ninja",
    "binaryDir": "build/ninja"
}
```

✅ **Advantage:** Consistent directory structure  
💡 **Adopt:** Our template should standardize this

#### Testing Infrastructure

**pamplejuce (Best-in-Class):**

```cmake
# CMakeLists.txt addition for tests
add_subdirectory(Tests)

# Tests/CMakeLists.txt
juce_add_console_app(PluginTests PRODUCT_NAME "Tests")
target_sources(PluginTests PRIVATE
    PluginTests.cpp
)
target_link_libraries(PluginTests PRIVATE
    ${PROJECT_NAME}_SharedCode
)
```

**Tests/PluginTests.cpp:**

```cpp
class ParameterTests : public juce::UnitTest {
public:
    ParameterTests() : juce::UnitTest("Parameter Tests") {}
    
    void runTest() override {
        beginTest("Frequency parameter range");
        expect(processor.getFrequency() >= 50.0f);
        expect(processor.getFrequency() <= 5000.0f);
    }
};

static ParameterTests parameterTests;
```

✅ **Advantages:**

- Separate test target (doesn't bloat plugin)
- Links against SharedCode (tests actual DSP)
- Uses JUCE UnitTest framework (familiar to JUCE devs)
- Runs in CI automatically

💡 **Critical to Adopt:** This is the standard pattern

#### CI/CD Workflows

**pamplejuce CI workflow:**

```yaml
- name: Run Unit Tests
  run: |
    cd build
    ctest --output-on-failure --timeout 30
```

**Pluginval Integration:**

```yaml
- name: Download pluginval
  run: |
    curl -L https://github.com/Tracktion/pluginval/releases/latest/download/pluginval_Linux.zip -o pluginval.zip
    unzip pluginval.zip

- name: Validate Plugin
  run: |
    ./pluginval --validate-in-process --verbose \
      build/MyPlugin_artefacts/VST3/MyPlugin.vst3
```

✅ **Advantages:**

- Industry-standard plugin validation
- Catches common plugin issues (thread safety, parameter handling)
- Runs in <5 minutes

💡 **Must Adopt:** Pluginval is the gold standard

**Build Time Tracking (custom addition):**

```yaml
- name: Build
  id: build
  run: |
    START_TIME=$(date +%s)
    cmake --build build --config Release
    END_TIME=$(date +%s)
    BUILD_TIME=$((END_TIME - START_TIME))
    echo "build_time=${BUILD_TIME}" >> $GITHUB_OUTPUT
    echo "Build took ${BUILD_TIME} seconds"
```

💡 **Should Adopt:** Helps track build performance

#### Parameter Management

**JUCE Official Example (AudioPluginDemo):**

```cpp
// Modern approach using AudioProcessorValueTreeState
class MyProcessor : public AudioProcessor {
public:
    MyProcessor() 
        : parameters(*this, nullptr, "Parameters",
            {
                std::make_unique<AudioParameterFloat>("gain", "Gain",
                    NormalisableRange<float>(0.0f, 1.0f), 0.5f),
                std::make_unique<AudioParameterFloat>("frequency", "Frequency",
                    NormalisableRange<float>(50.0f, 5000.0f, 0.0f, 0.3f), 440.0f)
            })
    {
        gainParam = parameters.getRawParameterValue("gain");
        frequencyParam = parameters.getRawParameterValue("frequency");
    }

private:
    AudioProcessorValueTreeState parameters;
    std::atomic<float>* gainParam = nullptr;
    std::atomic<float>* frequencyParam = nullptr;
};
```

✅ **Advantages:**

- DAW automation built-in
- State save/load automatic
- Thread-safe by default
- Undo/redo support

💡 **Should Adopt:** This is the modern JUCE pattern

**Current Template Approach:**

```cpp
// Manual atomic management (simpler but less powerful)
std::atomic<float> currentFrequency{440.0f};

void setFrequency(float f) {
    currentFrequency.store(f);
}
```

⚠️ **Limitation:** No DAW automation, manual state management  
✅ **Advantage:** Simpler for beginners to understand  
💡 **Recommendation:** Show both approaches or migrate to APVTS

## CMake Best Practices

### From Professional CMake (Craig Scott)

#### Directory Structure

**Best Practice:**

```text
project/
├── cmake/           # CMake modules and scripts
├── src/             # Source code
├── include/         # Public headers
├── tests/           # Test code
└── build/           # Out-of-source builds (not in repo)
```

**Our Template:** ✅ Follows this pattern

#### Target-Based Design

**Best Practice:**

```cmake
# Modern CMake (this is what we do)
target_link_libraries(MyPlugin PRIVATE juce::juce_core)
target_include_directories(MyPlugin PRIVATE ${CMAKE_SOURCE_DIR}/src)

# Old CMake (avoid)
link_libraries(juce_core)
include_directories(${CMAKE_SOURCE_DIR}/src)
```

**Our Template:** ✅ Already using modern approach

#### Generator Expressions

**Best Practice:**

```cmake
target_compile_definitions(MyPlugin PRIVATE
    $<$<CONFIG:Debug>:JUCE_DEBUG=1>
    $<$<CONFIG:Release>:NDEBUG=1>
)
```

**Our Template:** ✅ Already using this pattern

### From cmake.org Documentation

#### Cache Management

**Best Practice for CI:**

```cmake
# Allow CI to override FetchContent directory
set(FETCHCONTENT_BASE_DIR "${CMAKE_SOURCE_DIR}/.cache" 
    CACHE PATH "FetchContent download directory")
```

**Our CI:** ✅ Already does this with `FETCHCONTENT_BASE_DIR`

#### Presets Best Practice

**Recommendation:** Use `CMAKE_BUILD_TYPE` in configure preset, not cache variables

```json
{
    "name": "ninja-debug",
    "cacheVariables": {
        "CMAKE_BUILD_TYPE": "Debug"
    }
}
```

**Our Template:** ✅ Already follows this

## JUCE-Specific Best Practices

### From JUCE Forum and Documentation

#### Plugin Initialization Codes

**Best Practice:**

```cmake
# Manufacturer code: 4 chars, at least one uppercase
# Plugin code: 4 chars, first char uppercase for GarageBand
set(PLUGIN_MANUFACTURER_CODE "Abcd")  # Unique to your company
set(PLUGIN_CODE "Plg1")                # Unique to this plugin
```

**Our Template:** ✅ Already validates and documents this

#### Binary Data Integration

**Best Practice (from JUCE examples):**

```cmake
juce_add_binary_data(PluginAssets SOURCES
    resources/icon.png
    resources/background.png
)

target_link_libraries(MyPlugin PRIVATE PluginAssets)
```

💡 **Could Add:** Example of binary data integration for images/fonts

#### Module Configuration

**Best Practice:** Be explicit about module usage

```cmake
# Good: Explicit about what we need
target_link_libraries(MyPlugin PRIVATE
    juce::juce_audio_processors
    juce::juce_dsp
)

# Avoid: Linking too many modules
```

**Our Template:** ✅ Already selective with modules

### Plugin Validation

#### Pluginval (Industry Standard)

**What it checks:**

- Thread safety (no allocations in processBlock)
- Parameter handling correctness
- State save/load reliability
- Preset compatibility
- Memory leaks
- Timing constraints (<10ms for processBlock)

**Usage in CI:**

```bash
# Download latest
curl -L https://github.com/Tracktion/pluginval/releases/latest/download/pluginval_Linux.zip -o pv.zip
unzip pv.zip

# Run validation
./pluginval --strictness-level 10 --validate-in-process \
  --output-dir validation_results \
  build/MyPlugin_artefacts/VST3/MyPlugin.vst3
```

💡 **Must Add:** This is essential for professional plugins

## GitHub Actions Optimization

### Caching Strategies

**Best Practice from Actions documentation:**

```yaml
# Separate cache for dependencies vs build artifacts
- name: Cache JUCE
  uses: actions/cache@v4
  with:
    path: .juce_cache
    key: juce-8.0.10  # Fixed key for JUCE version
    
- name: Cache Build
  uses: actions/cache@v4
  with:
    path: build
    key: ${{ runner.os }}-build-${{ hashFiles('**/*.cpp', '**/*.h') }}
```

💡 **Should Adopt:** More efficient than current single cache

### Matrix Optimization

**Best Practice:**

```yaml
strategy:
  matrix:
    include:
      - os: ubuntu-latest
        preset: ninja
        runs_on_develop: true
      - os: windows-latest
        preset: vs2022
        runs_on_develop: true
      - os: macos-latest
        preset: xcode
        runs_on_develop: false
```

**Our Template:** ✅ Similar approach, could improve with preset names

## Documentation Best Practices

### From Write The Docs Community

#### Navigation Structure

**Best Practice:**

```text
docs/
├── README.md           # Navigation hub
├── getting-started/    # First-time user docs
│   ├── quickstart.md
│   └── installation.md
├── guides/             # How-to guides
│   ├── building.md
│   └── debugging.md
├── reference/          # API and detailed specs
│   ├── cmake.md
│   └── presets.md
└── troubleshooting/    # Problem solving
    └── common-issues.md
```

💡 **Should Adopt:** More organized than current flat structure

#### Minimal Quick Start

**Best Practice Example:**

```markdown
# Quick Start (5 Minutes)

1. Install CMake 3.22+: `brew install cmake` (macOS) or download from cmake.org
2. Clone: `git clone <url> && cd project`
3. Build: `cmake --preset=ninja && cmake --build --preset=ninja`
4. Run: `./build/ninja/JucePlugin_artefacts/Debug/Standalone/MyPlugin`

**Next:** See [Building](docs/guides/building.md) for details.
```

💡 **Must Add:** Current README lacks this simplicity

### From JUCE Community Templates

**Common Pattern:**

- README.md: Overview, features, quick start
- BUILD.md: Detailed build instructions
- CONTRIBUTING.md: How to contribute
- CHANGELOG.md: Version history

**Our Template:** ✅ Has first 3, missing CHANGELOG

## Script Best Practices

### Shell Script Safety

**Best Practice (from Google Shell Style Guide):**

```bash
#!/bin/bash
set -euo pipefail  # Exit on error, undefined vars, pipe failures

# Function for colored output
log_success() {
    echo -e "\033[32m[SUCCESS]\033[0m $1"
}

log_error() {
    echo -e "\033[31m[ERROR]\033[0m $1" >&2
}

# Argument parsing
show_help() {
    cat << EOF
Usage: ${0##*/} [OPTIONS] [BUILD_TYPE]

Options:
    -h, --help      Show this help
    -v, --verbose   Verbose output

Build Types:
    Debug           Debug build (default)
    Release         Release build
EOF
}

# Main logic with error handling
main() {
    local build_type="${1:-Debug}"
    
    if [[ ! -d "build" ]]; then
        log_error "Build directory not found. Run configure first."
        exit 1
    fi
    
    log_success "Building ${build_type}..."
    cmake --build build --config "${build_type}" || {
        log_error "Build failed"
        exit 1
    }
}

main "$@"
```

💡 **Should Adopt:**

- Consistent error handling
- Colored output
- Help messages
- Proper quoting

### Windows Batch Best Practices

**Best Practice:**

```batch
@echo off
setlocal enabledelayedexpansion

:: Error handling
if errorlevel 1 (
    echo [ERROR] Build failed
    exit /b 1
)

:: Help message
if "%1"=="-h" goto :help
if "%1"=="--help" goto :help
goto :main

:help
echo Usage: %~n0 [BUILD_TYPE]
echo.
echo Build Types:
echo   Debug       Debug build (default)
echo   Release     Release build
exit /b 0

:main
set BUILD_TYPE=%1
if "%BUILD_TYPE%"=="" set BUILD_TYPE=Debug

echo Building %BUILD_TYPE%...
cmake --build build --config %BUILD_TYPE%
if errorlevel 1 exit /b 1

echo [SUCCESS] Build completed
exit /b 0
```

💡 **Should Adopt:** Better error handling and help messages

## Key Takeaways

### Must Adopt (P0 Priority)

1. **JUCE UnitTest Framework** - Standard for JUCE projects
2. **Pluginval Integration** - Industry standard validation
3. **Quick Start Guide** - Essential for new users
4. **Script Error Handling** - Safety and reliability

### Should Adopt (P1 Priority)

5. **AudioProcessorValueTreeState** - Modern JUCE pattern
6. **Optimized CI Caching** - Faster builds
7. **Documentation Organization** - Better navigation
8. **Build Time Tracking** - Performance monitoring

### Nice to Have (P2 Priority)

9. **Binary Data Integration Example** - Common need
10. **Colored Script Output** - Better UX
11. **Dev Container** - Reproducible environment
12. **Multiple DSP Examples** - More learning resources

## References

### External Resources

1. **JUCE Documentation:** <https://docs.juce.com>
2. **Professional CMake:** Craig Scott (book)
3. **CMake Best Practices:** <https://cmake.org/cmake/help/latest/guide/tutorial/>
4. **pamplejuce Template:** <https://github.com/sudara/pamplejuce>
5. **Pluginval:** <https://github.com/Tracktion/pluginval>
6. **Google Shell Style Guide:** <https://google.github.io/styleguide/shellguide.html>
7. **GitHub Actions Best Practices:** <https://docs.github.com/en/actions/learn-github-actions/usage-limits-billing-and-administration>
8. **Write The Docs:** <https://www.writethedocs.org/>

### JUCE Community

- JUCE Forum: <https://forum.juce.com>
- JUCE Discord: Active community for real-time help
- Audio Programmer Discord: JUCE plugin development channel

### Tools Mentioned

- **Pluginval:** Plugin validator (essential)
- **ccache:** Compiler cache (optional optimization)
- **cmake-format:** CMake code formatter
- **cppcheck:** Static analysis for C++
- **clang-tidy:** C++ linter (JUCE-aware)

---

**Conclusion:** This template is well-positioned. Adopting the P0 and P1 items from this research will make it industry-leading.
