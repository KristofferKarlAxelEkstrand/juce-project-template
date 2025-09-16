# JUCE in this Project

JUCE (Jules' Utility Class Extensions) is a C++ framework for creating cross-platform audio applications and plugins. This project uses JUCE 8 to provide a robust foundation for its audio processing and GUI features.

## Core JUCE Concepts Used

This project demonstrates several key JUCE classes and design patterns:

- **`juce::AudioProcessor`**: The heart of the plugin (`DSPJuceAudioProcessor`). It manages the audio processing, parameters, and state.
- **`juce::AudioProcessorEditor`**: The base class for the plugin's GUI (`DSPJuceAudioProcessorEditor`). It provides the user interface for interacting with the processor.
- **`juce::dsp` Module**: The project uses the `juce::dsp::Oscillator` and `juce::dsp::Gain` classes for its audio synthesis. This module provides a set of high-performance, real-time safe DSP building blocks.
- **Parameter Management**: The communication between the editor and the processor is handled thread-safely using `std::atomic` variables. This is a crucial pattern for preventing audio glitches when parameters are changed from the GUI.
- **Plugin Formats**: JUCE handles the complexities of building for different plugin formats (VST3, AU) and as a standalone application from a single codebase.

## Real-Time Safety

A critical concept in audio development is **real-time safety**. The audio thread, which runs the `processBlock` function in `MainComponent.cpp`, has strict performance requirements. To avoid audio dropouts, this thread must not perform any operations that could block or take an unpredictable amount of time, such as:

- Memory allocation (`new`, `malloc`)
- Locking mutexes
- File I/O
- Waiting on a condition variable

This project adheres to these rules by performing all setup in `prepareToPlay` and using lock-free techniques (`std::atomic`) for communication.