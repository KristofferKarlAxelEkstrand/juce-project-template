# Improvement Issues Tracking

This document contains detailed issue specifications ready for creation in GitHub Issues.

---

## Issue #1: Add VS Code Debugging Configuration (launch.json)

**Priority**: P0 - Critical
**Labels**: developer-experience, vscode, debugging
**Milestone**: Developer Experience v1.0

### Description

The template lacks a `.vscode/launch.json` file, making it difficult for developers to debug their plugins in VS Code. While VSCODE_INTEGRATION.md documents the configuration, providing a ready-to-use file would significantly improve the onboarding experience.

### Problem Statement

New developers must manually create launch.json and update placeholder values, which is error-prone and time-consuming. This creates friction in the debugging workflow.

### Proposed Solution

Create `.vscode/launch.json` with cross-platform debugging configurations:

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "(Windows) Debug Standalone",
            "type": "cppvsdbg",
            "request": "launch",
            "program": "${workspaceFolder}/build/ninja/JucePlugin_artefacts/Debug/Standalone/JUCE Project Template Plugin.exe",
            "args": [],
            "stopAtEntry": false,
            "cwd": "${workspaceFolder}",
            "environment": [],
            "console": "integratedTerminal",
            "preLaunchTask": "Build Standalone (Ninja Debug)"
        },
        {
            "name": "(macOS) Debug Standalone",
            "type": "lldb",
            "request": "launch",
            "program": "${workspaceFolder}/build/ninja/JucePlugin_artefacts/Debug/Standalone/JUCE Project Template Plugin.app/Contents/MacOS/JUCE Project Template Plugin",
            "args": [],
            "cwd": "${workspaceFolder}",
            "preLaunchTask": "Build Standalone (Ninja Debug)"
        },
        {
            "name": "(Linux) Debug Standalone",
            "type": "cppdbg",
            "request": "launch",
            "program": "${workspaceFolder}/build/ninja/JucePlugin_artefacts/Debug/Standalone/JUCE Project Template Plugin",
            "args": [],
            "stopAtEntry": false,
            "cwd": "${workspaceFolder}",
            "environment": [],
            "externalConsole": false,
            "MIMode": "gdb",
            "setupCommands": [
                {
                    "description": "Enable pretty-printing for gdb",
                    "text": "-enable-pretty-printing",
                    "ignoreFailures": true
                }
            ],
            "preLaunchTask": "Build Standalone (Ninja Debug)"
        },
        {
            "name": "(Windows) Attach to DAW",
            "type": "cppvsdbg",
            "request": "attach",
            "processId": "${command:pickProcess}"
        },
        {
            "name": "(macOS) Attach to DAW",
            "type": "lldb",
            "request": "attach",
            "pid": "${command:pickProcess}"
        },
        {
            "name": "(Linux) Attach to DAW",
            "type": "cppdbg",
            "request": "attach",
            "processId": "${command:pickProcess}",
            "MIMode": "gdb"
        }
    ]
}
```

### Implementation Tasks

- [ ] Create .vscode/launch.json with configurations above
- [ ] Add note in file about updating paths after customization
- [ ] Update VSCODE_INTEGRATION.md to reference the file
- [ ] Add customization note to CUSTOMIZATION.md
- [ ] Test on all three platforms

### Acceptance Criteria

- Debugging works on Windows, macOS, and Linux with F5
- DAW attachment works on all platforms
- Documentation updated to reference provided configuration
- File includes comments about customization

### Related Issues

- Issue #2: IntelliSense configuration
- Issue #3: Extensions recommendations

---

## Issue #2: Add IntelliSense Configuration (c_cpp_properties.json)

**Priority**: P1 - High
**Labels**: developer-experience, vscode, intellisense
**Milestone**: Developer Experience v1.0

### Description

VS Code IntelliSense may not work correctly without a properly configured `c_cpp_properties.json`. The template should provide this configuration out-of-box.

### Problem Statement

Without c_cpp_properties.json, developers may experience:

- Incorrect error squiggles
- Poor code completion
- Broken go-to-definition
- Missing symbol references

### Proposed Solution

Create `.vscode/c_cpp_properties.json`:

```json
{
    "configurations": [
        {
            "name": "Windows (Ninja)",
            "compileCommands": "${workspaceFolder}/build/ninja/compile_commands.json",
            "cStandard": "c17",
            "cppStandard": "c++20",
            "intelliSenseMode": "windows-msvc-x64"
        },
        {
            "name": "macOS (Ninja)",
            "compileCommands": "${workspaceFolder}/build/ninja/compile_commands.json",
            "cStandard": "c17",
            "cppStandard": "c++20",
            "intelliSenseMode": "macos-clang-x64"
        },
        {
            "name": "Linux (Ninja)",
            "compileCommands": "${workspaceFolder}/build/ninja/compile_commands.json",
            "cStandard": "c17",
            "cppStandard": "c++20",
            "intelliSenseMode": "linux-gcc-x64"
        }
    ],
    "version": 4
}
```

### Implementation Tasks

- [ ] Create .vscode/c_cpp_properties.json
- [ ] Add platform-specific configurations
- [ ] Update VSCODE_INTEGRATION.md to reference the file
- [ ] Test IntelliSense on all platforms
- [ ] Verify compile_commands.json is generated by CMake

### Acceptance Criteria

- IntelliSense works after running "Configure Ninja" task
- Go-to-definition navigates correctly
- Error squiggles match actual build errors
- Code completion suggests correct types

---

## Issue #3: Add VS Code Extension Recommendations

**Priority**: P1 - High
**Labels**: developer-experience, vscode
**Milestone**: Developer Experience v1.0

### Description

VS Code can recommend extensions to users when they open the workspace, but this feature requires an `extensions.json` file.

### Problem Statement

New developers must manually discover and install required extensions, potentially missing essential tools like the C++ extension or CMake Tools.

### Proposed Solution

Create `.vscode/extensions.json`:

```json
{
    "recommendations": [
        "ms-vscode.cpptools",
        "ms-vscode.cmake-tools",
        "vadimcn.vscode-lldb",
        "twxs.cmake",
        "ms-vscode.cpptools-extension-pack"
    ],
    "unwantedRecommendations": []
}
```

### Extension Details

**Essential**:

- `ms-vscode.cpptools` - C/C++ IntelliSense and debugging
- `ms-vscode.cmake-tools` - CMake integration

**Platform-Specific**:

- `vadimcn.vscode-lldb` - LLDB debugger for macOS

**Quality of Life**:

- `twxs.cmake` - CMake syntax highlighting
- `ms-vscode.cpptools-extension-pack` - Complete C++ tooling

### Implementation Tasks

- [ ] Create .vscode/extensions.json
- [ ] Add all recommended extensions
- [ ] Document extensions in VSCODE_INTEGRATION.md
- [ ] Test that VS Code prompts for installation

### Acceptance Criteria

- VS Code prompts to install extensions on first open
- All extensions install successfully
- Documentation explains what each extension provides

---

## Issue #4: Add Build Performance Timing to Scripts

**Priority**: P2 - Medium
**Labels**: developer-experience, build-system
**Milestone**: Developer Experience v1.1

### Description

Build scripts should report execution time to help developers track build performance and identify regressions.

### Problem Statement

Developers can't easily tell if builds are getting slower over time or if their changes impact build performance.

### Proposed Solution

Add timing to build scripts:

**build-ninja.sh**:

```bash
echo "Building with Ninja ($BUILD_CONFIG configuration)..."
START_TIME=$(date +%s)

