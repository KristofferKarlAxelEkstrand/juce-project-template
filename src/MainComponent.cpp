#include "MainComponent.h"
#include "PluginEditor.h"

//==============================================================================
DSPJuceAudioProcessor::DSPJuceAudioProcessor()
    : AudioProcessor(BusesProperties().withOutput("Output", juce::AudioChannelSet::stereo(), true)) {
    // Initialize parameters with default values
    currentFrequency.store(DEFAULT_FREQUENCY);
    currentGain.store(DEFAULT_GAIN);
}

//==============================================================================
void DSPJuceAudioProcessor::prepareToPlay(double sampleRate, int samplesPerBlock) {
    // Initialize DSP processing specs
    juce::dsp::ProcessSpec spec;
    spec.sampleRate = sampleRate;
    spec.maximumBlockSize = static_cast<juce::uint32>(samplesPerBlock);
    spec.numChannels = static_cast<juce::uint32>(getTotalNumOutputChannels());

    // Prepare DSP components
    oscillator.prepare(spec);
    oscillator.setFrequency(currentFrequency.load());

    gain.prepare(spec);
    gain.setGainLinear(currentGain.load());
}

void DSPJuceAudioProcessor::releaseResources() {
    // Called when audio device stops or settings change
    // DSP components automatically handle cleanup
}

bool DSPJuceAudioProcessor::isBusesLayoutSupported(const BusesLayout &layouts) const {
    // Support stereo output only
    if (layouts.getMainOutputChannelSet() != juce::AudioChannelSet::stereo())
        return false;

    return true;
}

void DSPJuceAudioProcessor::processBlock(juce::AudioBuffer<float> &buffer, juce::MidiBuffer &midiMessages) {
    juce::ignoreUnused(midiMessages);

    juce::ScopedNoDenormals noDenormals;
    auto totalNumInputChannels = getTotalNumInputChannels();
    auto totalNumOutputChannels = getTotalNumOutputChannels();

    // Clear any input channels that don't contain input data
    for (auto i = totalNumInputChannels; i < totalNumOutputChannels; ++i)
        buffer.clear(i, 0, buffer.getNumSamples());

    // Update DSP parameters if they changed
    oscillator.setFrequency(currentFrequency.load());
    gain.setGainLinear(currentGain.load());

    // Process audio using modern JUCE DSP chain
    juce::dsp::AudioBlock<float> block(buffer);
    juce::dsp::ProcessContextReplacing<float> context(block);

    // Apply oscillator then gain
    oscillator.process(context);
    gain.process(context);
}

//==============================================================================
juce::AudioProcessorEditor *DSPJuceAudioProcessor::createEditor() { return new DSPJuceAudioProcessorEditor(*this); }

//==============================================================================
void DSPJuceAudioProcessor::setFrequency(float frequency) {
    currentFrequency.store(juce::jlimit(MIN_FREQUENCY, MAX_FREQUENCY, frequency));
}

void DSPJuceAudioProcessor::setGain(float gainValue) { currentGain.store(juce::jlimit(MIN_GAIN, MAX_GAIN, gainValue)); }

//==============================================================================
void DSPJuceAudioProcessor::getStateInformation(juce::MemoryBlock &destData) {
    // Create XML with current parameter values
    juce::XmlElement xml(JucePlugin_Name);
    xml.setAttribute("frequency", static_cast<double>(currentFrequency.load()));
    xml.setAttribute("gain", static_cast<double>(currentGain.load()));
    copyXmlToBinary(xml, destData);
}

void DSPJuceAudioProcessor::setStateInformation(const void *data, int sizeInBytes) {
    // Restore parameter values from XML
    std::unique_ptr<juce::XmlElement> xmlState = getXmlFromBinary(data, sizeInBytes);

    if (xmlState.get() != nullptr && xmlState->hasTagName(JucePlugin_Name)) {
        currentFrequency.store(static_cast<float>(xmlState->getDoubleAttribute("frequency", DEFAULT_FREQUENCY)));
        currentGain.store(static_cast<float>(xmlState->getDoubleAttribute("gain", DEFAULT_GAIN)));
    }
}