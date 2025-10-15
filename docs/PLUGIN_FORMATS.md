# Plugin Formats Guide

Understanding VST3, AU, and Standalone formats built by this template.

## Overview

This template builds your plugin in multiple formats from a single codebase. Each format serves different use cases and platforms.

## Plugin Formats

### VST3 (Virtual Studio Technology 3)

**Description**: Industry-standard plugin format by Steinberg

**Platforms**:

- Windows: Full support
- macOS: Full support  
- Linux: Full support

**Extension**:

- Windows: `.vst3` (folder containing DLL)
- macOS: `.vst3` (bundle)
- Linux: `.vst3` (folder containing SO)

**Installation Path**:

- Windows: `C:\Program Files\Common Files\VST3\`
- macOS: `/Library/Audio/Plug-Ins/VST3/`
- Linux: `~/.vst3/` or `/usr/lib/vst3/`

**Build Output**:

```text
build/ninja/JucePlugin_artefacts/Debug/VST3/Your Plugin.vst3/
├── Contents/              # macOS only
│   ├── Info.plist
│   └── x86_64/
│       └── Your Plugin.vst3
└── Your Plugin.vst3       # Windows/Linux: DLL/SO directly in folder
```

**Compatibility**: Most DAWs support VST3 (Cubase, FL Studio, Reaper, Studio One, etc.)

### AU (Audio Units)

**Description**: Apple's native plugin format

**Platforms**:

- macOS: Full support
- Windows: Not supported
- Linux: Not supported

**Extension**: `.component` (bundle)

**Installation Path**: `/Library/Audio/Plug-Ins/Components/`

**Build Output**:

```text
build/ninja/JucePlugin_artefacts/Debug/AU/Your Plugin.component/
└── Contents/
    ├── Info.plist
    ├── PkgInfo
    └── MacOS/
        └── Your Plugin
```

**Compatibility**: macOS DAWs (Logic Pro, GarageBand, Ableton Live, etc.)

**Note**: This template automatically builds AU on macOS. No configuration needed.

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
Enable/disable with `BUILD_CLAP=ON/OFF` CMake option (enabled by default).

### Standalone

**Description**: Independent application (not a plugin)

**Platforms**:

- Windows: Full support (executable)
- macOS: Full support (app bundle)
- Linux: Full support (executable)

**Extension**:

- Windows: `.exe`
- macOS: `.app` (bundle)
- Linux: No extension (executable)

**Build Output**:

**Windows**:

```text
build/ninja/JucePlugin_artefacts/Debug/Standalone/Your Plugin.exe
```

**macOS**:

```text
build/ninja/JucePlugin_artefacts/Debug/Standalone/Your Plugin.app/
└── Contents/
    ├── Info.plist
    ├── PkgInfo
    ├── MacOS/
    │   └── Your Plugin
    └── Resources/
```

**Linux**:

```text
build/ninja/JucePlugin_artefacts/Debug/Standalone/Your Plugin
```

**Use Cases**:

- Testing during development (faster than loading in DAW)
- Distribution to users without DAW requirement
- Live performance tools
- Educational demonstrations

## Format Comparison

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
| Multiple instances | DAW manages | DAW manages | DAW manages | Manual launch |

## Build Configuration

### Format Selection

Formats are configured in `CMakeLists.txt`:

```cmake
# Define plugin formats based on platform
if(APPLE)
    set(PLUGIN_FORMATS VST3 Standalone AU)
else()
    set(PLUGIN_FORMATS VST3 Standalone)
endif()
```

**Default behavior**:

- Windows/Linux: VST3 + Standalone + CLAP
- macOS: VST3 + AU + Standalone + CLAP

**CLAP format**: Enabled by default. Disable with `BUILD_CLAP=OFF`:

```bash
# Disable CLAP
cmake -B build/ninja -G Ninja -DBUILD_CLAP=OFF

# Enable CLAP (default)
cmake -B build/ninja -G Ninja -DBUILD_CLAP=ON
```

### Customizing Formats

To build only specific formats, edit `CMakeLists.txt`:

**VST3 only**:

```cmake
set(PLUGIN_FORMATS VST3)
```

**Standalone only** (for testing):

```cmake
set(PLUGIN_FORMATS Standalone)
```

**All formats** (macOS):

```cmake
set(PLUGIN_FORMATS VST3 AU Standalone)
```

After changing formats:

1. Reconfigure CMake: `./scripts/configure-ninja.sh`
2. Rebuild: `./scripts/build-ninja.sh`

## Installation for Testing

### Installing VST3

**Windows**:

```cmd
xcopy /E /I "build\ninja\JucePlugin_artefacts\Debug\VST3\Your Plugin.vst3" ^
      "C:\Program Files\Common Files\VST3\Your Plugin.vst3"
```

**macOS**:

```bash
cp -r "build/ninja/JucePlugin_artefacts/Debug/VST3/Your Plugin.vst3" \
      "/Library/Audio/Plug-Ins/VST3/"
```

**Linux**:

```bash
cp -r "build/ninja/JucePlugin_artefacts/Debug/VST3/Your Plugin.vst3" \
      "$HOME/.vst3/"
```

After copying, rescan plugins in your DAW.

### Installing AU (macOS)

```bash
cp -r "build/ninja/JucePlugin_artefacts/Debug/AU/Your Plugin.component" \
      "/Library/Audio/Plug-Ins/Components/"