cmake --build build/ninja --config "$BUILD_CONFIG"
BUILD_EXIT_CODE=$?

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

if [ $BUILD_EXIT_CODE -eq 0 ]; then
    echo ""
    echo "✅ Build successful! (${DURATION}s)"
    echo "Artifacts are in: build/ninja/JucePlugin_artefacts/$BUILD_CONFIG/"
else
    echo ""
    echo "❌ Build failed after ${DURATION}s"
    exit $BUILD_EXIT_CODE
fi
```

**build-ninja.bat**:

```batch
echo Building with Ninja (%BUILD_CONFIG% configuration)...
set START_TIME=%TIME%

cmake --build build\ninja --config %BUILD_CONFIG%
set BUILD_EXIT_CODE=%ERRORLEVEL%

set END_TIME=%TIME%
:: Calculate duration (simplified)

if %BUILD_EXIT_CODE% == 0 (
    echo.
    echo Build successful!
    echo Artifacts are in: build\ninja\JucePlugin_artefacts\%BUILD_CONFIG%\
) else (
    echo.
    echo Build failed
    exit /b %BUILD_EXIT_CODE%
)
```

### Implementation Tasks

- [ ] Add timing to build-ninja.sh
- [ ] Add timing to build-ninja.bat
- [ ] Format output nicely (MM:SS if over 60s)
- [ ] Test on all platforms
- [ ] Update documentation with timing examples

### Acceptance Criteria

- Build time displayed after each build
- Time formatted for readability
- Works on Windows, macOS, and Linux

---

## Issue #5: Improve Build Validation Feedback

**Priority**: P2 - Medium
**Labels**: developer-experience, build-system
**Milestone**: Developer Experience v1.1

### Description

The validate-builds.sh script should provide better progress feedback during validation.

### Problem Statement

Users don't know what the script is checking during validation, leading to confusion during long operations.

### Proposed Solution

Add progress indicators to validate-builds.sh:

```bash
echo "Build Validation Started"
echo "========================"
echo ""

