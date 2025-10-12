# VS Code Integration Guide

Complete guide to using Visual Studio Code for JUCE plugin development with this template.

## Overview

This template provides pre-configured VS Code tasks for fast build-test cycles. This guide covers task usage, debugging setup, and recommended extensions.

## VS Code Tasks

### Available Tasks

Access tasks via:
- Press `Ctrl+Shift+P` (Windows/Linux) or `Cmd+Shift+P` (macOS)
- Type "Tasks: Run Task"
- Select task from list

Or use keyboard shortcuts for common tasks.

### Build Tasks

#### Build Standalone (Ninja Debug)

**Default build task** - Press `Ctrl+Shift+B`

Builds Debug configuration using Ninja for fast incremental builds.

**Output**: `build/ninja/YourTarget_artefacts/Debug/`

**Use for**: Daily development and testing

#### Build Standalone (Ninja Release)

Builds Release configuration with optimizations.

**Access**: `Ctrl+Shift+P` → Tasks: Run Task → Build Standalone (Ninja Release)

**Output**: `build/ninja/YourTarget_artefacts/Release/`

**Use for**: Performance testing and final builds before distribution

### Run Tasks

#### Run Standalone

Builds and runs the Debug standalone application.

**Access**: `Ctrl+Shift+P` → Tasks: Run Task → Run Standalone

**Dependencies**: Automatically runs "Build Standalone (Ninja Debug)" first

**Use for**: Quick testing after code changes

#### Run Standalone (Release)

Builds and runs the Release standalone application.

**Access**: `Ctrl+Shift+P` → Tasks: Run Task → Run Standalone (Release)

**Dependencies**: Automatically runs "Build Standalone (Ninja Release)" first

**Use for**: Testing optimized builds and performance validation

### Configuration Task

#### Configure Ninja

Reconfigures CMake when project structure changes.

**Access**: `Ctrl+Shift+P` → Tasks: Run Task → Configure Ninja

**Run when**:
- Changing `CMakeLists.txt`
- Adding or removing source files
- Modifying plugin metadata
- Changing build options

## Debugging Setup

### Prerequisites

Install platform-specific debugger:

**Windows**:
- Visual Studio 2022 includes MSVC debugger
- C/C++ extension for VS Code (Microsoft)

**macOS**:
- Install Xcode Command Line Tools
- CodeLLDB extension for VS Code

**Linux**:
- Install GDB: `sudo apt-get install gdb`
- C/C++ extension for VS Code (Microsoft)

### Launch Configuration

