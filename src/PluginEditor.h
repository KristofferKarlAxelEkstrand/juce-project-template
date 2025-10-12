#pragma once

#include "DSPJuceAudioProcessor.h"
#include <juce_audio_processors/juce_audio_processors.h>
#include <juce_gui_basics/juce_gui_basics.h>

/**
 * @brief AudioProcessorEditor for JUCE plugin template
 *
 * This editor provides an example GUI for controlling audio processor parameters.
 * It demonstrates modern JUCE patterns including:
 * - Thread-safe parameter control between GUI and audio threads
 * - Modern visual design with gradients and proper spacing
 * - Real-time responsiveness with immediate audio parameter updates
 */
class DSPJuceAudioProcessorEditor : public juce::AudioProcessorEditor {
public:
    //==============================================================================
    explicit DSPJuceAudioProcessorEditor(DSPJuceAudioProcessor &processor);
    ~DSPJuceAudioProcessorEditor() override = default;

    //==============================================================================
    // Component overrides
    void paint(juce::Graphics &g) override;
    void resized() override;

private:
    //==============================================================================
    // Reference to the processor
    DSPJuceAudioProcessor &audioProcessor;

    // GUI Components
    juce::Slider frequencySlider;
    juce::Label frequencyLabel;
    juce::Slider gainSlider;
    juce::Label gainLabel;

    // Constants
    static constexpr double MIN_FREQUENCY = 50.0;
    static constexpr double MAX_FREQUENCY = 5000.0;
    static constexpr double MIN_GAIN = 0.0;
    static constexpr double MAX_GAIN = 1.0;

    //==============================================================================
    /**
     * @brief Initialize GUI controls with proper styling and ranges
     */
    void setupControls();

    JUCE_DECLARE_NON_COPYABLE_WITH_LEAK_DETECTOR(DSPJuceAudioProcessorEditor)
};