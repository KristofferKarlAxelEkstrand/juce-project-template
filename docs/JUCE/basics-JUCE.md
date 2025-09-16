# JUCE Framework in this Project

JUCE (Jules' Utility Class Extensions) is a C++ framework for cross-platform audio
applications and plugins. This project uses JUCE 8.0.9 with modern CMake integration.

## Key JUCE Classes Used

**Core Audio Components**:

- **`juce::AudioProcessor`** (`MainComponent`): Handles audio processing, parameters, and plugin state
- **`juce::AudioProcessorEditor`** (`PluginEditor`): Provides GUI interface and parameter controls
- **`juce::dsp::Oscillator`**: High-performance sine wave generator
- **`juce::dsp::Gain`**: Real-time safe gain control
- **`juce::AudioProcessorValueTreeState`**: Thread-safe parameter management

**Architecture Benefits**:

- **Single Codebase**: Builds VST3, AU (macOS), and standalone from same source
- **Cross-Platform**: Windows, macOS, Linux support with native look-and-feel  
- **Real-Time Safe**: Built-in protections against audio dropouts and memory allocation
- **Professional Grade**: Used in commercial audio software worldwide

## Real-Time Safety Critical Concepts

**The Audio Thread** (`MainComponent::getNextAudioBlock`) must complete within ~10ms to prevent dropouts.

**FORBIDDEN in Audio Thread**:

- Memory allocation (`new`, `malloc`, `std::vector::push_back`)
- Mutex locking (`std::mutex::lock`)
- File I/O operations
- Network requests
- Dynamic memory operations

**SAFE Practices Used**:

- **Pre-allocation**: All buffers allocated in `prepareToPlay()`
- **Lock-Free Communication**: `std::atomic` for parameter updates
- **Stack Variables**: Local variables for temporary calculations
- **JUCE DSP Modules**: Pre-validated real-time safe components

**Implementation Example**:

```cpp
// SAFE: Atomic parameter read
float currentFreq = frequency.load();

// SAFE: Stack-based calculation  
auto* leftChannel = buffer.getWritePointer(0);

// UNSAFE: Dynamic allocation
// auto newBuffer = std::make_unique<float[]>(numSamples); // DON'T DO THIS
```
