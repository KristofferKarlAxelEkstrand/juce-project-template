# Quick Start: Build Your First Plugin in 5 Minutes

## Prerequisites Check

Run these commands. If they work, you are ready:

```bash
cmake --version    # Must show 3.22+
g++ --version      # Or clang, msvc
git --version
```

## Three Steps to a Running Plugin

### Step 1: Get the Code (30 seconds)

```bash
git clone https://github.com/KristofferKarlAxelEkstrand/juce-project-template.git
cd juce-project-template
```

### Step 2: Build (3-4 minutes first time)

```bash
# Build with default tools (e.g., Make, MSBuild)
cmake --preset=default
cmake --build --preset=default
```

> **Note:** For faster builds, install [Ninja](https://ninja-build.org/) and use the `ninja` preset instead of `default`.

### Step 3: Run Your Plugin (instant)

```bash
# On macOS
open "build/JucePlugin_artefacts/Debug/Standalone/DSP-JUCE Plugin.app"

# On Linux
./build/JucePlugin_artefacts/Debug/Standalone/"DSP-JUCE Plugin"

# On Windows
./build/JucePlugin_artefacts/Debug/Standalone/"DSP-JUCE Plugin.exe"
```

## What You Just Built

You built a working JUCE audio plugin that:

- Generates a sine wave at 440 Hz
- Has frequency and gain controls
- Works as VST3, Standalone (AU on macOS)

## Next Steps

**Customize Your Plugin:**

1. Edit plugin name and metadata - See [BUILD.md](BUILD.md) for CMakeLists.txt configuration
2. Add your DSP code - See [DEVELOPMENT_WORKFLOW.md](DEVELOPMENT_WORKFLOW.md)
3. Design your GUI - See [docs/JUCE](docs/JUCE) for JUCE basics

**Learn the System:**

- Full build options - [BUILD.md](BUILD.md)
- Fast development workflow - [DEVELOPMENT_WORKFLOW.md](DEVELOPMENT_WORKFLOW.md)
- CI/CD and releases - [docs/CI.md](docs/CI.md)

**Troubleshooting:**

- Build fails? - [BUILD.md](BUILD.md) (see Troubleshooting section)
- Plugin does not load? - [BUILD.md](BUILD.md) (see Plugin Not Found by DAW)

## Common First-Time Issues

### "cmake: command not found"

Install CMake 3.22+:

- macOS: `brew install cmake`
- Linux: `sudo apt install cmake`
- Windows: Download from <https://cmake.org>

### "JUCE download fails"

If the automatic download of JUCE fails during the `cmake --preset` step (e.g., due to a firewall), you can download it manually:

1. **Download JUCE**: Get the `Source code (zip)` for version **8.0.10** from the [JUCE releases page](https://github.com/juce-framework/JUCE/releases/tag/8.0.10).
2. **Create directory**: `mkdir -p third_party`
3. **Extract to**: `third_party/JUCE`

After extracting, your directory structure should look like this: `third_party/JUCE/README.md`.

Then, run the build commands again.