Create `.vscode/launch.json` for debugging:

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Debug Standalone (Windows)",
            "type": "cppvsdbg",
            "request": "launch",
            "program": "${workspaceFolder}/build/ninja/JucePlugin_artefacts/Debug/Standalone/DSP-JUCE Plugin.exe",
            "args": [],
            "stopAtEntry": false,
            "cwd": "${workspaceFolder}",
            "environment": [],
            "console": "integratedTerminal",
            "preLaunchTask": "Build Standalone (Ninja Debug)"
        },
        {
            "name": "Debug Standalone (macOS)",
            "type": "lldb",
            "request": "launch",
            "program": "${workspaceFolder}/build/ninja/JucePlugin_artefacts/Debug/Standalone/DSP-JUCE Plugin.app/Contents/MacOS/DSP-JUCE Plugin",
            "args": [],
            "cwd": "${workspaceFolder}",
            "preLaunchTask": "Build Standalone (Ninja Debug)"
        },
        {
            "name": "Debug Standalone (Linux)",
            "type": "cppdbg",
            "request": "launch",
            "program": "${workspaceFolder}/build/ninja/JucePlugin_artefacts/Debug/Standalone/DSP-JUCE Plugin",
            "args": [],
            "stopAtEntry": false,
            "cwd": "${workspaceFolder}",
            "environment": [],
            "externalConsole": false,
            "MIMode": "gdb",
            "preLaunchTask": "Build Standalone (Ninja Debug)"
        }
    ]
}
```

**Important**: Replace `"DSP-JUCE Plugin"` with your actual plugin name from `PLUGIN_NAME` in `CMakeLists.txt`.

### Using the Debugger

1. **Set breakpoints**: Click left of line numbers in source files
2. **Start debugging**: Press `F5` or Run → Start Debugging
3. **Debug controls**:
   - `F5`: Continue
   - `F10`: Step Over
   - `F11`: Step Into
   - `Shift+F11`: Step Out
   - `Shift+F5`: Stop

### Debugging Plugin in DAW

To debug plugin loaded in a DAW:

#### Windows

```json
{
    "name": "Attach to DAW (Windows)",
    "type": "cppvsdbg",
    "request": "attach",
    "processId": "${command:pickProcess}"
}
```

1. Start your DAW
2. Load the plugin in DAW
3. Press `F5` in VS Code
4. Select DAW process from list

#### macOS/Linux

```json
{
    "name": "Attach to DAW (macOS/Linux)",
    "type": "lldb",
    "request": "attach",
    "pid": "${command:pickMyProcess}"
}
```

Same steps as Windows.

## Recommended Extensions

### Essential Extensions

**C/C++ (Microsoft)**
- IntelliSense and code navigation
- Debugging support
- Install: `ms-vscode.cpptools`

**CMake Tools (Microsoft)**
- CMake project support
- Build configuration management
- Install: `ms-vscode.cmake-tools`

### Platform-Specific Extensions

**Windows**:
- C/C++ Extension Pack: `ms-vscode.cpptools-extension-pack`

**macOS**:
- CodeLLDB: `vadimcn.vscode-lldb`

**Linux**:
- C/C++ Extension Pack: `ms-vscode.cpptools-extension-pack`

### Optional Extensions

**Productivity**:
- GitLens: Enhanced Git integration
- Markdown All in One: Markdown editing and preview
- Better Comments: Highlight TODO, FIXME, etc.

**Code Quality**:
- Clang-Format: Code formatting
- Error Lens: Inline error messages
- Code Spell Checker: Catch typos in code and comments

## IntelliSense Configuration

VS Code should auto-detect CMake configuration. If IntelliSense is not working:

1. **Generate compile_commands.json**:

   CMake automatically generates this in `build/ninja/compile_commands.json`

2. **Configure C/C++ extension**:

   Create `.vscode/c_cpp_properties.json`:

   ```json
   {
       "configurations": [
           {
               "name": "Ninja",
               "compileCommands": "${workspaceFolder}/build/ninja/compile_commands.json",
               "cStandard": "c17",
               "cppStandard": "c++20",
               "intelliSenseMode": "windows-msvc-x64"
           }
       ],
       "version": 4
   }
   ```

   Change `intelliSenseMode` for your platform:
   - Windows: `windows-msvc-x64`
   - macOS: `macos-clang-x64`
   - Linux: `linux-gcc-x64`

3. **Reload VS Code**: Press `Ctrl+Shift+P` → "Reload Window"

## Workflow Tips

### Fast Edit-Build-Test Cycle

1. Edit source files
2. Press `Ctrl+Shift+B` to build (1-3 seconds)
3. Run "Run Standalone" task to test
4. Repeat

**Average cycle time**: 3-5 seconds for small changes

### Build Performance

**Ninja builds** are fastest:
- Configuration: ~1 second
- Incremental build: 1-3 seconds
- Full rebuild: 2-5 minutes

**Tips**:
- Use Debug builds for development (faster compilation)
- Use Release builds for performance testing
- Keep build directory on fast storage (SSD)

### Multi-Configuration Workflow

Work on Debug and Release simultaneously:

1. Configure Ninja: `scripts/configure-ninja.sh`
2. Build Debug: Press `Ctrl+Shift+B`
3. Build Release: Tasks → Build Standalone (Ninja Release)
4. Test both configurations as needed

Both configurations share the same build directory but different outputs.

## Troubleshooting

### Tasks Not Found

**Symptom**: Tasks menu is empty or tasks are missing

**Fix**:
1. Ensure `.vscode/tasks.json` exists
2. Reload VS Code: `Ctrl+Shift+P` → "Reload Window"
3. Check VS Code version (requires 1.70+)

### IntelliSense Errors

**Symptom**: Red squiggles in code, navigation not working

**Fix**:
1. Run "Configure Ninja" task
2. Install C/C++ extension
3. Reload VS Code
4. Check `.vscode/c_cpp_properties.json` configuration

### Debugger Not Starting

**Symptom**: Debugging fails to start or attach

**Fix**:
1. Install platform-specific debug extension
2. Check `launch.json` configuration
3. Verify executable path matches your plugin name
4. Ensure Debug build exists: Press `Ctrl+Shift+B`

### Build Fails

**Symptom**: Build task fails with errors

**Fix**:
1. Check CMakeLists.txt for syntax errors
2. Run "Configure Ninja" task
3. Review build output for specific errors
4. Ensure all prerequisites installed (see BUILD.md)

### Task Runs Wrong Configuration

**Symptom**: Debug task runs Release build or vice versa

**Fix**:
1. Check task name in tasks list
2. Verify `--config` argument in task definition
3. Clean and rebuild: Delete `build/ninja`, run "Configure Ninja"

## Keyboard Shortcuts

### Default Shortcuts

- `Ctrl+Shift+B`: Build (default build task)
- `F5`: Start debugging
- `Ctrl+Shift+P`: Command palette (access all tasks)
- `Ctrl+` `: Open integrated terminal

### Custom Shortcuts

Add to `.vscode/keybindings.json`:

```json
[
    {
        "key": "ctrl+shift+r",
        "command": "workbench.action.tasks.runTask",
        "args": "Run Standalone"
    },
    {
        "key": "ctrl+shift+alt+b",
        "command": "workbench.action.tasks.runTask",
        "args": "Build Standalone (Ninja Release)"
    }
]
```

## See Also

- [DEVELOPMENT_WORKFLOW.md](../DEVELOPMENT_WORKFLOW.md) - Development workflow and build system
- [BUILD.md](../BUILD.md) - Platform-specific build instructions
- [CUSTOMIZATION.md](../CUSTOMIZATION.md) - Plugin customization guide
- [docs/CROSS_PLATFORM_BUILDS.md](CROSS_PLATFORM_BUILDS.md) - Cross-platform build details
