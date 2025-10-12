# Plugin Customization Guide

Step-by-step guide to customize this template for your own JUCE plugin.

## Before You Start

This template provides a working JUCE plugin. Follow these steps in order to customize it for your project.

**Time required**: 10-15 minutes

## Step 1: Edit Plugin Metadata

All plugin metadata is centralized in `CMakeLists.txt`. Edit these values:

### Required Changes

Open `CMakeLists.txt` and locate the metadata section (around line 63):

```cmake
set(PLUGIN_NAME "DSP-JUCE Plugin")        # Change to your plugin name
set(PLUGIN_TARGET "JucePlugin")           # Change to your target name (no spaces)
set(PLUGIN_VERSION "0.0.1")               # Keep for initial development
set(PLUGIN_COMPANY_NAME "MyCompany")      # Change to your company name
set(PLUGIN_COMPANY_WEBSITE "https://mycompany.com")  # Change to your website
set(PLUGIN_DESCRIPTION "Advanced DSP audio processing plugin")  # Change description
```

**Edit these fields**:

1. `PLUGIN_NAME`: User-facing product name (can contain spaces)
   - Example: `"My Awesome Reverb"`
   - This appears in DAWs and the standalone app title

2. `PLUGIN_TARGET`: CMake target name (no spaces, alphanumeric only)
   - Example: `"MyAwesomeReverb"`
   - Used for build directories and internal references

3. `PLUGIN_COMPANY_NAME`: Your name or company name
   - Example: `"John Doe Audio"`

4. `PLUGIN_COMPANY_WEBSITE`: Your website URL
   - Example: `"https://johndoeaudio.com"`

5. `PLUGIN_DESCRIPTION`: Short description of your plugin
   - Example: `"Algorithmic reverb with vintage character"`

### Plugin Identification Codes

**Important**: Change these codes to unique values for your plugin:

```cmake
set(PLUGIN_MANUFACTURER_CODE "Mcmp")      # 4 characters, at least one uppercase
set(PLUGIN_CODE "Dsp1")                   # 4 characters, first char uppercase
```

**Rules**:
- Must be exactly 4 characters
- At least one uppercase letter required
- `PLUGIN_CODE` first character should be uppercase (GarageBand compatibility)
- These codes must be unique to your plugin

**Examples**:
- Manufacturer code: `"Jdoe"` (for John Doe)
- Plugin code: `"Rvb1"` (for first reverb plugin)

### Version Number

Keep `PLUGIN_VERSION "0.0.1"` during development. Update when ready to release.

Version must also match in line 4:

```cmake
project(JuceProject VERSION 0.0.1 LANGUAGES C CXX)
```

**Important**: Both version numbers must match or CMake will fail with an error.

## Step 2: Reconfigure CMake

After editing `CMakeLists.txt`, reconfigure CMake to apply changes:

**VS Code users**:
1. Press `Ctrl+Shift+P` (Windows/Linux) or `Cmd+Shift+P` (macOS)
2. Select "Tasks: Run Task"
3. Select "Configure Ninja"

**Command line**:

```bash
# Windows
scripts\configure-ninja.bat

# macOS/Linux
./scripts/configure-ninja.sh
```

Or use standard CMake:

```bash
cmake --preset=default
```

## Step 3: Verify Configuration

Check that metadata was applied correctly:

```bash
# Check CMake output
cmake --preset=default | grep "Plugin:"
# Should show: -- Plugin: Your Plugin Name v0.0.1

# Check generated metadata file
cat build/default/plugin_metadata.sh | grep PROJECT_NAME_PRODUCT
# Should show: export PROJECT_NAME_PRODUCT="Your Plugin Name"
```

## Step 4: Build Your Plugin

Build the plugin to verify everything works:

**VS Code users**:
- Press `Ctrl+Shift+B` to build

**Command line**:

```bash
# Windows
scripts\build-ninja.bat

# macOS/Linux
./scripts/build-ninja.sh
```

**Expected output**: Build artifacts in `build/ninja/YourTarget_artefacts/Debug/`

## Step 5: Test Your Plugin

Run the standalone application:

**VS Code users**:
1. Press `Ctrl+Shift+P`
2. Select "Tasks: Run Task"
3. Select "Run Standalone"

**Command line**:

```bash
# Windows
build\ninja\YourTarget_artefacts\Debug\Standalone\Your Plugin Name.exe

# macOS
open "build/ninja/YourTarget_artefacts/Debug/Standalone/Your Plugin Name.app"

# Linux
./build/ninja/YourTarget_artefacts/Debug/Standalone/Your\ Plugin\ Name
```

**Note**: Replace `YourTarget` and `Your Plugin Name` with your actual values.