TOTAL_STEPS=4
CURRENT_STEP=0

progress() {
    CURRENT_STEP=$((CURRENT_STEP + 1))
    echo "[$CURRENT_STEP/$TOTAL_STEPS] $1"
}

progress "Checking artefacts directory..."
if ! check_exists "$ARTEFACTS_DIR" "Artefacts directory" -d; then
    exit 1
fi

progress "Validating VST3 plugin..."
check_exists "$vst3_bundle_path" "VST3 Plugin" -d || missing_artifacts+=("VST3 Plugin")

progress "Validating Standalone application..."
# ... validation code

progress "Validation complete!"
```

### Implementation Tasks

- [ ] Add progress function to validate-builds.sh
- [ ] Update all validation steps with progress calls
- [ ] Add summary with pass/fail count
- [ ] Test output formatting

### Acceptance Criteria

- Clear progress shown for each validation step
- Summary shows total checks and results
- Output is clean and professional

---

## Issue #6: Enhance Setup Validation and Promote in Onboarding

**Priority**: P1 - High
**Labels**: developer-experience, documentation, onboarding
**Milestone**: Onboarding Improvements

### Description

The validate-setup.sh script exists but is not prominently featured in onboarding. It should be enhanced and made a key part of the setup process.

### Problem Statement

New users may miss dependencies and encounter cryptic errors later in the build process.

### Proposed Solution

1. Enhance validate-setup.sh with installation suggestions:

```bash
check_tool() {
    local tool=$1
    local install_cmd=$2
    
    if command -v "$tool" &> /dev/null; then
        echo "✅ $tool found: $(command -v $tool)"
        return 0
    else
        echo "❌ $tool not found"
        if [ -n "$install_cmd" ]; then
            echo "   Install: $install_cmd"
        fi
        return 1
    fi
}

# Check CMake
check_tool "cmake" "brew install cmake (macOS) | sudo apt install cmake (Linux)" || MISSING_TOOLS=1

# Check compiler
if check_tool "g++" "sudo apt install build-essential (Linux)"; then
    GCC_VERSION=$(g++ --version | head -n1)
    echo "   Version: $GCC_VERSION"
fi
```

2. Update QUICKSTART.md:

````markdown
### Step 0: Validate Setup (30 seconds)

Before building, verify you have all required tools:

```bash
./scripts/validate-setup.sh
```
````bash
# This script will check if tools are available and suggest installation
```

If any tools are missing, install them using the suggested commands.

### Implementation Tasks

- [ ] Enhance validate-setup.sh with installation suggestions
- [ ] Add platform-specific dependency checks
- [ ] Add to QUICKSTART.md as Step 0
- [ ] Test on fresh systems
- [ ] Add exit code handling (0 = ready, 1 = missing tools)

### Acceptance Criteria

- Script detects all required tools
- Provides platform-specific installation commands
- Exits with clear success/failure indication
- QUICKSTART.md prominently features the script

---

## Issue #7: Create Automated VS Code Setup Script

**Priority**: P2 - Medium
**Labels**: developer-experience, vscode, automation
**Milestone**: Developer Experience v1.1

### Description

Create a script that generates VS Code configuration files with correct plugin names from CMake metadata.

