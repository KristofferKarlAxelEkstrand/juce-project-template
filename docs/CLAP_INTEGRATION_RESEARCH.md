# CLAP Plugin Format Integration Research

Research findings on adding CLAP plugin format support to the JUCE Project Template.

## Executive Summary

**Status**: CLAP integration is feasible using third-party extensions

**Key Findings**:

- JUCE 8.0.10 does NOT include native CLAP support
- JUCE 9 will include native CLAP support (planned for future release)
- Third-party `clap-juce-extensions` library provides working CLAP support for JUCE 6/7/8
- Integration is compatible with existing CMake build system and metadata structure
- CLAP format follows similar artifact patterns to VST3 and AU

**Recommendation**: Integrate `clap-juce-extensions` as an optional feature until JUCE 9 native support is available.

## CLAP Format Overview

### What is CLAP?

**CLAP (CLever Audio Plug-in)** is an open-source audio plugin standard developed by the community as an
alternative to VST, AU, and AAX formats.

**Key Advantages**:

- Open-source and royalty-free (no licensing fees like VST)
- Modern feature set (note expressions, polyphonic modulation, sample-accurate automation)
- Growing DAW support (Bitwig Studio, Reaper, MultitrackStudio)
- Better performance characteristics than older formats
- Extensible architecture for future capabilities

**Extension**: `.clap` (bundle on macOS, folder on Windows/Linux)

**Installation Paths**:

- Windows: `C:\Program Files\Common Files\CLAP\`
- macOS: `/Library/Audio/Plug-Ins/CLAP/`
- Linux: `~/.clap/` or `/usr/lib/clap/`

## JUCE Native CLAP Support Status

### JUCE 8.0.10 (Current)

**Native CLAP Support**: NO

JUCE 8.0.10 does not include built-in CLAP format support. The `juce_add_plugin()` function supports these formats:

- VST3
- AU (Audio Units, macOS only)
- AAX (Avid Audio eXtension, requires AAX SDK)
- Standalone
- Unity (Unity game engine integration)

### JUCE 9 (Future)

**Native CLAP Support**: YES (planned)

According to JUCE roadmap (Q1 2025), JUCE 9 will include native CLAP plugin authoring support. This means:

- CLAP will be a first-class format alongside VST3 and AU
- `juce_add_plugin(FORMATS CLAP)` will work natively
- No third-party extensions required
- Full integration with JUCE plugin infrastructure

**Timeline**: JUCE 9 release date not confirmed (as of October 2025)

## Third-Party Solution: clap-juce-extensions

### Overview

**Project**: <https://github.com/free-audio/clap-juce-extensions>

**License**: MIT (compatible with both open and closed source projects)

**Compatibility**: JUCE 6, 7, and 8

**Maturity**: Production-ready (used by Surge XT, B-Step, Monique, ChowDSP plugins, Dexed)

**CLAP Version**: 1.0 (compatible with Bitwig Studio 4.3+, Reaper, MultitrackStudio)

### How It Works

The library uses a "forkless" approach that adds CLAP support without forking JUCE:

1. Wraps existing JUCE `AudioProcessor` to create CLAP plugin
2. Preserves all JUCE plugin code (VST3, AU, Standalone continue working)
3. Adds CLAP as additional format alongside existing formats
4. Uses standard JUCE APIs (parameters, state, processing)

### Integration Method

**CMake Integration** (recommended for this template):

```cmake
# 1. Add clap-juce-extensions via FetchContent or submodule
include(FetchContent)
FetchContent_Declare(
    clap-juce-extensions
    GIT_REPOSITORY https://github.com/free-audio/clap-juce-extensions.git
    GIT_TAG main
    GIT_SHALLOW TRUE
)
FetchContent_MakeAvailable(clap-juce-extensions)

# 2. Create JUCE plugin as normal
juce_add_plugin(${PLUGIN_TARGET}
    FORMATS VST3 AU Standalone
    # ... other parameters
)

