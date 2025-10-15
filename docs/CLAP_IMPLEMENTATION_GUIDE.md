# CLAP Integration Implementation Guide

Step-by-step guide for adding CLAP plugin format support to the JUCE Project Template.

## Prerequisites

- JUCE 8.0.10 (already configured via FetchContent or submodule)
- CMake 3.22+
- Understanding of CLAP_INTEGRATION_RESEARCH.md findings

## Implementation Options

### Option 1: FetchContent (Recommended)

Automatic download of clap-juce-extensions during CMake configuration.

**Advantages**:

- No manual dependency management
- Always gets latest version from main branch
- Matches existing JUCE FetchContent pattern
- Clean repository (no submodule updates needed)

**Disadvantages**:

- Downloads dependency during configure (adds time)
- Requires internet connection for fresh builds

### Option 2: Git Submodule

Manual cloning of clap-juce-extensions as git submodule.

**Advantages**:

- Matches existing JUCE submodule pattern (if used)
- Works offline after initial clone
- Version locked to specific commit

**Disadvantages**:

- Requires `git submodule update --init --recursive`
- Manual updates needed for new versions
- More complex for new users

## Step-by-Step Implementation (Option 1: FetchContent)

### Step 1: Update CMakeLists.txt

Add CLAP support after the JUCE plugin configuration.

**Location**: After `juce_add_plugin()` and before `target_sources()`

**Code to add**:

```cmake
# =============================================================================
# CLAP PLUGIN FORMAT (Optional)
# =============================================================================
# Enable CLAP plugin format using clap-juce-extensions
# This is a third-party library until JUCE 9 provides native CLAP support
# See: https://github.com/free-audio/clap-juce-extensions

option(BUILD_CLAP "Build CLAP plugin format" ON)

if(BUILD_CLAP)
    message(STATUS "CLAP format: Enabled")
    
    # Download clap-juce-extensions via FetchContent
    include(FetchContent)
    FetchContent_Declare(
        clap-juce-extensions
        GIT_REPOSITORY https://github.com/free-audio/clap-juce-extensions.git
        GIT_TAG main
        GIT_SHALLOW TRUE
        GIT_PROGRESS TRUE
    )
    FetchContent_MakeAvailable(clap-juce-extensions)
    
    # Add CLAP plugin target
    # This creates ${PLUGIN_TARGET}_CLAP alongside existing formats
    clap_juce_extensions_plugin(
        TARGET ${PLUGIN_TARGET}
        CLAP_ID "${PLUGIN_BUNDLE_ID}"
        CLAP_FEATURES instrument synthesizer
        CLAP_MANUAL_URL "${PLUGIN_COMPANY_WEBSITE}"
        CLAP_SUPPORT_URL "${PLUGIN_COMPANY_WEBSITE}"
    )
    
    message(STATUS "CLAP target: ${PLUGIN_TARGET}_CLAP")
else()
    message(STATUS "CLAP format: Disabled (BUILD_CLAP=OFF)")
endif()
```

**Customization Notes**:

- `CLAP_FEATURES`: Set based on plugin type
  - Effects: `audio-effect stereo distortion`
  - Instruments: `instrument synthesizer`
  - Utilities: `utility analyzer`
  - Full list: https://github.com/free-audio/clap/blob/main/include/clap/plugin-features.h

**Placement**: Insert this block after line 157 in CMakeLists.txt (after `juce_add_plugin()` block)

### Step 2: Update Build Validation Script

Modify `scripts/validate-builds.sh` to check for CLAP artifacts.

**File**: `scripts/validate-builds.sh`

**Changes needed**:

1. Add CLAP artifact path detection
2. Add CLAP validation checks
3. Handle optional CLAP builds (when BUILD_CLAP=OFF)

**Code additions** (after VST3 and AU checks, around line 80):

