# DSP-JUCE Development Environment

This repository is a modern JUCE 8.0.10 audio plugin development environment
demonstrating real-time audio processing, cross-platform plugin builds, and modern C++20 patterns.

## Architecture Overview

**Core Components:**

- `MainComponent.h/cpp`: AudioProcessor implementing sine-wave synthesizer with thread-safe parameter control
- `PluginEditor.h/cpp`: GUI editor with frequency/gain sliders using immediate parameter updates  
- `Main.cpp`: Plugin entry point supporting both VST3 plugin and standalone builds
- `CMakeLists.txt`: Modern CMake with FetchContent auto-downloading JUCE 8.0.10

**Metadata Centralization:**

All plugin metadata is defined in `CMakeLists.txt` (lines 55-70) as a single source of truth:

- Edit `PLUGIN_NAME`, `PLUGIN_TARGET`, `PLUGIN_VERSION` to create new plugins
- Metadata automatically propagates to source code via JUCE macros (`JucePlugin_Name`, etc.)
- Build scripts source generated `plugin_metadata.sh` for dynamic artifact validation
- CI/CD workflows extract metadata for automated releases
- Version consistency enforced by CMake (build fails if `PLUGIN_VERSION != PROJECT_VERSION`)

**Critical Real-Time Safety Pattern:**

```cpp
// Thread-safe parameter communication between GUI and audio threads
std::atomic<float> currentFrequency{440.0f};  // In MainComponent.h
oscillator.setFrequency(currentFrequency.load());  // In processBlock()
audioProcessor.setFrequency(newValue);  // From GUI thread (stores atomically)
```

**DSP Processing Chain:**

```cpp
// Modern JUCE DSP approach in processBlock()
juce::dsp::AudioBlock<float> block(buffer);
juce::dsp::ProcessContextReplacing<float> context(block);
oscillator.process(context);  // Generate sine wave
gain.process(context);        // Apply gain
```

## Build System Essentials

**Critical Build Commands:**

```bash
# Configure (90+ seconds - downloads JUCE 8.0.10 automatically)
cmake --preset=default          # Linux/macOS
cmake --preset=vs2022           # Windows (requires Visual Studio 2022)

# Build (2m45s Debug, 4m30s Release)
cmake --build --preset=default  # Creates VST3 + standalone in build/<target>_artefacts/
```

**Threading Architecture:**

- **Audio Thread**: `processBlock()` runs in real-time audio thread (no allocations, lock-free)
- **GUI Thread**: Slider callbacks update `std::atomic<float>` parameters
- **Message Thread**: JUCE's message thread handles UI updates and event processing
- **Data Flow**: GUI → atomic store → audio thread load → DSP parameter update

**JUCE Module Dependencies:**

- `juce_audio_basics`: Core audio types and buffer management
- `juce_audio_devices`: Audio device I/O (standalone app only)
- `juce_audio_formats`: File I/O support
- `juce_audio_processors`: Plugin framework and parameter handling
- `juce_audio_utils`: UI components for audio applications
- `juce_core`: Fundamental utilities and data structures
- `juce_data_structures`: Value trees and undo management
- `juce_dsp`: Digital signal processing algorithms
- `juce_events`: Message threading and asynchronous operations
- `juce_graphics`: 2D graphics rendering
- `juce_gui_basics`: Core GUI components and event handling
- `juce_gui_extra`: Additional GUI components (sliders, buttons)

## Development Workflow

**Before Making Changes:**

```bash
./scripts/validate-setup.sh  # Check dependencies
npm test                     # Validate documentation
```

**Code Patterns:**

```cpp
// Real-time safe parameter updates in processBlock()
oscillator.setFrequency(currentFrequency.load());  // Never allocate memory here

// GUI parameter control (PluginEditor.cpp)
frequencySlider.onValueChange = [this] {
    audioProcessor.setFrequency(static_cast<float>(frequencySlider.getValue()));
};

// State persistence pattern (MainComponent.cpp)
void getStateInformation(juce::MemoryBlock &destData) override {
    juce::XmlElement xml(JucePlugin_Name);  // Uses CMake-generated macro
    xml.setAttribute("frequency", currentFrequency.load());
    copyXmlToBinary(xml, destData);
}
```

**Quality Assurance:**

```bash
clang-format -i src/*.cpp src/*.h  # Format before committing
cmake --build --preset=default    # Validate builds successfully
```

**Git Workflow Conventions:**

```bash
# Branch structure (Git Flow-inspired)
feature/your-feature  # From develop branch
fix/issue-123        # Bug fixes from develop

# Commit messages (Conventional Commits)
feat: Add frequency modulation to oscillator
fix: Resolve audio dropout on buffer size change
docs: Update build instructions for Windows
style: Apply clang-format to source files
```

**Pre-Commit Automation:**