# 3. Add CLAP format via clap-juce-extensions
clap_juce_extensions_plugin(
    TARGET ${PLUGIN_TARGET}
    CLAP_ID "com.mycompany.myplugin"
    CLAP_FEATURES instrument synthesizer
)
```

This creates a new target `${PLUGIN_TARGET}_CLAP` that builds the CLAP plugin.

## Compatibility Assessment

### CMake Metadata Integration

**Compatibility**: EXCELLENT ✓

The existing metadata system in `CMakeLists.txt` is fully compatible:

```cmake
# Existing metadata (no changes needed)
set(PLUGIN_NAME "JUCE Project Template Plugin")
set(PLUGIN_TARGET "JucePlugin")
set(PLUGIN_VERSION "${PROJECT_VERSION}")
set(PLUGIN_COMPANY_NAME "MyCompany")
set(PLUGIN_BUNDLE_ID "com.mycompany.juceplugin")

# CLAP-specific additions
clap_juce_extensions_plugin(
    TARGET ${PLUGIN_TARGET}
    CLAP_ID "${PLUGIN_BUNDLE_ID}"  # Use existing bundle ID
    CLAP_FEATURES instrument synthesizer
    CLAP_MANUAL_URL "${PLUGIN_COMPANY_WEBSITE}"
    CLAP_SUPPORT_URL "${PLUGIN_COMPANY_WEBSITE}"
)
```

**Metadata Mapping**:

- `PLUGIN_BUNDLE_ID` → `CLAP_ID` (reverse DNS format already used)
- `PLUGIN_NAME` → CLAP plugin name (automatic from JUCE)
- `PLUGIN_VERSION` → CLAP version (automatic from JUCE)
- `PLUGIN_COMPANY_NAME` → CLAP manufacturer (automatic from JUCE)

### Build System Integration

**Compatibility**: EXCELLENT ✓

**CMake Presets**: No changes required

- Existing presets (default, vs2022, ninja, xcode) work unchanged
- CLAP target builds alongside other formats
- No additional build configuration needed

**Build Scripts**: Minor additions needed

- `scripts/configure-ninja.sh` - Works unchanged
- `scripts/build-ninja.sh` - Works unchanged
- CLAP target builds with standard `cmake --build` command

**VS Code Tasks**: Minor additions recommended

- Add task for building CLAP format specifically
- Update "Build All" task to include CLAP

### Artifact Layout

**Compatibility**: EXCELLENT ✓

CLAP follows same artifact pattern as VST3 and AU:

**Current Structure**:

```text
build/ninja/JucePlugin_artefacts/Debug/
├── VST3/
│   └── JUCE Project Template Plugin.vst3/
├── AU/
│   └── JUCE Project Template Plugin.component/
└── Standalone/
    └── JUCE Project Template Plugin.exe
```

**With CLAP Added**:

```text
build/ninja/JucePlugin_artefacts/Debug/
├── VST3/
│   └── JUCE Project Template Plugin.vst3/
├── AU/
│   └── JUCE Project Template Plugin.component/
├── CLAP/                                      # New
│   └── JUCE Project Template Plugin.clap/    # New
└── Standalone/
    └── JUCE Project Template Plugin.exe
```

**Artifact Validation**: `scripts/validate-builds.sh` requires updates to check CLAP artifacts.

### CI/CD Integration

**Compatibility**: EXCELLENT ✓

**GitHub Actions**: Minor workflow updates needed

- Add CLAP to artifact collection step
- Include CLAP in release assets
- No changes to matrix strategy (CLAP builds on all platforms)

**Artifact Naming**: Follows existing pattern

- Windows: `JucePlugin-0.0.1-windows-CLAP.zip`
- macOS: `JucePlugin-0.0.1-macos-CLAP.zip`
- Linux: `JucePlugin-0.0.1-linux-CLAP.tar.gz`

### Single-Source Versioning

**Compatibility**: EXCELLENT ✓

CLAP version information flows from `project(VERSION)` through JUCE to CLAP wrapper automatically:

```cmake
project(JuceProject VERSION 0.0.1)  # Single source of truth
set(PLUGIN_VERSION "${PROJECT_VERSION}")