### Problem Statement

After customizing plugin name in CMakeLists.txt, developers must manually update launch.json paths, which is error-prone.

### Proposed Solution

Create `scripts/setup-vscode.sh` and `scripts/setup-vscode.bat`:

```bash
#!/bin/bash
set -euo pipefail

echo "Setting up VS Code configuration..."

# Source plugin metadata
if [ ! -f "build/ninja/plugin_metadata.sh" ]; then
    echo "Error: Run './scripts/configure-ninja.sh' first"
    exit 1
fi

source build/ninja/plugin_metadata.sh

# Generate launch.json from template
sed -e "s/\${PLUGIN_NAME}/$PROJECT_NAME_PRODUCT/g" \
    -e "s/\${PLUGIN_TARGET}/$PROJECT_NAME_TARGET/g" \
    .vscode/templates/launch.json.template > .vscode/launch.json

echo "✅ Generated .vscode/launch.json with:"
echo "   Plugin Name: $PROJECT_NAME_PRODUCT"
echo "   Plugin Target: $PROJECT_NAME_TARGET"
echo ""
echo "You can now debug with F5 in VS Code"
```

### Implementation Tasks

- [ ] Create .vscode/templates/launch.json.template with placeholders
- [ ] Create scripts/setup-vscode.sh
- [ ] Create scripts/setup-vscode.bat
- [ ] Add to CUSTOMIZATION.md as customization step
- [ ] Test on all platforms

### Acceptance Criteria

- Script generates working launch.json
- Paths use correct plugin name
- Works after CMake configure
- Documentation updated

---

## Issue #12: Add Testing Framework and Documentation

**Priority**: P1 - High
**Labels**: testing, code-quality, documentation
**Milestone**: Testing Infrastructure v1.0

### Description

Add JUCE UnitTest framework integration with example tests and documentation.

### Problem Statement

Template has no testing infrastructure, making it unclear how to write tests for audio plugins.

### Proposed Solution

1. Add test source file:

**src/Tests/DSPJuceAudioProcessorTests.cpp**:

```cpp
#include "../DSPJuceAudioProcessor.h"
#include <juce_core/juce_core.h>

class DSPJuceAudioProcessorTests : public juce::UnitTest {
public:
    DSPJuceAudioProcessorTests() 
        : juce::UnitTest("DSPJuceAudioProcessor", "Core") {}
    
    void runTest() override {
        beginTest("Frequency parameter bounds");
        {
            DSPJuceAudioProcessor processor;
            
            // Test valid frequency using APVTS
            auto freqValue = processor.parameters.getParameterAsValue(DSPJuceAudioProcessor::PARAM_ID_FREQUENCY);
            freqValue.setValue(440.0f);
            expect((float)freqValue.getValue() == 440.0f, 
                   "Frequency should be set to 440 Hz");
            
            // Test clamping at lower bound
            freqValue.setValue(10.0f);  // Below MIN_FREQUENCY (20 Hz)
            expect((float)freqValue.getValue() >= 20.0f, 
                   "Frequency should be clamped to minimum");
        }
        
        beginTest("Gain parameter bounds");
        {
            DSPJuceAudioProcessor processor;
            
            // Test valid gain using APVTS
            auto gainValue = processor.parameters.getParameterAsValue(DSPJuceAudioProcessor::PARAM_ID_GAIN);
            gainValue.setValue(0.5f);
            expect((float)gainValue.getValue() == 0.5f, 
                   "Gain should be set to 0.5");
            
            gainValue.setValue(1.5f);  // Above MAX_GAIN (1.0)
            expect((float)gainValue.getValue() <= 1.0f, 
                   "Gain should be clamped to maximum");
        }
    }
};

static DSPJuceAudioProcessorTests processorTests;
```

**Note**: With the migration to APVTS, add tests for state persistence:

```cpp
// Test state save/load with APVTS ValueTree
beginTest("Parameter state persistence");
{
    DSPJuceAudioProcessor processor;
    
    // Set test values
    auto freqValue = processor.parameters.getParameterAsValue(DSPJuceAudioProcessor::PARAM_ID_FREQUENCY);
    auto gainValue = processor.parameters.getParameterAsValue(DSPJuceAudioProcessor::PARAM_ID_GAIN);
    freqValue.setValue(880.0f);
    gainValue.setValue(0.75f);
    
    // Save state
    juce::MemoryBlock stateData;
    processor.getStateInformation(stateData);
    
    // Create new processor and restore state
    DSPJuceAudioProcessor processor2;
    processor2.setStateInformation(stateData.getData(), static_cast<int>(stateData.getSize()));
    
    // Verify state was restored
    auto freqParam2 = processor2.parameters.getParameterAsValue(DSPJuceAudioProcessor::PARAM_ID_FREQUENCY);
    auto gainParam2 = processor2.parameters.getParameterAsValue(DSPJuceAudioProcessor::PARAM_ID_GAIN);
    expect(freqParam2.getValue() == 880.0f, "Frequency should be restored");
    expect(gainParam2.getValue() == 0.75f, "Gain should be restored");
}
```

2. Create test runner:

**src/Tests/TestRunner.cpp**:

```cpp
#include <juce_core/juce_core.h>

int main(int argc, char* argv[]) {
    juce::UnitTestRunner runner;
    runner.runAllTests();
    
    int numFailures = runner.getNumResults() - 
                      runner.getNumResultsWithStatus(juce::UnitTestRunner::TestResult::passed);
    
    return numFailures > 0 ? 1 : 0;
}
```

3. Update CMakeLists.txt:

```cmake
# Add test executable (optional, only if tests exist)
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/src/Tests")
    add_executable(${PLUGIN_TARGET}_Tests
        src/Tests/TestRunner.cpp
        src/Tests/DSPJuceAudioProcessorTests.cpp
        src/DSPJuceAudioProcessor.cpp
        src/DSPJuceAudioProcessor.h
    )
    
    target_link_libraries(${PLUGIN_TARGET}_Tests PRIVATE
        juce::juce_core
        juce::juce_audio_processors
        juce::juce_dsp
    )
    
    enable_testing()
    add_test(NAME ProcessorTests COMMAND ${PLUGIN_TARGET}_Tests)
endif()
```

4. Create docs/TESTING.md

### Implementation Tasks

- [ ] Create src/Tests/ directory structure
- [ ] Add example test file
- [ ] Create test runner
- [ ] Update CMakeLists.txt
- [ ] Add VS Code test task
- [ ] Create docs/TESTING.md
- [ ] Add CI test execution

### Acceptance Criteria

- Tests compile and run successfully
- Example tests pass
- VS Code task runs tests
- Documentation explains how to write tests
- CI executes tests

---

## Issue #18: Migrate to AudioProcessorValueTreeState

**Priority**: P1 - High
**Labels**: code-modernization, juce-best-practices
**Milestone**: JUCE Modernization v1.0

### Description

Replace manual atomic parameter handling with JUCE's AudioProcessorValueTreeState (APVTS) for better plugin host integration.

### Problem Statement

Current implementation uses manual `std::atomic<float>` for parameters. While functional, APVTS provides:

- Automatic parameter automation
- Host parameter name/range reporting
- Built-in undo/redo support
- Simpler state management

### Proposed Solution

**Update DSPJuceAudioProcessor.h**:

```cpp
class DSPJuceAudioProcessor : public juce::AudioProcessor {
public:
    DSPJuceAudioProcessor();
    
    // Replace manual atomics with APVTS
    juce::AudioProcessorValueTreeState parameters;
    
private:
    static juce::AudioProcessorValueTreeState::ParameterLayout createParameterLayout();
    
    juce::dsp::Oscillator<float> oscillator;
    juce::dsp::Gain<float> gain;
    
    // Attachments for real-time parameter updates
    std::unique_ptr<juce::AudioProcessorValueTreeState::SliderAttachment> frequencyAttachment;
    std::unique_ptr<juce::AudioProcessorValueTreeState::SliderAttachment> gainAttachment;
};
```

**Update DSPJuceAudioProcessor.cpp**:

```cpp
juce::AudioProcessorValueTreeState::ParameterLayout 
DSPJuceAudioProcessor::createParameterLayout() {
    juce::AudioProcessorValueTreeState::ParameterLayout layout;
    
    layout.add(std::make_unique<juce::AudioParameterFloat>(
        "frequency",
        "Frequency",
        juce::NormalisableRange<float>(20.0f, 20000.0f, 0.01f, 0.25f),
        440.0f,
        juce::AudioParameterFloatAttributes()
            .withLabel("Hz")
            .withCategory(juce::AudioProcessorParameter::genericParameter)
    ));
    
    layout.add(std::make_unique<juce::AudioParameterFloat>(
        "gain",
        "Gain",
        juce::NormalisableRange<float>(0.0f, 1.0f, 0.01f),
        0.5f,
        juce::AudioParameterFloatAttributes()
            .withLabel("Linear")
    ));
    
    return layout;
}

DSPJuceAudioProcessor::DSPJuceAudioProcessor()
    : parameters(*this, nullptr, "Parameters", createParameterLayout())
{
    // ...
}
```

**Update processBlock()**:

```cpp
void DSPJuceAudioProcessor::processBlock(
    juce::AudioBuffer<float>& buffer, 
    juce::MidiBuffer& midiMessages) {
    
    // Get parameters from APVTS
    auto* freqParam = parameters.getRawParameterValue("frequency");
    auto* gainParam = parameters.getRawParameterValue("gain");
    
    oscillator.setFrequency(freqParam->load());
    gain.setGainLinear(gainParam->load());
    
    // ... rest of processing
}
```

### Implementation Tasks

- [ ] Create createParameterLayout() method
- [ ] Replace atomics with APVTS
- [ ] Update PluginEditor to use APVTS attachments
- [ ] Update state save/load (APVTS handles automatically)
- [ ] Add migration guide to docs
- [ ] Update JUCE documentation references

### Acceptance Criteria

- Parameters appear in host automation list
- Parameter names and ranges reported correctly
- State save/load works
- No regression in audio performance
- Documentation updated

### Breaking Changes

This changes the internal architecture but maintains the same functionality. Users with customized code will need to migrate.

---

## Issue #24: Create Comprehensive Linux Setup Guide

**Priority**: P2 - Medium
**Labels**: documentation, linux, onboarding
**Milestone**: Documentation Improvements

### Description

Create dedicated Linux setup documentation covering distribution-specific dependencies and audio system configuration.

### Problem Statement

Linux users face unique challenges with audio systems, dependencies, and VST3 installation that aren't covered in detail.

### Proposed Solution

Create **docs/LINUX_SETUP.md**:

```markdown
# Linux Setup Guide

Complete guide for setting up JUCE plugin development on Linux.

## Distribution-Specific Setup

### Ubuntu/Debian

```bash
# Install build tools
sudo apt update
sudo apt install -y \
    build-essential \
    cmake \
    ninja-build \
    git \
    pkg-config

# Install JUCE dependencies
sudo apt install -y \
    libasound2-dev \
    libx11-dev \
    libxcomposite-dev \
    libxcursor-dev \
    libxinerama-dev \
    libxrandr-dev \
    libfreetype6-dev \
    libfontconfig1-dev \
    libgl1-mesa-dev \
    libxext-dev \
    libwebkit2gtk-4.1-dev

# Install optional tools
sudo apt install -y \
    clang-format \
    gdb \
    valgrind
```

### Fedora/RHEL

```bash
# Install build tools
sudo dnf groupinstall "Development Tools"
sudo dnf install cmake ninja-build git pkg-config

# Install JUCE dependencies
sudo dnf install \
    alsa-lib-devel \
    libX11-devel \
    libXcomposite-devel \
    libXcursor-devel \
    libXinerama-devel \
    libXrandr-devel \
    freetype-devel \
    fontconfig-devel \
    mesa-libGL-devel \
    webkit2gtk4.1-devel
```

### Arch Linux

```bash
# Install build tools
sudo pacman -S base-devel cmake ninja git pkg-config

# Install JUCE dependencies
sudo pacman -S \
    alsa-lib \
    libx11 \
    libxcomposite \
    libxcursor \
    libxinerama \
    libxrandr \
    freetype2 \
    fontconfig \
    mesa \
    webkit2gtk
```

## Audio System Configuration

### ALSA (Advanced Linux Sound Architecture)

Default audio system, works out-of-box.

### PulseAudio

Most common desktop audio server.

Check status:

```bash
systemctl --user status pulseaudio
```

### JACK (JACK Audio Connection Kit)

Professional audio routing system.

Install:

```bash
# Ubuntu
sudo apt install jackd2 qjackctl

