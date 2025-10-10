# Plugin Metadata Centralization - Refactoring Plan

## Objective

Create a single source of truth for plugin metadata to enable easy creation
of new plugins with consistent naming across all build artifacts, scripts,
and documentation.

## Current Problems

### 1. Hardcoded Values Scattered Across Files

- **CMakeLists.txt**: Target name, company, product name, bundle ID
- **Scripts**: `validate-builds.sh`, `test-builds.sh` have hardcoded names
- **Source Code**: `MainComponent.h` and `MainComponent.cpp` have hardcoded strings
- **Workflows**: Release workflow has hardcoded ZIP naming
- **Documentation**: Multiple files reference specific plugin names

### 2. Manual Synchronization Required

When creating a new plugin, you must manually update 10+ locations, risking inconsistencies.

### 3. Customer-Facing Issues

- Inconsistent branding if names don't match
- ZIP file names don't reflect product metadata
- Plugin display names may differ from binary names

## Recommended Solution: CMake-Based Single Source of Truth

### Why CMakeLists.txt Should Be The Source?

**Industry Standard**:

- JUCE documentation recommends this approach
- Used by commercial plugin developers (FabFilter, U-He, etc.)
- CMake properties automatically propagate to build system

**Technical Benefits**:

- CMake variables available to scripts via `cmake -L` or custom exports
- JUCE macros (`JucePlugin_Name`, `JucePlugin_Manufacturer`, etc.) auto-generated
- Platform-specific build configurations inherit metadata automatically
- Single `juce_add_plugin()` call defines everything

**Maintainability**:

- One file to update when creating new plugins
- Type-safe (CMake will error on invalid configurations)
- Version controlled with source code
- No additional configuration file format to learn

## Implementation Phases

### Phase 1: Enhanced CMakeLists.txt Structure ✅

**File**: `CMakeLists.txt`

**Changes**:

1. Move metadata to top-level variables (before `juce_add_plugin()`)
2. Add computed properties (bundle ID from company + target)
3. Add validation checks
4. Export metadata to a file for scripts to consume

```cmake
# =============================================================================
# PLUGIN METADATA - Single Source of Truth
# =============================================================================
# Edit these values to create a new plugin. All other files will automatically
# use these values.

set(PLUGIN_NAME "DSP-JUCE Plugin")  # User-facing product name
set(PLUGIN_TARGET "DSPJucePlugin")   # CMake target name (no spaces)
set(PLUGIN_VERSION "1.0.0")
set(PLUGIN_COMPANY_NAME "MyCompany")
set(PLUGIN_COMPANY_WEBSITE "https://www.mycompany.com")
set(PLUGIN_DESCRIPTION "Advanced audio processing plugin")

# Manufacturer codes (must follow JUCE/AU requirements)
set(PLUGIN_MANUFACTURER_CODE "Mcmp")  # 4 chars, at least one uppercase
set(PLUGIN_CODE "Dsp1")                # 4 chars, exactly one uppercase

# Auto-compute bundle ID (reverse-DNS format)
string(TOLOWER "${PLUGIN_COMPANY_NAME}" COMPANY_LOWER)
string(REPLACE " " "" COMPANY_LOWER "${COMPANY_LOWER}")
string(TOLOWER "${PLUGIN_TARGET}" TARGET_LOWER)
set(PLUGIN_BUNDLE_ID "com.${COMPANY_LOWER}.${TARGET_LOWER}")

# =============================================================================
```

**Export Metadata** for shell scripts:

```cmake
# Export metadata to file for build scripts
file(WRITE "${CMAKE_BINARY_DIR}/plugin_metadata.sh"
    "#!/bin/bash\n"
    "# Auto-generated plugin metadata - do not edit\n"
    "export PROJECT_NAME_TARGET=\"${PLUGIN_TARGET}\"\n"
    "export PROJECT_NAME_PRODUCT=\"${PLUGIN_NAME}\"\n"
    "export PROJECT_VERSION=\"${PLUGIN_VERSION}\"\n"
    "export PROJECT_COMPANY=\"${PLUGIN_COMPANY_NAME}\"\n"
)
```