# Flows to JUCE plugin
juce_add_plugin(${PLUGIN_TARGET}
    VERSION ${PLUGIN_VERSION}
    # ...
)

# Automatically used by CLAP wrapper (no explicit VERSION parameter needed)
clap_juce_extensions_plugin(TARGET ${PLUGIN_TARGET} ...)
```

## Installation and Testing

### Installation Paths

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

### DAW Compatibility

**CLAP-Compatible DAWs**:

- Bitwig Studio 4.3+ (full support, CLAP-native)
- Reaper 6.44+ (full support)
- MultitrackStudio (full support)
- FL Studio 21.2+ (beta CLAP support)

**Validation**:

CLAP has simpler validation than AU (no `auval` equivalent yet). Test by:

1. Installing CLAP to system directory
2. Launching DAW
3. Rescanning plugins
4. Loading plugin on track
5. Testing audio processing and GUI

## Implementation Recommendations

### Recommended Approach

#### Option A: Conditional CLAP Support (RECOMMENDED)

Add CLAP as an optional feature that can be enabled/disabled:

```cmake
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
        CLAP_FEATURES instrument synthesizer
    )
    
    message(STATUS "Building CLAP format: YES")
else()
    message(STATUS "Building CLAP format: NO (BUILD_CLAP=OFF)")
endif()
```

**Benefits**:

- Users can opt-in/opt-out of CLAP
- No impact on existing builds if disabled
- Future-proof (can switch to JUCE 9 native CLAP easily)
- Minimal changes to existing infrastructure

#### Option B: Submodule Approach

Use git submodule instead of FetchContent:

```bash
git submodule add -b main \
    https://github.com/free-audio/clap-juce-extensions.git \
    third_party/clap-juce-extensions
```

```cmake
if(EXISTS "${CMAKE_SOURCE_DIR}/third_party/clap-juce-extensions/CMakeLists.txt")
    add_subdirectory(third_party/clap-juce-extensions EXCLUDE_FROM_ALL)
    clap_juce_extensions_plugin(...)
