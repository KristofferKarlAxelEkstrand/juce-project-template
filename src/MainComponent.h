#pragma once

#include <juce_audio_utils/juce_audio_utils.h>
#include <juce_dsp/juce_dsp.h>
#include <juce_gui_basics/juce_gui_basics.h>

/**
 * @brief Main audio component demonstrating real-time DSP with JUCE
 * 
 * This component provides a simple audio synthesizer with frequency and gain controls.
 * It demonstrates modern JUCE patterns including:
 * - Real-time audio processing with juce::dsp modules
 * - Thread-safe parameter handling between GUI and audio threads
 * - Proper audio resource management
 */
class MainComponent : public juce::AudioAppComponent
{
public:
    //==============================================================================
    MainComponent();
    ~MainComponent() override;

    //==============================================================================
    // AudioAppComponent overrides
    void prepareToPlay(int samplesPerBlockExpected, double sampleRate) override;
    void getNextAudioBlock(const juce::AudioSourceChannelInfo &bufferToFill) override;
    void releaseResources() override;

    //==============================================================================
    // Component overrides
    void paint(juce::Graphics &g) override;
    void resized() override;

private:
    //==============================================================================
    // DSP Components
    juce::dsp::Oscillator<float> oscillator{[](float x) { return std::sin(x); }, 200};
    juce::dsp::Gain<float> gain;

    // GUI Components
    juce::Slider frequencySlider;
    juce::Label frequencyLabel;
    juce::Slider gainSlider;
    juce::Label gainLabel;

    // Constants
    static constexpr double MIN_FREQUENCY = 50.0;
    static constexpr double MAX_FREQUENCY = 5000.0;
    static constexpr double DEFAULT_FREQUENCY = 440.0;
    static constexpr double MIN_GAIN = 0.0;
    static constexpr double MAX_GAIN = 1.0;
    static constexpr double DEFAULT_GAIN = 0.5;

    //==============================================================================
    /**
     * @brief Initialize GUI controls with proper styling and ranges
     */
    void setupControls();

    JUCE_DECLARE_NON_COPYABLE_WITH_LEAK_DETECTOR(MainComponent)
};