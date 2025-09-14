# JUCE Audio Development Environment

This repository is a modern JUCE 8.0.9 audio development environment designed for creating professional audio plugins,
instruments, and effects with CMake build system integration.

## Core Development Principles

- **Modern JUCE Architecture**: Focus on JUCE 8.0.9+ features and best practices
- **Plugin-First Design**: Prioritize audio plugin development (VST3, AU, AAX, Standalone)
- **Performance Focused**: Optimize for real-time audio processing and low latency
- **Cross-Platform Compatibility**: Support Windows, macOS, and Linux development
- **Professional Quality**: Follow industry standards for audio plugin development

## Project Structure

- **Root**: Contains CMakeLists.txt using JUCE 8.0.9 with FetchContent approach
- **src/**: Audio source code directory
  - `Main.cpp`: Application entry point and main window setup
  - `MainComponent.h/cpp`: Core audio component with real-time processing
- **build/**: CMake build output directory (auto-generated)
- **.github/**: Development environment customization
  - `copilot-instructions.md`: This file - JUCE development guidance
  - `prompts/`: Audio development prompt templates
  - `instructions/`: File-specific coding standards and practices

## Build System

Always run commands in this exact order:

1. `cmake --preset=default` (configure build using CMakePresets.json)
2. `cmake --build --preset=default` (build using MSVC on Windows)
3. Run executable from `build/Debug/SimpleJuceApp.exe`

**Key Points:**

- Never use manual JUCE cloning - the project uses CMake FetchContent to automatically download JUCE 8.0.9
- Build system supports multiple plugin formats: VST3, AU, AAX, Standalone
- CMake handles all JUCE module linking and platform-specific configurations
- Cross-platform builds supported (Windows, macOS, Linux)

## Audio Development Methodology

### Design Phase (Audio-First)

Before implementing any audio feature:

1. **Audio Requirements**: Define sample rates, buffer sizes, latency requirements
2. **DSP Architecture**: Plan signal flow, processing chains, and algorithms
3. **Real-Time Constraints**: Consider thread safety and real-time audio processing
4. **Plugin Format Requirements**: Understand VST3, AU, AAX specifications
5. **Performance Profiling**: Plan for CPU usage and memory allocation patterns

### Implementation Phase (Real-Time Focus)

1. **Audio Thread Safety**: Implement lock-free programming patterns
2. **Buffer Management**: Proper audio buffer handling and processing
3. **Parameter Automation**: Smooth parameter changes without clicks/pops
4. **State Management**: Plugin state saving/loading and preset management
5. **GUI-Audio Separation**: Decouple UI from audio processing threads

### Testing Phase (Audio Quality)

1. **Audio Unit Testing**: Verify DSP algorithms and signal processing
2. **Real-Time Performance**: Test under various buffer sizes and sample rates
3. **Plugin Validation**: Test in multiple DAWs and host applications
4. **Cross-Platform Testing**: Validate on Windows, macOS, and Linux
5. **Stress Testing**: CPU load, memory usage, and stability under load

## JUCE Development Standards

### Audio Programming Best Practices

- **Real-Time Safety**: Avoid memory allocation, file I/O, or blocking operations in audio threads
- **Thread Safety**: Use atomic operations and lock-free programming for audio parameter access
- **Performance Focus**: Optimize for low CPU usage and minimal memory footprint
- **JUCE Conventions**: Follow JUCE coding standards and naming conventions
- **Modern C++**: Use C++17 features and RAII patterns

### Plugin Development Guidelines

When creating JUCE plugins:

1. **AudioProcessor Subclass**: Implement proper processBlock, prepareToPlay, and releaseResources
2. **Parameter Management**: Use AudioParameterFloat, AudioParameterChoice for automatable parameters
3. **Editor Components**: Separate GUI logic from audio processing completely
4. **State Management**: Implement getStateInformation and setStateInformation properly
5. **Format Compatibility**: Test across VST3, AU, AAX, and Standalone formats

### Code Quality Requirements

- **Real-Time Constraints**: No dynamic allocation in audio callbacks
- **JUCE Module Usage**: Properly link and use JUCE modules (audio_processors, gui_basics, etc.)
- **Memory Management**: Use JUCE's reference counting and smart pointers
- **Cross-Platform Code**: Ensure compatibility across Windows, macOS, and Linux
- **Professional Audio Standards**: Follow industry best practices for plugin development

## Technology Context

This project demonstrates modern JUCE development practices:

- JUCE Framework 8.0.9 (latest stable)
- CMake with FetchContent for dependency management
- Visual Studio Build Tools / MSVC compiler
- Git with proper .gitignore excluding build artifacts
- VS Code integration via CMake Tools extension

## JUCE Module Integration

The project uses these core JUCE modules:

- **juce_gui_basics**: GUI components and windowing
- **juce_audio_utils**: High-level audio utilities and AudioAppComponent
- **juce_audio_processors**: Plugin hosting and AudioProcessor base class
- **juce_audio_devices**: Audio device management and I/O
- **juce_dsp**: Digital signal processing utilities and algorithms

## Audio Development Examples

When working with JUCE audio development:

1. **Plugin Creation**: Use juce_add_plugin() in CMake for VST3/AU/AAX formats
2. **DSP Implementation**: Implement processBlock() for real-time audio processing
3. **UI Development**: Create AudioProcessorEditor subclasses for plugin interfaces
4. **Parameter Management**: Use AudioProcessor::addParameter() for automatable controls
5. **State Handling**: Implement getStateInformation() and setStateInformation() properly

## Audio Development Anti-Patterns

- Allocating memory in processBlock() or other real-time contexts
- Using blocking operations (file I/O, network) in audio threads
- Ignoring sample rate changes in prepareToPlay()
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