endif()
```

**Benefits**: Matches existing JUCE submodule pattern

**Drawbacks**: Requires users to `git submodule update --init --recursive`

### Migration Path to JUCE 9

When JUCE 9 is released with native CLAP support, migration is straightforward:

**Before (JUCE 8 + clap-juce-extensions)**:

```cmake
juce_add_plugin(${PLUGIN_TARGET}
    FORMATS VST3 AU Standalone
)
clap_juce_extensions_plugin(TARGET ${PLUGIN_TARGET} CLAP_ID "...")
```

**After (JUCE 9 native)**:

```cmake
juce_add_plugin(${PLUGIN_TARGET}
    FORMATS VST3 AU Standalone CLAP  # Just add CLAP here
)
```

**Compatibility Considerations**:

- CLAP ID should remain the same (`PLUGIN_BUNDLE_ID`)
- Parameter IDs remain compatible (both use JUCE hashing)
- State save/load remains compatible (uses JUCE's `setStateInformation`)

## Required Changes Summary

### Critical Changes

1. **CMakeLists.txt**: Add CLAP integration code (10-20 lines)
2. **scripts/validate-builds.sh**: Add CLAP artifact validation
3. **docs/PLUGIN_FORMATS.md**: Add CLAP documentation section

### Optional Changes

1. **.vscode/tasks.json**: Add CLAP build task
2. **.github/workflows/*.yml**: Include CLAP in CI artifacts
3. **README.md**: Mention CLAP support

### No Changes Required

1. Source code (`src/*.cpp`, `src/*.h`) - No changes needed
2. CMakePresets.json - Works unchanged
3. Build scripts - Work unchanged
4. Plugin metadata variables - Compatible as-is

## Known Limitations

### clap-juce-extensions Limitations

1. **AudioProcessor::WrapperType**: Returns `wrapperType_Undefined` for CLAP
   - Workaround: Use `clap_juce_extensions::clap_properties` base class
2. **Some JUCE features untested**: Particularly advanced parameter features
3. **No CLAP hosting**: Library is for plugin authoring only, not hosting
4. **Community support**: Not officially supported by JUCE team

### CLAP Format Limitations

1. **Limited DAW support**: Not all DAWs support CLAP yet
2. **New format**: Less mature than VST3/AU (but actively developed)
3. **No installer standards**: Each DAW has different CLAP scan paths

## Testing Strategy

### Development Testing

1. Build CLAP alongside existing formats
2. Test standalone version first (validates core functionality)
3. Install CLAP to system directory
4. Test in CLAP-compatible DAW (Reaper recommended for free testing)
5. Verify parameter automation
6. Test preset save/load
7. Verify GUI scaling and resizing

### CI/CD Testing

1. Add CLAP to build matrix
2. Validate CLAP artifacts exist
3. Package CLAP in release assets
4. Add CLAP-specific installation instructions to release notes

## Cost-Benefit Analysis

### Benefits

- **Modern format**: CLAP offers technical advantages over VST3/AU
- **No licensing**: Free and open-source (unlike VST3 trademark restrictions)
- **Growing adoption**: DAW support increasing (Bitwig, Reaper, FL Studio)
- **Future-proof**: JUCE 9 will support natively
- **Minimal cost**: 10-20 lines of CMake, works alongside existing formats

### Costs

- **Additional testing**: One more format to validate
- **Documentation**: Update guides to cover CLAP
- **Support**: Users may ask questions about CLAP-specific issues
- **Build time**: Slightly longer builds (additional target)

### Recommendation

Recommendation: Integrate CLAP support

- Low implementation cost (few hours of work)
- High value for users targeting modern DAWs
- Positions template as forward-looking
- Easy to maintain until JUCE 9 migration

## Next Steps

### Phase 1: Basic Integration (2-3 hours)

1. Add `clap-juce-extensions` to CMakeLists.txt with `BUILD_CLAP` option
2. Update `scripts/validate-builds.sh` to check CLAP artifacts
3. Test build on all platforms

### Phase 2: Documentation (2-3 hours)

1. Add CLAP section to `docs/PLUGIN_FORMATS.md`
2. Update README.md to mention CLAP support
3. Add CLAP installation instructions
4. Document `BUILD_CLAP` CMake option

### Phase 3: CI/CD Integration (1-2 hours)

1. Update GitHub Actions workflows to build CLAP
2. Include CLAP artifacts in releases
3. Test cross-platform CLAP builds

### Phase 4: Testing (2-4 hours)

1. Test CLAP builds on Windows, macOS, Linux
2. Install and test in Reaper/Bitwig
3. Verify parameter persistence
4. Test GUI in CLAP host

**Total Estimated Effort**: 8-12 hours

## References

### Primary Sources

- CLAP Specification: <https://github.com/free-audio/clap>
- clap-juce-extensions: <https://github.com/free-audio/clap-juce-extensions>
- JUCE Roadmap Q1 2025: <https://juce.com/blog/juce-roadmap-update-q1-2025/>
- JUCE CMake API: <https://github.com/juce-framework/JUCE/blob/master/docs/CMake%20API.md>

### Example Implementations

- Surge XT Synthesizer: <https://github.com/surge-synthesizer/surge>
- ChowDSP Plugins: <https://github.com/Chowdhury-DSP>
- Dexed: <https://github.com/asb2m10/dexed>

### Community Resources

- CLAP Forum: <https://forum.juce.com/t/fr-support-clap-for-plugins-host-client/51860>
- CLAP Developer Guide: <https://cleveraudio.org/developers-getting-started/>
- CLAP Database: <https://clapdb.tech/>

## Conclusion

CLAP integration is feasible and recommended for this JUCE project template. The `clap-juce-extensions`
library provides production-ready CLAP support that integrates seamlessly with the existing CMake infrastructure,
metadata system, and build workflows. Implementation effort is low (8-12 hours total), and the benefits include
supporting a modern, open-source plugin format with growing DAW adoption. The migration path to JUCE 9 native
CLAP support is straightforward when available.