### Phase 2: Update Build Scripts ✅

**File**: `scripts/validate-builds.sh`

**Changes**:

```bash
# Source metadata from CMake-generated file
if [ -f "$PROJECT_ROOT/build/plugin_metadata.sh" ]; then
    source "$PROJECT_ROOT/build/plugin_metadata.sh"
else
    # Fallback for when CMake hasn't run yet
    echo "⚠️  Warning: CMake metadata not found. Run CMake configure first."
    exit 1
fi

# Now use the variables
PROJECT_NAME_TARGET="${PROJECT_NAME_TARGET:-DSPJucePlugin}"
PROJECT_NAME_PRODUCT="${PROJECT_NAME_PRODUCT:-DSP-JUCE Plugin}"
```

### Phase 3: Update Source Code ✅

**File**: `src/MainComponent.h`

**Changes**:

```cpp
// Use JUCE-generated macro instead of hardcoded string
const juce::String getName() const override { 
    return JucePlugin_Name;  // Auto-generated from CMakeLists.txt
}
```

**File**: `src/MainComponent.cpp`

**Changes**:

```cpp
// Use JUCE-generated macro for XML tag
juce::XmlElement xml(JucePlugin_Name);

// In setStateInformation()
if (xmlState.get() != nullptr && xmlState->hasTagName(JucePlugin_Name)) {
```

### Phase 4: Update CI/CD Workflows ✅

**File**: `.github/workflows/release.yml`

**Changes**:

```yaml
env:
  # Read from CMake configuration
  ZIP_NAME: "DSP-JUCE-Plugin-${{ github.ref_name }}-${{ matrix.platform_id }}.zip"

steps:
  - name: Extract plugin metadata
    run: |
      cmake -L build/${{ matrix.build_path }} | grep PROJECT_NAME > metadata.txt
      source build/plugin_metadata.sh
      echo "PLUGIN_NAME=$PROJECT_NAME_PRODUCT" >> $GITHUB_ENV
      
  - name: Archive plugin artifacts
    run: |
      ZIP_NAME="${PLUGIN_NAME}-${{ github.ref_name }}-${{ matrix.platform_id }}.zip"
      cd "$ARTIFACT_DIR"
      zip -r "$GITHUB_WORKSPACE/$ZIP_NAME" VST3 Standalone
```

### Phase 5: Update Documentation ✅

**Files to Update**:

- `README.md`: Use variables or note to check CMakeLists.txt
- `BUILD.md`: Reference CMakeLists.txt as configuration source
- `docs/cmake/basics-cmake.md`: Document the metadata variables

**Approach**: Add a note at the top:

```markdown
> **Plugin Configuration**: All plugin metadata (name, version, company) is 
> defined in `CMakeLists.txt`. See the "PLUGIN METADATA" section at the top 
> of the file.
```

## Implementation Checklist

### Core Configuration

- [ ] Add metadata variables to top of `CMakeLists.txt`
- [ ] Update `juce_add_plugin()` to use variables
- [ ] Add metadata export to shell script file
- [ ] Add validation for manufacturer codes

### Build Scripts

- [ ] Update `scripts/validate-builds.sh` to source metadata
- [ ] Update `scripts/test-builds.sh` (or remove if obsolete)
- [ ] Test scripts work without hardcoded values

### Source Code

- [ ] Replace hardcoded strings in `MainComponent.h`
- [ ] Replace hardcoded strings in `MainComponent.cpp`
- [ ] Verify `JucePlugin_*` macros are available

### CI/CD

- [ ] Update `.github/workflows/release.yml` to use metadata
- [ ] Update `.github/workflows/ci.yml` if needed
- [ ] Test workflow with new metadata system