```

**Note**: AU validation may take a few seconds. Check Console.app for validation messages.

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

### Running Standalone

**No installation needed**. Run directly:

**Windows**:

```cmd
build\ninja\JucePlugin_artefacts\Debug\Standalone\Your Plugin.exe
```

**macOS**:

```bash
open "build/ninja/JucePlugin_artefacts/Debug/Standalone/Your Plugin.app"
```

**Linux**:

```bash
./build/ninja/JucePlugin_artefacts/Debug/Standalone/Your\ Plugin
```

## Plugin Metadata

All formats use the same metadata from `CMakeLists.txt`:

```cmake
set(PLUGIN_NAME "Your Plugin Name")         # Product name
set(PLUGIN_VERSION "1.0.0")                 # Version
set(PLUGIN_COMPANY_NAME "Your Company")     # Manufacturer
set(PLUGIN_MANUFACTURER_CODE "Mcmp")        # 4-char code
set(PLUGIN_CODE "Plug")                     # 4-char unique code
```

**Important**: Change `PLUGIN_MANUFACTURER_CODE` and `PLUGIN_CODE` to unique values.

### Metadata Propagation

Metadata flows to:

**VST3**:

- Plugin name displayed in DAW
- Version shown in plugin info
- Manufacturer name in plugin browser

**AU**:

- Bundle identifier: `com.yourcompany.yourplugin`
- Info.plist metadata
- Audio Component description

**Standalone**:

- Application title
- About dialog (if implemented)
- System window title

## Testing in DAWs

### VST3 Testing

**Recommended DAWs**:

- Reaper (free evaluation, cross-platform)
- Tracktion Waveform Free (free, cross-platform)
- Cakewalk by BandLab (free, Windows)

**Steps**:

1. Install VST3 to system directory
2. Launch DAW
3. Rescan plugins (varies by DAW)
4. Insert plugin on track
5. Test audio processing and GUI

### AU Testing (macOS)

**Recommended DAWs**:

- GarageBand (free, included with macOS)
- Logic Pro (paid)
- Ableton Live (paid, AU support)

**Steps**:

1. Install AU to `/Library/Audio/Plug-Ins/Components/`
2. Launch DAW
3. AU validation happens automatically
4. Find plugin in AU instruments/effects
5. Insert and test

### Standalone Testing

**Quick test**:

1. Launch standalone app
2. Select audio device in settings
3. Test audio input/output
4. Test GUI controls
5. Verify parameter changes affect audio

## Troubleshooting

### Plugin Not Found in DAW

**VST3**:

1. Verify installation path is correct
2. Check DAW's VST3 search paths in preferences
3. Rescan plugins in DAW
4. Check file permissions (should be readable by all users)

**AU**:

1. Check Console.app for AU validation errors
2. Run AU validation: `auval -v aufx Plug Mcmp` (replace codes)
3. Verify Info.plist is correct
4. Reboot (forces AU cache refresh)

### Plugin Crashes on Load

**Debug**:

1. Test standalone version first (isolates DAW issues)
2. Check Debug build for assertions
3. Use debugger attached to DAW process
4. Review DAW's crash logs

**Common causes**:

- Uninitialized variables in constructor
- Memory allocation in audio thread
- Thread safety violations
- Missing resources or files

### Validation Errors (AU)

**Check validation**:

```bash
auval -v aufx Plug Mcmp  # Replace with your codes
```

**Common issues**:

- Invalid manufacturer/plugin codes
- Mismatched bundle identifier
- Missing required AU properties
- Incorrect parameter handling

### GUI Issues

**Check**:

1. Test in standalone (fast iteration)
2. Check for platform-specific code paths
3. Verify resource loading (images, fonts)
4. Test window resizing behavior
5. Check high-DPI scaling

## Format-Specific Features

### VST3 Features

- Sample-accurate automation
- Note expression support
- Sidechain inputs (if configured)
- Multiple audio buses (if configured)
- Program lists and presets

### AU Features

- Core Audio integration
- AUParameter support
- Cocoa UI (native macOS)
- Audio Unit presets (.aupreset files)
- Inter-app audio (if configured)

### Standalone Features

- Direct audio device selection
- MIDI device selection
- Audio settings dialog
- File menu (load/save presets)
- Independent operation (no DAW needed)

## Distribution

### VST3 Distribution

**Windows**:

```text
YourPlugin-v1.0.0-windows.zip
└── Your Plugin.vst3/
    └── Contents/
        └── x86_64/
            └── Your Plugin.vst3
```

**macOS**:

```text
YourPlugin-v1.0.0-macos.zip
└── Your Plugin.vst3/
    └── Contents/
        └── MacOS/
            └── Your Plugin
```

**Linux**:

```text
YourPlugin-v1.0.0-linux.tar.gz
└── Your Plugin.vst3/
    └── Contents/
        └── x86_64-linux/
            └── Your Plugin.so
```

### AU Distribution (macOS)

```text
YourPlugin-v1.0.0-macos.zip
└── Your Plugin.component/
    └── Contents/
        ├── Info.plist
        └── MacOS/
            └── Your Plugin
```

### Standalone Distribution

**Windows**: Installer (NSIS, Inno Setup) or ZIP
**macOS**: DMG or ZIP
**Linux**: AppImage, DEB, or tar.gz

## See Also

- [BUILD.md](../BUILD.md) - Build system overview
- [CUSTOMIZATION.md](../CUSTOMIZATION.md) - Plugin metadata configuration
- [DEVELOPMENT_WORKFLOW.md](../DEVELOPMENT_WORKFLOW.md) - Development and testing
- [docs/VERSION_MANAGEMENT.md](VERSION_MANAGEMENT.md) - Release workflow
- [JUCE Plugin Format Documentation](https://docs.juce.com/master/tutorial_audio_plugin_host.html)
