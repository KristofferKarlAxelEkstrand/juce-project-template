# Cross-Platform Builds

Build system support for Windows, macOS, and Linux.

## Overview

The project uses platform-specific scripts:

- Windows: `.bat` files (initialize MSVC environment)
- macOS/Linux: `.sh` files (use system tools)

VS Code tasks select the correct script automatically.

## Build Scripts

### Windows

Scripts in `scripts/`:

- `configure-ninja.bat` - Configure CMake
- `build-ninja.bat` - Build with Ninja

Features:

- Auto-detect Visual Studio 2022 (Community, Professional, Enterprise)
- Initialize x64 developer environment
- Make MSVC, Ninja, and CMake available in build environment

### macOS/Linux

Scripts in `scripts/`:

- `configure-ninja.sh` - Configure CMake
- `build-ninja.sh` - Build with Ninja

Features:

- Use system CMake and Ninja
- Use default compiler (Clang on macOS, GCC/Clang on Linux)
- Standard Unix conventions

## VS Code Integration

Tasks in `.vscode/tasks.json` use platform-specific commands:

```json
{
    "label": "Build Standalone (Ninja Debug)",
    "type": "shell",
    "windows": {
        "command": "${workspaceFolder}\\scripts\\build-ninja.bat"
    },
    "linux": {
        "command": "${workspaceFolder}/scripts/build-ninja.sh"
    },
    "osx": {
        "command": "${workspaceFolder}/scripts/build-ninja.sh"
    }
}
```

VS Code selects the correct block based on OS.

## Platform Differences

### Executable Extensions

- Windows: `Your Plugin.exe`
- macOS: `Your Plugin.app` (application bundle)
- Linux: `Your Plugin` (no extension)

### Path Separators

- Windows: Backslash `\\` in tasks.json
- macOS/Linux: Forward slash `/` in tasks.json

VS Code handles this automatically.

### Build Directories

CMake presets use different directories:

- `default`: `build/default/` (Linux/macOS)
- `vs2022`: `build/vs2022/` (Windows)
- `ninja`: `build/ninja/` (all platforms)

## CMake Presets

`CMakePresets.json` defines platform-specific presets:

| Preset | Generator | Platform | Build Dir |
|--------|-----------|----------|-----------|
| `default` | Unix Makefiles | Linux/macOS | `build/default/` |
| `vs2022` | Visual Studio 17 | Windows | `build/vs2022/` |
| `ninja` | Ninja | All | `build/ninja/` |
| `xcode` | Xcode | macOS | `build/xcode/` |

Presets use conditions to select correct generator:

```json
{
    "name": "vs2022",
    "condition": {
        "type": "equals",
        "lhs": "${hostSystemName}",
        "rhs": "Windows"
    }
}
```

## Testing Builds

### Test on Windows

```cmd
scripts\configure-ninja.bat
scripts\build-ninja.bat
```

Or use VS Code: Press `Ctrl+Shift+B`

### Test on macOS/Linux

```bash
./scripts/configure-ninja.sh
./scripts/build-ninja.sh
```

Or use VS Code: Press `Cmd+Shift+B` (macOS) or `Ctrl+Shift+B` (Linux)

## Troubleshooting

### Windows: vcvarsall.bat not found

Install Visual Studio 2022 with "Desktop development with C++" workload.

### macOS: ninja not found

Install Ninja:

```bash
brew install ninja
```

### Linux: ninja not found

Install Ninja:

```bash
sudo apt-get install ninja-build
```

### Linux: Missing JUCE dependencies

Install required libraries:

```bash
sudo apt-get install -y \
    libasound2-dev libx11-dev libxcomposite-dev libxcursor-dev \
    libxinerama-dev libxrandr-dev libfreetype6-dev libfontconfig1-dev \
    libgl1-mesa-dev libwebkit2gtk-4.1-dev pkg-config
```

### Scripts not executable (macOS/Linux)

Make scripts executable:

```bash
chmod +x scripts/*.sh
```

## See Also

- [BUILD.md](../BUILD.md) - Initial build setup
- [DEVELOPMENT_WORKFLOW.md](../DEVELOPMENT_WORKFLOW.md) - Development workflow with Ninja