- Husky runs `lint-staged` on commit
- Automatically lints markdown files with `markdownlint-cli2 --fix`
- Blocks commits that fail linting (fix with `npm run lint:md:fix`)
- CI runs only on PRs to `main`/`develop` (saves resources)

## Project Structure and Key Files

```text
dsp-juce/
├── src/                     # JUCE application source code
│   ├── Main.cpp            # Plugin entry point for both standalone and plugin formats
│   ├── MainComponent.h     # AudioProcessor interface for audio processing
│   ├── MainComponent.cpp   # Real-time audio processing with DSP
│   ├── PluginEditor.h      # AudioProcessorEditor interface for GUI
│   └── PluginEditor.cpp    # GUI implementation with parameter controls
├── .github/                # GitHub configuration and instructions
├── CMakeLists.txt          # Modern CMake with JUCE 8.0.10 FetchContent
├── CMakePresets.json       # Cross-platform build presets
├── package.json           # NPM tooling for documentation linting
├── scripts/               # Setup validation scripts
└── build/                 # Auto-generated build directory (ignored by git)
    └── <target>_artefacts/Debug/  # Named from PLUGIN_TARGET in CMakeLists.txt
        ├── VST3/           # VST3 plugin bundle
        ├── Standalone/     # Standalone application
        └── lib<target>_SharedCode.a  # Shared library
```

## Project-Specific Conventions

**Git Workflow (Git Flow-inspired):**

- **Branch Structure**: `main` (production) ← `develop` (integration) ← `feature/*` branches
- **PR Strategy**: Feature → develop → main (CI runs only on PRs to protected branches)
- **Commit Format**: Conventional Commits (`feat:`, `fix:`, `docs:`, `style:`)
- **Pre-commit Hooks**: Husky + lint-staged auto-format markdown on commit

**Real-Time Audio Constraints:**

- **Zero allocations in audio thread**: All memory operations in `prepareToPlay()` only
- **Atomic parameter access**: GUI→audio communication via `std::atomic<float>`
- **DSP preparation**: All processing setup completed before `processBlock()` begins
- **Buffer size agnostic**: Code works with any buffer size (32-2048 samples)

**JUCE Integration Patterns:**

- **Plugin formats**: Single codebase builds VST3, AU, and standalone
- **State persistence**: XML-based parameter save/restore via `getStateInformation/setStateInformation`
- **Resource management**: RAII with `JUCE_DECLARE_NON_COPYABLE_WITH_LEAK_DETECTOR`
- **Cross-platform compatibility**: Conditional compilation for Windows/macOS/Linux

## Common Tasks and Outputs

### Manual Validation Scenarios

After making changes, always test through these scenarios:

1. **Build Validation:**

   ```bash
   # Clean rebuild cycle
   rm -rf build
   cmake --preset=default  # Linux/macOS
   cmake --preset=vs2022   # Windows
   cmake --build --preset=default
   ```

2. **Artefact Verification:**

   ```bash
   # Check all expected files exist (paths use PLUGIN_TARGET and PLUGIN_NAME from CMakeLists.txt)
   # Use scripts/validate-builds.sh for automatic validation with dynamic metadata
   ./scripts/validate-builds.sh
   ```

3. **Application Startup Test:**

   ```bash
   # Should start and show JUCE version (fails in headless environment)
   # Path depends on PLUGIN_TARGET and PLUGIN_NAME from CMakeLists.txt
   # Example: ./build/<target>_artefacts/Debug/Standalone/<product-name>
   ```

4. **Plugin Format Validation:**

   ```bash
   # VST3 plugin should be properly structured
   # Path: build/<target>_artefacts/Debug/VST3/<product-name>.vst3/
   # Use validate-builds.sh script for automatic validation
   ```

## Troubleshooting

### Missing Dependencies (Linux)

Install all packages for audio development:

```bash
sudo apt-get install -y libasound2-dev libx11-dev libxcomposite-dev libxcursor-dev \
                        libxinerama-dev libxrandr-dev libfreetype6-dev libfontconfig1-dev \
                        libgl1-mesa-dev libcurl4-openssl-dev libwebkit2gtk-4.1-dev pkg-config \
                        build-essential
```

- Run `./scripts/validate-setup.sh` to verify installation
- Missing packages will cause CMake configuration to fail

### Windows Build Issues

- Use `cmake --preset=vs2022` instead of `--preset=default` on Windows
- Ensure Visual Studio 2022 with "Desktop development with C++" workload is installed
- If CMake can't find Visual Studio, reinstall with proper C++ tools

### Documentation Linting Failures

- Always run `npm test` before committing
- Fix issues with `npm run lint:md:fix`
- Common issues: trailing whitespace, heading levels

### Build Performance Issues

- Debug builds are large (~197MB static library) but necessary for development
- Use Release builds for distribution: `cmake --preset=release && cmake --build --preset=release`
- Clean builds take full time; incremental builds are much faster

## JUCE Development Anti-Patterns

- Allocating memory in `processBlock()` or other real-time contexts
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