```bash
# --- CLAP Plugin Check ---
if [ "$OS" = "windows" ]; then
    clap_path="$ARTEFACTS_DIR/CLAP/${PROJECT_NAME_PRODUCT}.clap"
elif [ "$OS" = "macos" ]; then
    clap_path="$ARTEFACTS_DIR/CLAP/${PROJECT_NAME_PRODUCT}.clap"
else
    clap_path="$ARTEFACTS_DIR/CLAP/${PROJECT_NAME_PRODUCT}.clap"
fi

# CLAP is optional (controlled by BUILD_CLAP CMake option)
if [ -e "$clap_path" ]; then
    if check_exists "$clap_path" "CLAP plugin" -d; then
        echo "  CLAP format: Built"
    else
        missing_optional_artifacts+=("CLAP plugin: $clap_path")
    fi
else
    echo "  CLAP format: Not built (BUILD_CLAP=OFF or build failed)"
fi
```

### Step 3: Update Documentation

#### A. Update PLUGIN_FORMATS.md

Add CLAP section to `docs/PLUGIN_FORMATS.md`.

**Location**: After AU section, before Standalone section

**Content**:

```markdown
### CLAP (CLever Audio Plug-in)

**Description**: Modern open-source plugin format

**Platforms**:

- Windows: Full support
- macOS: Full support
- Linux: Full support

**Extension**: `.clap` (bundle)

**Installation Path**:

- Windows: `C:\Program Files\Common Files\CLAP\`
- macOS: `/Library/Audio/Plug-Ins/CLAP/`
- Linux: `~/.clap/` or `/usr/lib/clap/`

**Build Output**:

**Windows**:

```text
build/ninja/JucePlugin_artefacts/Debug/CLAP/Your Plugin.clap/
```

**macOS**:

```text
build/ninja/JucePlugin_artefacts/Debug/CLAP/Your Plugin.clap/
```

**Linux**:

```text
build/ninja/JucePlugin_artefacts/Debug/CLAP/Your Plugin.clap/
```

**Compatibility**: CLAP-enabled DAWs (Bitwig Studio 4.3+, Reaper 6.44+, MultitrackStudio, FL Studio 21.2+)

**Note**: CLAP support uses clap-juce-extensions library until JUCE 9 provides native support.

**Enable/Disable**: Set `BUILD_CLAP=ON` or `BUILD_CLAP=OFF` in CMake configuration.

```bash
# Enable CLAP
cmake -B build/ninja -G Ninja -DBUILD_CLAP=ON

# Disable CLAP
cmake -B build/ninja -G Ninja -DBUILD_CLAP=OFF
```
```

#### B. Update Format Comparison Table

In `docs/PLUGIN_FORMATS.md`, update the format comparison table:

```markdown
| Feature | VST3 | AU | CLAP | Standalone |
|---------|------|-----|------|-----------|
| Cross-platform | Yes | macOS only | Yes | Yes |
| Requires DAW | Yes | Yes | Yes | No |
| Development testing | Slow | Slow | Slow | Fast |
| Distribution | Wide support | macOS DAWs | Growing support | Any user |
| Licensing | Trademark restrictions | Apple only | Open-source | N/A |
| Audio I/O | Via DAW | Via DAW | Via DAW | Direct hardware |
| MIDI support | Via DAW | Via DAW | Via DAW | Direct hardware |
| Modern features | Yes | Limited | Advanced | N/A |
```

#### C. Add CLAP Installation Section

Add to "Installation for Testing" section:

```markdown
### Installing CLAP

**Windows**:

```cmd
xcopy /E /I "build\ninja\JucePlugin_artefacts\Debug\CLAP\Your Plugin.clap" ^
      "C:\Program Files\Common Files\CLAP\Your Plugin.clap"
```

**macOS**:

```bash
cp -r "build/ninja/JucePlugin_artefacts/Debug/CLAP/Your Plugin.clap" \
      "/Library/Audio/Plug-Ins/CLAP/"
```

**Linux**:

```bash
cp -r "build/ninja/JucePlugin_artefacts/Debug/CLAP/Your Plugin.clap" \
      "$HOME/.clap/"
```

After copying, rescan plugins in your CLAP-compatible DAW.
```

### Step 4: Update README.md