## Step 6: Customize the Code

Now customize the audio processing and GUI:

### Audio Processing (DSP)

Edit `src/MainComponent.cpp` and `src/MainComponent.h`:

1. Modify `prepareToPlay()` to initialize your DSP
2. Update `processBlock()` with your audio algorithm
3. Add parameters for user control

**Example**: Replace sine wave with your processing

### GUI (User Interface)

Edit `src/PluginEditor.cpp` and `src/PluginEditor.h`:

1. Update `PluginEditor()` constructor to add your controls
2. Modify `resized()` to layout your UI
3. Connect controls to audio parameters

**Example**: Add knobs, sliders, or buttons for your parameters

## Step 7: Update Documentation

Update project documentation to reflect your plugin:

1. **README.md**: Replace template description with your plugin description
2. **QUICKSTART.md**: Update examples to use your plugin name
3. **DEVELOPMENT_WORKFLOW.md**: No changes needed (uses metadata automatically)

## Common Customization Tasks

### Add New Source Files

1. Create files in `src/` directory
2. Add to `CMakeLists.txt` in `target_sources()` section:

   ```cmake
   target_sources(${PLUGIN_TARGET} PRIVATE
       src/Main.cpp
       src/MainComponent.cpp
       src/MainComponent.h
       src/PluginEditor.cpp
       src/PluginEditor.h
       src/MyNewFile.cpp        # Add your files here
       src/MyNewFile.h
   )
   ```

3. Reconfigure CMake (see Step 2)
4. Build (see Step 4)

### Change Plugin Type

By default, this template creates an audio effect plugin. To create a synthesizer:

Edit `CMakeLists.txt`, line 149:

```cmake
IS_SYNTH TRUE                    # Change FALSE to TRUE
NEEDS_MIDI_INPUT TRUE            # Change FALSE to TRUE
```

### Enable More Plugin Formats

Add AU (Audio Units) on macOS, or other formats:

The template automatically builds AU on macOS. For other platforms, formats are:
- Windows/Linux: VST3, Standalone
- macOS: VST3, AU, Standalone

No changes needed unless you want to disable formats.

## Validation

After customization, validate everything works:

```bash
# Check build artifacts exist
./scripts/validate-builds.sh Debug

# Check development environment
./scripts/validate-setup.sh

# Lint documentation
npm test
```

## Troubleshooting

### Build fails after changing metadata

**Cause**: Version mismatch or invalid codes

**Fix**: Check that:
1. `project(... VERSION ...)` matches `PLUGIN_VERSION`
2. `PLUGIN_MANUFACTURER_CODE` and `PLUGIN_CODE` are exactly 4 characters
3. Both codes have at least one uppercase letter

### VS Code tasks fail with "file not found"

**Cause**: VS Code tasks cache old plugin names

**Fix**:
1. Reconfigure CMake (Step 2)
2. Restart VS Code
3. The tasks dynamically read metadata and should work now

### Plugin does not appear in DAW

**Cause**: Plugin not installed in system directory

**Fix**: Copy plugin to system directory:

Windows:
```cmd
copy "build\ninja\YourTarget_artefacts\Debug\VST3\Your Plugin.vst3" ^
     "C:\Program Files\Common Files\VST3\"
```

macOS:
```bash
cp -r "build/ninja/YourTarget_artefacts/Debug/VST3/Your Plugin.vst3" \
      "/Library/Audio/Plug-Ins/VST3/"
```

Linux:
```bash
cp -r "build/ninja/YourTarget_artefacts/Debug/VST3/Your Plugin.vst3" \
      "$HOME/.vst3/"
```

Then rescan plugins in your DAW.

## Next Steps

After customization:

1. **Set up fast development workflow**: See [DEVELOPMENT_WORKFLOW.md](DEVELOPMENT_WORKFLOW.md)
2. **Learn JUCE concepts**: See [docs/JUCE/](docs/JUCE/)
3. **Understand version management**: See [docs/VERSION_MANAGEMENT.md](docs/VERSION_MANAGEMENT.md)
4. **Prepare for release**: See [BUILD.md](BUILD.md) for Release builds
5. **Set up CI/CD**: See [docs/CI.md](docs/CI.md)

## See Also

- [BUILD.md](BUILD.md) - Platform-specific build instructions
- [DEVELOPMENT_WORKFLOW.md](DEVELOPMENT_WORKFLOW.md) - Fast development with Ninja
- [CONTRIBUTING.md](CONTRIBUTING.md) - Git workflow and coding standards
- [docs/VERSION_MANAGEMENT.md](docs/VERSION_MANAGEMENT.md) - Version and release workflow