### Documentation

- [ ] Update `README.md` with configuration reference
- [ ] Update `BUILD.md` with new structure
- [ ] Add `CREATING_NEW_PLUGIN.md` guide
- [ ] Update inline documentation

### Testing

- [ ] Clean build to verify all metadata propagates
- [ ] Run validation scripts
- [ ] Check VST3/AU plugin names in DAW
- [ ] Verify ZIP file naming in release workflow
- [ ] Test on all platforms (Windows, macOS, Linux)

## Benefits of This Approach

### For Plugin Development

✅ **Single Edit Point**: Change plugin name/company in one place
✅ **Type Safety**: CMake validates configuration at configure time
✅ **Automatic Propagation**: Build outputs, scripts, source code all sync
✅ **Industry Standard**: Matches professional JUCE development practices

### For Customers/Users

✅ **Consistent Branding**: Plugin name matches across DAW, files, docs
✅ **Professional Packaging**: ZIP files named correctly
✅ **Clear Versioning**: Version number consistent everywhere

### For Maintenance

✅ **Easy Template Creation**: Copy CMakeLists.txt, edit 5 variables, done
✅ **Reduced Errors**: No manual synchronization needed
✅ **Self-Documenting**: Configuration is in build file where it belongs

## Example: Creating a New Plugin

With this system, creating a new plugin is simple:

1. **Edit `CMakeLists.txt` metadata section** (5 variables):

   ```cmake
   set(PLUGIN_NAME "Super Reverb")
   set(PLUGIN_TARGET "SuperReverb")
   set(PLUGIN_VERSION "1.0.0")
   set(PLUGIN_COMPANY_NAME "AudioTech")
   set(PLUGIN_MANUFACTURER_CODE "Atec")
   set(PLUGIN_CODE "Srv1")
   ```

2. **Run CMake** (metadata automatically exports):

   ```bash
   cmake --preset=vs2022
   ```

3. **Build** (all outputs use new metadata):

   ```bash
   cmake --build --preset=vs2022-release
   ```

4. **Result**:
   - VST3: `SuperReverb.vst3`
   - Standalone: `Super Reverb.exe`
   - Build directory: `SuperReverb_artefacts/`
   - Bundle ID: `com.audiotech.superreverb`
   - ZIP file: `SuperReverb-v1.0.0-windows.zip`
   - Plugin display in DAW: "Super Reverb by AudioTech"

## Migration Strategy

### Option A: Immediate Full Refactor (Recommended)

Do all phases in one PR to avoid inconsistencies

### Option B: Gradual Migration

1. Add variables to CMakeLists.txt (backward compatible)
2. Update scripts to use metadata file
3. Update source code to use macros
4. Update workflows last

## Next Steps

1. Review and approve this plan
2. Create implementation branch
3. Execute phases 1-5
4. Test thoroughly on all platforms
5. Document the new system
6. Merge to develop

## Questions to Consider

1. Should we add a `cmake/PluginConfig.cmake` module for very large projects with multiple plugins?
   - **Answer**: Not needed for single-plugin projects. Keep it in main CMakeLists.txt for simplicity.

2. Should manufacturer codes be validated automatically?
   - **Answer**: Yes, add CMake checks for 4-character codes and uppercase requirements.

3. How to handle version bumping?
   - **Answer**: Edit `PLUGIN_VERSION` in CMakeLists.txt. Consider adding a VERSION.txt file if needed.

4. Should we support loading config from external file?
   - **Answer**: No for now. CMakeLists.txt is standard and sufficient.

## References

- [JUCE CMake API Documentation](https://github.com/juce-framework/JUCE/blob/master/docs/CMake%20API.md)
- [JUCE Plugin Format Guidelines](https://docs.juce.com/master/tutorial_create_projucer_basic_plugin.html)
- [CMake Best Practices](https://cmake.org/cmake/help/latest/guide/tutorial/index.html)
