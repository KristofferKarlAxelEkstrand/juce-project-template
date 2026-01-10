# Windows Development Guide

Complete guide for developing JUCE audio plugins on Windows.

## Development Workflows

Choose the workflow that fits your needs:

| Workflow           | Best For                   | What You Build          | Requirements            |
| ------------------ | -------------------------- | ----------------------- | ----------------------- |
| **Windows Native** | Windows plugin development | Windows VST3/Standalone | Visual Studio 2022      |
| **Dev Container**  | Consistent Linux builds    | Linux VST3/Standalone   | Docker Desktop, VS Code |
| **WSL2 + WSLg**    | Linux builds with GUI      | Linux VST3/Standalone   | Windows 10/11, WSL2     |
| **GitHub CI**      | Cross-platform releases    | All platforms           | Just push code          |

**Note:** Plugins are native binaries. A Linux plugin cannot run in a Windows DAW and vice versa. Each platform requires
its own build.

## Windows Native Development

Build Windows plugins directly on your Windows machine.

### Prerequisites

1. **Visual Studio 2022** with "Desktop development with C++" workload
   - Download: [Visual Studio 2022 Community](https://visualstudio.microsoft.com/downloads/)
   - During installation, select "Desktop development with C++"
   - This includes CMake, Ninja, and the MSVC compiler

2. **Git** (usually included with VS, or install separately)
   - Download: [Git for Windows](https://git-scm.com/download/win)

### Verify Installation

Open "Developer Command Prompt for VS 2022" and run:

```cmd
cmake --version
cl
ninja --version
git --version
```

### Build Steps

```cmd
# Clone the repository
git clone https://github.com/YourUser/juce-project-template.git
cd juce-project-template

# Configure (downloads JUCE, ~90 seconds first time)
cmake --preset=vs2022

# Build Debug
cmake --build --preset=vs2022

# Build Release
cmake --build --preset=vs2022-release
```

### Build Outputs

Artifacts are in `build/vs2022/JucePlugin_artefacts/`:

```text
build/vs2022/JucePlugin_artefacts/
├── Debug/
│   ├── VST3/Your Plugin.vst3/
│   └── Standalone/Your Plugin.exe
└── Release/
    ├── VST3/Your Plugin.vst3/
    └── Standalone/Your Plugin.exe
```

### Fast Development with Ninja

For faster incremental builds (1-3 seconds):

```cmd
# From Developer Command Prompt
scripts\configure-ninja.bat
scripts\build-ninja.bat
```

Or use VS Code tasks: `Ctrl+Shift+B`

### Install Plugin in DAW

Copy the VST3 to the system plugin folder:

```cmd
xcopy /E /I "build\vs2022\JucePlugin_artefacts\Release\VST3\Your Plugin.vst3" "%PROGRAMFILES%\Common Files\VST3\Your Plugin.vst3"
```

Then rescan plugins in your DAW.

## Dev Container on Windows

Run a Linux development environment inside Docker on Windows.

### Docker Requirements

1. **Docker Desktop for Windows**
   - Download: [Docker Desktop](https://www.docker.com/products/docker-desktop)
   - Works on Windows 10/11 Home, Pro, Enterprise
   - Uses WSL2 backend (recommended)

2. **VS Code** with Dev Containers extension
   - Download: [VS Code](https://code.visualstudio.com/)
   - Install extension: `ms-vscode-remote.remote-containers`

### Getting Started

1. Clone the repository
2. Open folder in VS Code
3. Click "Reopen in Container" when prompted
4. Wait for container build (~2-3 minutes first time)

### What You Get

- Pre-configured Linux build environment
- All JUCE dependencies installed
- Ninja for fast builds (1-3 seconds incremental)
- ccache for build caching
- VS Code debugging integration

### Building in Container

```bash
# Build (Ctrl+Shift+B in VS Code)
cmake --build --preset=ninja

# Or use the build script
./scripts/build-ninja.sh
```

### Limitations

- Builds Linux plugins (not Windows)
- GUI testing requires X11 forwarding or Xvfb
- Audio requires virtual audio setup

For Windows plugin builds, use native development or GitHub CI.

## WSL2 + WSLg Development

Run Linux GUI applications directly on Windows with full audio support.

### Requirements

- Windows 10 Build 19044+ (November 2021 Update) or Windows 11
- WSL2 (not WSL1)
- Updated GPU drivers

**Note:** WSLg works on Windows Home editions, not just Pro/Enterprise.

### Install WSL2 with GUI Support

```powershell
# Run as Administrator
wsl --install -d Ubuntu

# Restart computer when prompted

# After restart, update WSL
wsl --update
wsl --shutdown
```

### Update GPU Drivers

Install the latest drivers for your GPU:

- [Intel GPU drivers](https://downloadcenter.intel.com/)
- [AMD GPU drivers](https://www.amd.com/support/download/drivers.html)
- [NVIDIA GPU drivers](https://www.nvidia.com/drivers)

### Install Build Dependencies

Open Ubuntu terminal:

```bash
sudo apt update && sudo apt upgrade -y

# Install build tools
sudo apt install -y build-essential cmake ninja-build git

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
    libcurl4-openssl-dev \
    libwebkit2gtk-4.1-dev \
    pkg-config
```

### Configure Audio (PulseAudio)

WSLg includes PulseAudio support. Audio should work automatically, but you can verify:

```bash
# Check PulseAudio is running
pactl info

# List audio sinks (outputs)
pactl list sinks short

# List audio sources (inputs)
pactl list sources short

# Test audio output
paplay /usr/share/sounds/alsa/Front_Center.wav
```

If audio is not working:

```bash
# Ensure PulseAudio environment is set
echo 'export PULSE_SERVER=unix:/mnt/wslg/PulseServer' >> ~/.bashrc
source ~/.bashrc

# Restart WSL
wsl --shutdown
# Then reopen Ubuntu
```

### Configure MIDI

For MIDI support in WSLg:

```bash
# Install ALSA MIDI tools
sudo apt install -y alsa-utils

# List MIDI devices
aconnect -l

# For virtual MIDI, install FluidSynth
sudo apt install -y fluidsynth fluid-soundfont-gm
fluidsynth -a pulseaudio /usr/share/sounds/sf2/FluidR3_GM.sf2
```

### Build and Run

```bash
# Clone repository
git clone https://github.com/YourUser/juce-project-template.git
cd juce-project-template

# Configure
cmake --preset=ninja

# Build
cmake --build --preset=ninja

# Run standalone (GUI appears on Windows desktop!)
./build/ninja/JucePlugin_artefacts/Debug/Standalone/JUCE\ Project\ Template\ Plugin
```

The standalone application window appears on your Windows desktop, integrated with the Windows taskbar.

### WSLg Troubleshooting

**"Cannot open display" error:**

```bash
# Check DISPLAY is set
echo $DISPLAY
# Should show something like :0

# If not set, add to .bashrc
echo 'export DISPLAY=:0' >> ~/.bashrc
source ~/.bashrc
```

**No audio:**

```bash
# Check PulseAudio server
echo $PULSE_SERVER
# Should show: unix:/mnt/wslg/PulseServer

# Restart WSL completely
wsl --shutdown
```

**Graphical glitches:**

- Update GPU drivers
- Try: `export LIBGL_ALWAYS_SOFTWARE=1` for software rendering

## GitHub Actions CI

Build for all platforms without local setup.

### How It Works

Push code to trigger builds:

- **PR to `main`**: Builds all platforms (Linux, Windows, macOS)
- **PR to `develop`**: Builds Linux Debug + Windows Release
- **PR to `develop-windows`**: Builds Windows Release only
- **PR to `develop-macos`**: Builds macOS Release only
- **PR to `develop-linux`**: Builds Linux Debug + Release

### Download Artifacts

1. Go to Actions tab in GitHub
2. Click on completed workflow run
3. Download artifacts (VST3, Standalone) for each platform

### Release Workflow

Tag a release to automatically build and publish:

```bash
git tag v1.0.0
git push origin v1.0.0
```

## Workflow Comparison

| Feature          | Native Windows | Dev Container | WSL2 + WSLg | GitHub CI |
| ---------------- | -------------- | ------------- | ----------- | --------- |
| Windows plugins  | Yes            | No            | No          | Yes       |
| Linux plugins    | No             | Yes           | Yes         | Yes       |
| macOS plugins    | No             | No            | No          | Yes       |
| GUI testing      | Yes            | Limited       | Yes         | No        |
| Audio testing    | Yes            | Virtual       | Yes         | No        |
| Setup complexity | Low            | Medium        | Medium      | None      |
| Build speed      | Fast           | Fast          | Fast        | Slow      |
| Offline work     | Yes            | Yes           | Yes         | No        |

## Recommended Setup

For most Windows developers:

1. **Primary development**: Windows Native with Visual Studio 2022
   - Fast builds, full debugging, native audio/GUI testing

2. **Linux validation**: GitHub CI (develop-linux branch)
   - Automatic builds on push, no local setup needed

3. **Full cross-platform release**: GitHub CI (main branch)
   - All platforms built and tested automatically

For developers who need to work with Linux code directly:

1. **WSL2 + WSLg**: Best GUI/audio experience
2. **Dev Container**: Most consistent environment

## See Also

- [BUILD.md](../BUILD.md) - General build instructions
- [DEVELOPMENT_WORKFLOW.md](../DEVELOPMENT_WORKFLOW.md) - VS Code workflow
- [DEV_CONTAINER.md](DEV_CONTAINER.md) - Dev container details
- [CI.md](CI.md) - CI/CD configuration