Add CLAP to the plugin formats list.

**Location**: Features section or Quick Start section

**Change**:

```markdown
- **Plugin Formats**: VST3, AU (macOS), CLAP, and Standalone
```

### Step 5: Add VS Code Tasks (Optional)

Add CLAP-specific build tasks to `.vscode/tasks.json`.

**New task**:

```json
{
    "label": "Build CLAP (Ninja Debug)",
    "type": "shell",
    "command": "cmake",
    "args": [
        "--build",
        "${workspaceFolder}/build/ninja",
        "--target",
        "JucePlugin_CLAP"
    ],
    "group": "build",
    "problemMatcher": "$gcc"
}
```

### Step 6: Update GitHub Actions (Optional)

Modify `.github/workflows/build.yml` to include CLAP artifacts.

**Changes**:

1. CLAP builds automatically with other formats (no workflow changes needed)
2. Update artifact collection to include CLAP directory
3. Update release asset packaging to include CLAP

**Example artifact collection**:

```yaml
- name: Upload CLAP Artifacts
  uses: actions/upload-artifact@v3
  with:
    name: ${{ matrix.name }}-CLAP
    path: |
      build/*/JucePlugin_artefacts/*/CLAP/*.clap
```

## Testing the Integration

### Build and Verify

**Step 1: Configure with CLAP enabled**:

```bash
# Linux/macOS
./scripts/configure-ninja.sh

# Windows
scripts\configure-ninja.bat

# Or manually
cmake -B build/ninja -G Ninja -DBUILD_CLAP=ON
```

**Expected output**:

```text
-- CLAP format: Enabled
-- Fetching clap-juce-extensions...
-- CLAP target: JucePlugin_CLAP
```

**Step 2: Build**:

```bash
# Linux/macOS
./scripts/build-ninja.sh

# Windows
scripts\build-ninja.bat

# Or manually
cmake --build build/ninja
```

**Expected output**: `JucePlugin_CLAP` target builds successfully

**Step 3: Validate artifacts**:

```bash
./scripts/validate-builds.sh
```

**Expected output**:

```text
[OK] CLAP plugin: Found
  CLAP format: Built
```

**Step 4: Check artifact location**:

```bash
# Linux/macOS
ls -la build/ninja/JucePlugin_artefacts/Debug/CLAP/

# Windows
dir build\ninja\JucePlugin_artefacts\Debug\CLAP\
```

**Expected**: `JUCE Project Template Plugin.clap/` directory exists

### Test in DAW

**Reaper (Free)**: Best for testing CLAP on all platforms

1. Download Reaper: https://www.reaper.fm/download.php
2. Install CLAP to system directory (see installation commands above)
3. Launch Reaper
4. Preferences → Plug-ins → CLAP → Rescan
5. Create track → Insert FX → CLAP → Find your plugin
6. Test audio processing, GUI, parameters

**Bitwig Studio (Trial)**: CLAP-native DAW

1. Download Bitwig trial: https://www.bitwig.com/download/
2. Install CLAP to system directory
3. Launch Bitwig
4. Settings → Locations → CLAP → Rescan
5. Create track → Add device → Find your plugin
6. Test modulation, note expression features

## Troubleshooting

### CLAP Target Not Created

**Symptom**: `JucePlugin_CLAP` target doesn't exist

**Solutions**:

1. Check `BUILD_CLAP` is `ON`: `cmake -L build/ninja | grep BUILD_CLAP`
2. Reconfigure: `rm -rf build/ninja && ./scripts/configure-ninja.sh`
3. Check CMake output for clap-juce-extensions fetch errors

### CLAP Plugin Not Found in DAW

**Solutions**:

1. Verify installation path is correct for your OS
2. Check DAW's CLAP search paths in preferences
3. Rescan plugins in DAW
4. Verify CLAP file permissions (readable by all users)
5. Check DAW version supports CLAP (Bitwig 4.3+, Reaper 6.44+)

### Build Errors

**"clap-juce-extensions not found"**:

- Check internet connection (FetchContent requires download)
- Try manual submodule approach instead

**"CLAP_FEATURES unknown"**:

- Update feature list to valid CLAP features
- See: https://github.com/free-audio/clap/blob/main/include/clap/plugin-features.h

### CLAP Plugin Crashes in DAW

**Debug steps**:

1. Test Standalone version first (validates core plugin functionality)
2. Check Debug build for JUCE assertions
3. Use debugger attached to DAW process
4. Review DAW's crash logs
5. Test with minimal plugin (remove custom DSP temporarily)

## Disabling CLAP Support

If you need to disable CLAP temporarily or permanently:

**Option 1: CMake Command Line**:

```bash
cmake -B build/ninja -G Ninja -DBUILD_CLAP=OFF
```

**Option 2: Edit CMakeLists.txt**:

```cmake
option(BUILD_CLAP "Build CLAP plugin format" OFF)  # Changed to OFF
```

**Option 3: Remove CLAP Integration**:

Delete the entire CLAP integration block from CMakeLists.txt.

## Migration to JUCE 9 Native CLAP

When JUCE 9 is released with native CLAP support:

**Step 1: Update JUCE version**:

```cmake
FetchContent_Declare(
    JUCE
    GIT_REPOSITORY https://github.com/juce-framework/JUCE.git
    GIT_TAG 9.0.0  # Or latest JUCE 9 version
)
```

**Step 2: Add CLAP to FORMATS**:

```cmake
if(APPLE)
    set(PLUGIN_FORMATS VST3 Standalone AU CLAP)  # Add CLAP
else()
    set(PLUGIN_FORMATS VST3 Standalone CLAP)  # Add CLAP
endif()
```

**Step 3: Remove clap-juce-extensions integration**:

Delete the entire `BUILD_CLAP` block from CMakeLists.txt.

**Step 4: Test**:

CLAP should now build natively via JUCE without third-party library.

**Compatibility Note**: CLAP ID, parameters, and state should remain compatible if using same `PLUGIN_BUNDLE_ID` value.

## Advanced Configuration

### Custom CLAP Features

Customize plugin classification:

**Effect Plugin**:

```cmake
clap_juce_extensions_plugin(
    TARGET ${PLUGIN_TARGET}
    CLAP_ID "${PLUGIN_BUNDLE_ID}"
    CLAP_FEATURES audio-effect stereo reverb
)
```

**Synthesizer**:

```cmake
clap_juce_extensions_plugin(
    TARGET ${PLUGIN_TARGET}
    CLAP_ID "${PLUGIN_BUNDLE_ID}"
    CLAP_FEATURES instrument synthesizer polyphonic
)
```

**Multi-Effect**:

```cmake
clap_juce_extensions_plugin(
    TARGET ${PLUGIN_TARGET}
    CLAP_ID "${PLUGIN_BUNDLE_ID}"
    CLAP_FEATURES audio-effect stereo delay reverb distortion
)
```

### Extended CLAP Capabilities

For advanced CLAP features (note expressions, polyphonic modulation):

**Update AudioProcessor**:

```cpp
#include "clap-juce-extensions/clap-juce-extensions.h"

class DSPJuceAudioProcessor : public juce::AudioProcessor,
                               public clap_juce_extensions::clap_properties
{
    // Now has is_clap member variable
    // Can detect CLAP wrapper at runtime
};
```

**Benefits**:

- Detect CLAP wrapper: `if (is_clap) { ... }`
- Enable CLAP-specific features
- Support polyphonic modulation
- Access note expression data

See: https://github.com/free-audio/clap-juce-extensions/blob/main/include/clap-juce-extensions/clap-juce-extensions.h

## Summary

Adding CLAP support to the JUCE Project Template requires:

1. 10-20 lines in CMakeLists.txt (conditional integration)
2. Minor updates to validation scripts
3. Documentation additions
4. No source code changes required

Total implementation time: 2-4 hours (including testing)

CLAP builds alongside existing VST3, AU, and Standalone formats with no impact on existing workflows when disabled.
