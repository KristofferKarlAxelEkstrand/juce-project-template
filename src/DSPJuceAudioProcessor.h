#pragma once

#include <juce_audio_processors/juce_audio_processors.h>
#include <juce_dsp/juce_dsp.h>

/**
 * @brief AudioProcessor for both plugin and standalone builds
 *
 * This processor provides an example audio synthesizer with frequency and gain controls.
 * It demonstrates modern JUCE patterns including:
 * - Real-time audio processing with juce::dsp modules
 * - Thread-safe parameter handling between GUI and audio threads
 * - Proper audio resource management
 * - Cross-platform plugin/standalone compatibility
 */
class DSPJuceAudioProcessor : public juce::AudioProcessor {
public:
    //==============================================================================
    DSPJuceAudioProcessor();
    ~DSPJuceAudioProcessor() override = default;

    //==============================================================================
    // AudioProcessor implementation
    void prepareToPlay(double sampleRate, int samplesPerBlock) override;
    void releaseResources() override;
    bool isBusesLayoutSupported(const BusesLayout &layouts) const override;
    void processBlock(juce::AudioBuffer<float> &buffer, juce::MidiBuffer &midiMessages) override;

    //==============================================================================
    // Editor creation
    juce::AudioProcessorEditor *createEditor() override;
    bool hasEditor() const override { return true; }

    //==============================================================================
    // Program and state management
    const juce::String getName() const override { return JucePlugin_Name; }
    bool acceptsMidi() const override { return false; }
    bool producesMidi() const override { return false; }
    bool isMidiEffect() const override { return false; }
    double getTailLengthSeconds() const override { return 0.0; }

    int getNumPrograms() override { return 1; }
    int getCurrentProgram() override { return 0; }
    void setCurrentProgram(int index) override { juce::ignoreUnused(index); }
    const juce::String getProgramName(int index) override {
        juce::ignoreUnused(index);
        return "Default";
    }
    void changeProgramName(int index, const juce::String &newName) override { juce::ignoreUnused(index, newName); }

    //==============================================================================
    // State save/restore
    void getStateInformation(juce::MemoryBlock &destData) override;
    void setStateInformation(const void *data, int sizeInBytes) override;

    //==============================================================================
    // Parameter access (thread-safe)
    void setFrequency(float frequency);
    void setGain(float gain);
    float getFrequency() const { return currentFrequency.load(); }
    float getGain() const { return currentGain.load(); }

private:
    //==============================================================================
    // DSP Components
    juce::dsp::Oscillator<float> oscillator{[](float x) { return std::sin(x); }, 200};
    juce::dsp::Gain<float> gain;

    // Thread-safe parameter storage
    std::atomic<float> currentFrequency{440.0f};
    std::atomic<float> currentGain{0.5f};

    // Constants
    static constexpr float MIN_FREQUENCY = 50.0f;
    static constexpr float MAX_FREQUENCY = 5000.0f;
    static constexpr float DEFAULT_FREQUENCY = 440.0f;
    static constexpr float MIN_GAIN = 0.0f;
    static constexpr float MAX_GAIN = 1.0f;
    static constexpr float DEFAULT_GAIN = 0.5f;

    JUCE_DECLARE_NON_COPYABLE_WITH_LEAK_DETECTOR(DSPJuceAudioProcessor)
};