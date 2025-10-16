# JUCE AudioPluginHost Basics

JUCE AudioPluginHost is a lightweight application for testing and debugging audio plugins (VST3, AU, etc.) without
needing a full DAW.

## What is AudioPluginHost?

- A standalone app included with the JUCE SDK.
- Lets you load, connect, and test plugins in real time.
- Supports VST3, AU (macOS), and internal JUCE plugins.

## Installation

The `AudioPluginHost` is included with the JUCE source code in this project. You need to build it yourself using the
Projucer tool, which is also included. This is the standard, recommended method.

### Step 1: Build the Projucer Tool

The Projucer is JUCE's project management tool, and you need it to create the build files for the AudioPluginHost.

1. **Navigate to the Projucer build directory for your OS.** For Windows with Visual Studio 2022, this is:
   `third_party/JUCE/extras/Projucer/Builds/VisualStudio2022/`

2. **Open `Projucer.sln`** in Visual Studio.

3. **Build the solution** (Right-click the project in the Solution Explorer and select "Build"). This will create
   `Projucer.exe` inside a `Builds/` subdirectory within that folder.

### Step 2: Build the AudioPluginHost

Now that you have the Projucer, you can build the AudioPluginHost.

1. **Run the `Projucer.exe`** you just built.

2. From the Projucer, go to **File > Open...** and select the `AudioPluginHost.jucer` file located at:
   `third_party/JUCE/extras/AudioPluginHost/AudioPluginHost.jucer`

3. **Save the project.** In the Projucer, go to **File > Save Project**. This will generate a new Visual Studio solution
   (`.sln`) for the AudioPluginHost in its own `Builds` directory.

4. **Open the new solution** (e.g., `extras/AudioPluginHost/Builds/VisualStudio2022/AudioPluginHost.sln`) in Visual
   Studio.

5. **Build the solution.** This will create `AudioPluginHost.exe`, which you can now run to test your plugins.

## How to Use

1. Launch AudioPluginHost.
2. Go to `Options > Plugin Folders` and add the folder containing your built plugin (e.g.,
   `build/default/JucePlugin_artefacts/Debug/VST3`).
3. Click `Options > Scan for Plugins` to refresh the list.
4. Drag your plugin from the list into the graph area to test.
5. You can connect plugins, test audio/MIDI, and debug UI and parameter changes.

## Best Practices

- Use AudioPluginHost for rapid plugin format testing before moving to a full DAW.
- After each build, re-scan plugins or reload the plugin window to see changes.
- For VST3, make sure your plugin is in a scanned folder and has the `.vst3` extension.

## Troubleshooting

- If your plugin does not appear, check the plugin folder path and re-scan.
- If the plugin fails to load, check for build errors or missing dependencies.
