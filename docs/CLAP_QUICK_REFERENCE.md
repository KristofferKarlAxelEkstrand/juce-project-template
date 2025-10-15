# CLAP Support Quick Reference

Quick reference guide for CLAP plugin format integration in JUCE Project Template.

## What is CLAP?

**CLAP (CLever Audio Plug-in)** - Modern, open-source audio plugin format

**Advantages over VST3/AU**:

- Open-source and royalty-free
- Advanced features (note expressions, polyphonic modulation)
- Better performance characteristics
- Growing DAW support

## Current Status

**JUCE 8.0.10**: NO native CLAP support (requires third-party `clap-juce-extensions`)

**JUCE 9**: NATIVE CLAP support (planned, release date TBD)

**Recommendation**: Use `clap-juce-extensions` now, migrate to JUCE 9 when available

## Quick Integration (5 Minutes)

### Add to CMakeLists.txt

Insert after `juce_add_plugin()` block:

```cmake
# CLAP Plugin Format
option(BUILD_CLAP "Build CLAP plugin format" ON)

if(BUILD_CLAP)
    include(FetchContent)
    FetchContent_Declare(
        clap-juce-extensions
        GIT_REPOSITORY https://github.com/free-audio/clap-juce-extensions.git
        GIT_TAG main
        GIT_SHALLOW TRUE
    )
    FetchContent_MakeAvailable(clap-juce-extensions)
    
    clap_juce_extensions_plugin(
        TARGET ${PLUGIN_TARGET}
        CLAP_ID "${PLUGIN_BUNDLE_ID}"
        CLAP_FEATURES instrument synthesizer  # Customize based on plugin type
    )
endif()
```

### Build

```bash
# Reconfigure
cmake -B build/ninja -G Ninja

# Build (CLAP included automatically)
cmake --build build/ninja
```

### Verify

```bash
# Check artifacts
ls build/ninja/JucePlugin_artefacts/Debug/CLAP/
```

## CLAP Features Configuration

Set `CLAP_FEATURES` based on plugin type:

**Instrument/Synthesizer**:

```cmake
CLAP_FEATURES instrument synthesizer
```

**Effect Plugin**:

```cmake
CLAP_FEATURES audio-effect stereo reverb
```

**Modulation Effect**:

```cmake
CLAP_FEATURES audio-effect modulation chorus flanger
```

**Dynamics Processor**:

```cmake
CLAP_FEATURES audio-effect dynamics compressor limiter
```

**Analyzer/Utility**:

```cmake
CLAP_FEATURES utility analyzer
```

Full feature list: https://github.com/free-audio/clap/blob/main/include/clap/plugin-features.h

## Installation Paths

**Windows**: `C:\Program Files\Common Files\CLAP\`

**macOS**: `/Library/Audio/Plug-Ins/CLAP/`

**Linux**: `~/.clap/` or `/usr/lib/clap/`

## Testing DAWs

**Free Options**:

- Reaper 6.44+ (free evaluation, cross-platform)
- Bitwig Studio (free trial, CLAP-native)

**Paid Options**:

- Bitwig Studio 4.3+ (full CLAP support)
- FL Studio 21.2+ (beta CLAP support)
- MultitrackStudio (full support)

## Common Issues

### CLAP Not Building

**Check BUILD_CLAP option**:

```bash
cmake -L build/ninja | grep BUILD_CLAP
```

**Reconfigure if needed**:

```bash
cmake -B build/ninja -G Ninja -DBUILD_CLAP=ON
```

### CLAP Not Found in DAW

1. Install to correct system path
2. Check DAW preferences → CLAP scan paths
3. Rescan plugins
4. Verify DAW version supports CLAP

### Build Errors

**Internet connection required**: FetchContent downloads clap-juce-extensions during configure

**Alternative**: Use git submodule approach (see CLAP_IMPLEMENTATION_GUIDE.md)

## Disable CLAP

**Temporary**:

```bash
cmake -B build/ninja -G Ninja -DBUILD_CLAP=OFF
```

**Permanent**: Edit CMakeLists.txt:

```cmake
option(BUILD_CLAP "Build CLAP plugin format" OFF)
```

## Migration to JUCE 9

When JUCE 9 is released:

**Before (JUCE 8 + clap-juce-extensions)**:

```cmake
juce_add_plugin(${PLUGIN_TARGET} FORMATS VST3 AU Standalone)
clap_juce_extensions_plugin(TARGET ${PLUGIN_TARGET} ...)
```

**After (JUCE 9 native)**:

```cmake
juce_add_plugin(${PLUGIN_TARGET} FORMATS VST3 AU Standalone CLAP)
# Remove clap_juce_extensions_plugin() call
```

## Advanced Features

### Detect CLAP at Runtime

```cpp
#include "clap-juce-extensions/clap-juce-extensions.h"

class MyProcessor : public juce::AudioProcessor,
                    public clap_juce_extensions::clap_properties
{
    void processBlock(...)
    {
        if (is_clap)
        {
            // CLAP-specific processing
        }
    }
};
```

### Sample-Accurate Automation

```cmake
clap_juce_extensions_plugin(
    TARGET ${PLUGIN_TARGET}
    CLAP_ID "${PLUGIN_BUNDLE_ID}"
    CLAP_FEATURES instrument synthesizer
    CLAP_PROCESS_EVENTS_RESOLUTION_SAMPLES 32  # 32-sample blocks
)
```

## Resources

**Documentation**:

- CLAP_INTEGRATION_RESEARCH.md - Full research findings
- CLAP_IMPLEMENTATION_GUIDE.md - Detailed implementation steps
- docs/PLUGIN_FORMATS.md - Plugin format comparisons

**External Links**:

- clap-juce-extensions: https://github.com/free-audio/clap-juce-extensions
- CLAP Specification: https://github.com/free-audio/clap
- CLAP Developer Guide: https://cleveraudio.org/developers-getting-started/

**Example Projects**:

- Surge XT: https://github.com/surge-synthesizer/surge
- ChowDSP: https://github.com/Chowdhury-DSP

## Summary

**Time to Integrate**: 5-10 minutes

**Code Changes**: 10-20 lines in CMakeLists.txt

**Build Impact**: Minimal (optional format, builds in parallel)

**Benefits**: Modern plugin format, growing DAW support, future-proof

**Recommendation**: Add CLAP support using `BUILD_CLAP=ON` option
