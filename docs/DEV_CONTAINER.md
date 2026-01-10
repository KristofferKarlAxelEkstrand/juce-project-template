# Dev Container Development Guide

This project is designed for dev container-first development. The dev container provides a complete, pre-configured JUCE
development environment that works identically across all platforms.

## Getting Started

### Option 1: VS Code Dev Containers (Recommended)

1. Install [Docker Desktop](https://www.docker.com/products/docker-desktop)
2. Install [VS Code](https://code.visualstudio.com/) with the
   [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
3. Clone this repository and open in VS Code
4. When prompted, click "Reopen in Container"
5. Wait for the container to build (first time takes 2-3 minutes)

### Option 2: GitHub Codespaces

1. Click the "Open in GitHub Codespaces" badge in the README
2. Wait for the codespace to start (1-2 minutes)
3. Start developing immediately in your browser

### Option 3: CLI with Dev Container

```bash
# Install devcontainer CLI
npm install -g @devcontainers/cli

# Clone and start container
git clone https://github.com/KristofferKarlAxelEkstrand/juce-project-template.git
cd juce-project-template
devcontainer up --workspace-folder .
devcontainer exec --workspace-folder . bash
```

## What's Included

The dev container provides:

| Component                 | Description                                     |
| ------------------------- | ----------------------------------------------- |
| **Build Tools**           | CMake 3.25+, Ninja, Clang, GCC, ccache          |
| **JUCE Dependencies**     | ALSA, X11, FreeType, WebKit, OpenGL libraries   |
| **Audio Testing**         | JACK with dummy driver, ALSA sequencer for MIDI |
| **Windows Cross-Compile** | MinGW-w64 for building Windows VST3 from Linux  |
| **Code Quality**          | clang-format, markdownlint, prettier            |
| **Debugging**             | GDB, LLDB, VS Code debugging integration        |
| **VS Code Extensions**    | C++, CMake, clangd, LLDB debugger               |

## Daily Workflow

### Build Commands

```bash
# Build debug (1-3 seconds incremental with ccache)
cmake --build --preset=ninja

# Build release
cmake --build --preset=ninja --config Release

# Reconfigure (after changing CMakeLists.txt)
cmake --preset=ninja

# Windows cross-compile
cmake --preset=mingw64
cmake --build --preset=mingw64
```

### VS Code Shortcuts

| Action    | Shortcut                           |
| --------- | ---------------------------------- |
| Build     | `Ctrl+Shift+B`                     |
| Run Task  | `Ctrl+Shift+P` → "Tasks: Run Task" |
| Debug     | `F5`                               |
| Configure | Run "Configure Ninja" task         |

### Validate Build

```bash
# Check build artifacts
./scripts/validate-builds.sh

# Run linting
npm test
```

## Build Outputs

Artifacts are in `build/ninja/JucePlugin_artefacts/Debug/`:

```text
JucePlugin_artefacts/Debug/
├── VST3/
│   └── JUCE Project Template Plugin.vst3/
├── Standalone/
│   └── JUCE Project Template Plugin
└── libJUCE Project Template Plugin_SharedCode.a
```

## Container Configuration

### Host Requirements

The container requests these minimum resources:

- **CPUs**: 4 cores
- **Memory**: 8 GB
- **Storage**: 32 GB

Configure in Docker Desktop if builds are slow.

### ccache Volume

Build cache persists between container rebuilds via a Docker volume:

```jsonc
"mounts": ["source=juce-ccache,target=/home/vscode/.ccache,type=volume"]
```

First build: ~3 minutes. Incremental builds: 1-3 seconds.

### Environment Variables

| Variable     | Value                      | Description              |
| ------------ | -------------------------- | ------------------------ |
| `CCACHE_DIR` | `/home/vscode/.ccache`     | Build cache location     |
| `PATH`       | Includes `/usr/lib/ccache` | ccache compiler wrappers |

## Windows Cross-Compilation

Build Windows VST3 plugins from inside the Linux container:

```bash
# Configure for Windows
cmake --preset=mingw64

# Build
cmake --build --preset=mingw64

# Output
ls build/mingw64/JucePlugin_artefacts/Debug/VST3/
```

The MinGW-w64 toolchain is pre-installed with POSIX threading support.

## Audio Testing

Start virtual audio for plugin testing:

```bash
./.devcontainer/start-audio.sh
```

This starts JACK with a dummy driver (no real hardware needed):

- Sample rate: 48000 Hz
- Buffer size: 512 samples

Use `aconnect -l` to list MIDI connections.

## Headless GUI Testing

Run GUI applications headlessly with Xvfb:

```bash
# Start virtual display
Xvfb :99 -screen 0 1024x768x24 &
export DISPLAY=:99

# Run standalone
./build/ninja/JucePlugin_artefacts/Debug/Standalone/JUCE\ Project\ Template\ Plugin
```

## Troubleshooting

### Container Won't Start

```bash
# Check Docker is running
docker info

# Rebuild container
# In VS Code: Ctrl+Shift+P → "Dev Containers: Rebuild Container"
```

### Slow Builds

1. Increase Docker resources (CPUs, RAM) in Docker Desktop
2. Check ccache is working: `ccache -s`
3. Ensure the ccache volume exists: `docker volume ls | grep ccache`

### Permission Errors

The post-create script fixes common permission issues. If you still have problems:

```bash
sudo chown -R $(id -u):$(id -g) /home/vscode/.ccache
```

### Git Identity Not Set

Configure git in the container:

```bash
git config --global user.email "you@example.com"
git config --global user.name "Your Name"
```

## Customizing the Container

### Add Dependencies

Edit `.devcontainer/Dockerfile`:

```dockerfile
RUN apt-get update && apt-get install -y \
    your-package-here
```

Then rebuild the container.

### Add VS Code Extensions

Edit `.devcontainer/devcontainer.json`:

```jsonc
"customizations": {
    "vscode": {
        "extensions": [
            "existing-extension",
            "your.new-extension"
        ]
    }
}
```

### Change Post-Create Commands

Edit `.devcontainer/post-create.sh` to run additional setup after container creation.

## Files Reference

| File                                     | Purpose                                    |
| ---------------------------------------- | ------------------------------------------ |
| `.devcontainer/devcontainer.json`        | Container configuration                    |
| `.devcontainer/Dockerfile`               | Base image and dependencies                |
| `.devcontainer/post-create.sh`           | Setup script (runs after container starts) |
| `.devcontainer/start-audio.sh`           | Virtual audio/MIDI setup                   |
| `.devcontainer/toolchains/mingw64.cmake` | Windows cross-compile toolchain            |
