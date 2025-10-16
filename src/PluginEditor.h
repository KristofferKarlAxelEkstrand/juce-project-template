#pragma once

#include "DSPJuceAudioProcessor.h"
#include <juce_audio_processors/juce_audio_processors.h>
#include <juce_gui_basics/juce_gui_basics.h>

/**
 * @brief AudioProcessorEditor for JUCE plugin template
 *
 * This editor provides an example GUI for controlling audio processor parameters.
 * It demonstrates modern JUCE patterns including:
 * - AudioProcessorValueTreeState attachments for automatic parameter binding
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

    // APVTS Attachments - automatically sync sliders with parameters
    std::unique_ptr<juce::AudioProcessorValueTreeState::SliderAttachment> frequencyAttachment;
    std::unique_ptr<juce::AudioProcessorValueTreeState::SliderAttachment> gainAttachment;

    //==============================================================================
    /**
     * @brief Initialize GUI controls with proper styling and ranges
     */
    void setupControls();

    JUCE_DECLARE_NON_COPYABLE_WITH_LEAK_DETECTOR(DSPJuceAudioProcessorEditor)
};