# Start JACK with low latency
jackd -dalsa -r48000 -p128
```

### PipeWire

Modern audio server replacing PulseAudio.

```bash
# Check if running
systemctl --user status pipewire
```

## VST3 Installation Paths

User plugins:

```
~/.vst3/
```

System-wide plugins:

```
/usr/lib/vst3/
/usr/local/lib/vst3/
```

## Testing Your Plugin

### Install for Testing

```bash
# Copy VST3 to user directory
mkdir -p ~/.vst3
cp -r build/ninja/JucePlugin_artefacts/Debug/VST3/*.vst3 ~/.vst3/
```

### DAWs for Testing

**Free/Open Source**:

- Ardour
- Qtractor  
- LMMS
- Carla (host)

**Commercial**:

- Bitwig Studio
- Reaper (Linux version)

## Common Issues

### Audio Permissions

Add user to audio group:

```bash
sudo usermod -aG audio $USER
# Log out and back in
```

### Real-Time Priority

For JACK real-time:

```bash
sudo dpkg-reconfigure -p high jackd2
```

### Library Conflicts

If you see "undefined symbol" errors:

```bash
# Check library dependencies
ldd build/ninja/JucePlugin_artefacts/Debug/VST3/YourPlugin.vst3/Contents/x86_64-linux/YourPlugin.so
```

## See Also

- [BUILD.md](../BUILD.md) - General build instructions
- [DEVELOPMENT_WORKFLOW.md](../DEVELOPMENT_WORKFLOW.md) - Development workflow

```

### Implementation Tasks

- [ ] Create docs/LINUX_SETUP.md
- [ ] Add distribution-specific commands
- [ ] Document audio system setup
- [ ] Add troubleshooting section
- [ ] Test on Ubuntu, Fedora, and Arch
- [ ] Link from README and BUILD.md

### Acceptance Criteria

- Guide covers major distributions
- Audio systems explained
- VST3 installation documented
- Tested on real Linux systems

---

## Meta: Create GitHub Issue Templates

**Priority**: P2 - Medium
**Labels**: github, project-management
**Milestone**: Repository Improvements

### Description

Add issue and PR templates to improve contribution quality.

### Proposed Templates

**bug_report.md**:
```markdown
---
name: Bug Report
about: Report a bug or unexpected behavior
labels: bug
---

## Description
[Clear description of the bug]

## Steps to Reproduce
1. [First step]
2. [Second step]
3. [...]

## Expected Behavior
[What should happen]

## Actual Behavior
[What actually happens]

## Environment
- OS: [Windows/macOS/Linux]
- Version: [e.g., Windows 11, macOS 14.0]
- CMake version: [output of `cmake --version`]
- Compiler: [MSVC/GCC/Clang and version]

## Build Configuration
- Preset used: [default/vs2022/ninja/etc.]
- Build type: [Debug/Release]

## Additional Context
[Any other relevant information]
```

**feature_request.md**:

```markdown
---
name: Feature Request
about: Suggest a new feature or enhancement
labels: enhancement
---

## Feature Description
[Clear description of the feature]

## Use Case
[Why is this feature needed?]

## Proposed Solution
[How should this work?]

## Alternatives Considered
[Other approaches you've thought about]

## Additional Context
[Any other relevant information]
```

**pull_request_template.md**:

```markdown
## Description
[Describe your changes]

## Type of Change
- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update

## How Has This Been Tested?
- [ ] Tested on Windows
- [ ] Tested on macOS
- [ ] Tested on Linux

## Checklist
- [ ] Code formatted with clang-format (C++) or prettier (markdown)
- [ ] Documentation updated (if applicable)
- [ ] Build succeeds locally
- [ ] No new warnings introduced
- [ ] CHANGELOG updated (if applicable)
```

### Implementation Tasks

- [ ] Create .github/ISSUE_TEMPLATE/bug_report.md
- [ ] Create .github/ISSUE_TEMPLATE/feature_request.md
- [ ] Create .github/pull_request_template.md
- [ ] Test templates in draft issues/PRs
- [ ] Update CONTRIBUTING.md to reference templates

### Acceptance Criteria

- Templates appear when creating issues/PRs
- All fields are clear and useful
- Templates guide quality submissions
