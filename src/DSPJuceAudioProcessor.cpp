#include "DSPJuceAudioProcessor.h"
#include "PluginEditor.h"

//==============================================================================
juce::AudioProcessorValueTreeState::ParameterLayout DSPJuceAudioProcessor::createParameterLayout() {
    juce::AudioProcessorValueTreeState::ParameterLayout layout;

    // Add frequency parameter with logarithmic scaling
    layout.add(std::make_unique<juce::AudioParameterFloat>(
        juce::ParameterID{PARAM_ID_FREQUENCY, 1},
        "Frequency",
        juce::NormalisableRange<float>(MIN_FREQUENCY, MAX_FREQUENCY, 0.01f, 0.25f),
        DEFAULT_FREQUENCY,
        juce::AudioParameterFloatAttributes().withLabel("Hz")));

    // Add gain parameter
    layout.add(std::make_unique<juce::AudioParameterFloat>(
        juce::ParameterID{PARAM_ID_GAIN, 1},
        "Gain",
        juce::NormalisableRange<float>(MIN_GAIN, MAX_GAIN, 0.01f),
        DEFAULT_GAIN,
        juce::AudioParameterFloatAttributes().withLabel("Linear")));

    return layout;
}

//==============================================================================
DSPJuceAudioProcessor::DSPJuceAudioProcessor()
    : AudioProcessor(BusesProperties().withOutput("Output", juce::AudioChannelSet::stereo(), true)),
      parameters(*this, nullptr, "Parameters", createParameterLayout()) {
    // Cache parameter pointers for real-time performance
    frequencyParam = parameters.getRawParameterValue(PARAM_ID_FREQUENCY);
    gainParam = parameters.getRawParameterValue(PARAM_ID_GAIN);
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
    gain.prepare(spec);

    // Set initial parameter values
    if (frequencyParam != nullptr)
        oscillator.setFrequency(frequencyParam->load());
    
    if (gainParam != nullptr)
        gain.setGainLinear(gainParam->load());
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

    // Update DSP parameters using cached pointers for real-time performance
    if (frequencyParam != nullptr)
        oscillator.setFrequency(frequencyParam->load());
    
    if (gainParam != nullptr)
        gain.setGainLinear(gainParam->load());

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
void DSPJuceAudioProcessor::getStateInformation(juce::MemoryBlock &destData) {
    // APVTS handles state save automatically via ValueTree
    auto state = parameters.copyState();
    std::unique_ptr<juce::XmlElement> xml(state.createXml());
    copyXmlToBinary(*xml, destData);
}

void DSPJuceAudioProcessor::setStateInformation(const void *data, int sizeInBytes) {
    // APVTS handles state restore automatically via ValueTree
    std::unique_ptr<juce::XmlElement> xmlState(getXmlFromBinary(data, sizeInBytes));

    if (xmlState.get() != nullptr)
        if (xmlState->hasTagName(parameters.state.getType()))
            parameters.replaceState(juce::ValueTree::fromXml(*xmlState));
}
