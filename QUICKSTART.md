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
cmake --preset=ninja
cmake --build --preset=ninja
```

### Step 3: Run Your Plugin (instant)

```bash
# On macOS
open "build/ninja/JucePlugin_artefacts/Debug/Standalone/DSP-JUCE Plugin.app"

# On Linux
./build/ninja/JucePlugin_artefacts/Debug/Standalone/"DSP-JUCE Plugin"

# On Windows
"build\\ninja\\JucePlugin_artefacts\\Debug\\Standalone\\DSP-JUCE Plugin.exe"
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

Check internet connection. If behind a firewall, you have two options:

#### Option 1: Manual Download (Recommended)

1. **Download JUCE manually**: [https://github.com/juce-framework/JUCE/archive/refs/tags/8.0.10.zip](https://github.com/juce-framework/JUCE/archive/refs/tags/8.0.10.zip)
2. **Create directory**: `mkdir -p third_party`
3. **Extract to**: `third_party/JUCE` (ensure the `.git` folder is not inside the extracted folder)

#### Option 2: Git Submodule

If you prefer to use Git, you can add JUCE as a submodule:

```bash
git submodule add https://github.com/juce-framework/JUCE.git third_party/JUCE
```
