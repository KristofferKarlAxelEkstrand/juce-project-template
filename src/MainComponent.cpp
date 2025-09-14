#include "MainComponent.h"

//==============================================================================
MainComponent::MainComponent() {
    setupControls();
    setSize(600, 150);
    setAudioChannels(0, 2); // no inputs, stereo output
}

MainComponent::~MainComponent()
{
    shutdownAudio();
}

//==============================================================================
void MainComponent::setupControls() {
    // Frequency control setup
    addAndMakeVisible(frequencySlider);
    frequencySlider.setRange(MIN_FREQUENCY, MAX_FREQUENCY, 1.0);
    frequencySlider.setValue(DEFAULT_FREQUENCY);
    frequencySlider.setSkewFactorFromMidPoint(1000.0); // Logarithmic scale
    frequencySlider.setTextBoxStyle(juce::Slider::TextBoxRight, false, 100, 20);
    frequencySlider.setTextValueSuffix(" Hz");
    frequencySlider.onValueChange = [this] {
        // Thread-safe parameter update - only update if on message thread
        if (juce::MessageManager::getInstance()->isThisTheMessageThread()) {
            oscillator.setFrequency(static_cast<float>(frequencySlider.getValue()));
        }
    };

    addAndMakeVisible(frequencyLabel);
    frequencyLabel.setText("Frequency", juce::dontSendNotification);
    frequencyLabel.attachToComponent(&frequencySlider, true);

    // Gain control setup
    addAndMakeVisible(gainSlider);
    gainSlider.setRange(MIN_GAIN, MAX_GAIN, 0.01);
    gainSlider.setValue(DEFAULT_GAIN);
    gainSlider.setTextBoxStyle(juce::Slider::TextBoxRight, false, 100, 20);
    gainSlider.onValueChange = [this] {
        // Thread-safe parameter update
        if (juce::MessageManager::getInstance()->isThisTheMessageThread()) {
            gain.setGainLinear(static_cast<float>(gainSlider.getValue()));
        }
    };

    addAndMakeVisible(gainLabel);
    gainLabel.setText("Gain", juce::dontSendNotification);
    gainLabel.attachToComponent(&gainSlider, true);
}

//==============================================================================
void MainComponent::prepareToPlay(int samplesPerBlockExpected, double sampleRate) {
    // Initialize DSP processing specs
    juce::dsp::ProcessSpec spec;
    spec.sampleRate = sampleRate;
    spec.maximumBlockSize = static_cast<juce::uint32>(samplesPerBlockExpected);
    spec.numChannels = 2;

    // Prepare DSP components
    oscillator.prepare(spec);
    oscillator.setFrequency(static_cast<float>(frequencySlider.getValue()));

    gain.prepare(spec);
    gain.setGainLinear(static_cast<float>(gainSlider.getValue()));
}

void MainComponent::getNextAudioBlock(const juce::AudioSourceChannelInfo &bufferToFill) {
    // Process audio using modern JUCE DSP chain
    auto *buffer = bufferToFill.buffer;
    juce::dsp::AudioBlock<float> block(*buffer);
    juce::dsp::ProcessContextReplacing<float> context(block);

    // Apply oscillator then gain
    oscillator.process(context);
    gain.process(context);
}

void MainComponent::releaseResources() {
    // Called when audio device stops or settings change
    // DSP components automatically handle cleanup
}

//==============================================================================
void MainComponent::paint(juce::Graphics &g) {
    // Fill background with default window color
    g.fillAll(getLookAndFeel().findColour(juce::ResizableWindow::backgroundColourId));

    // Add subtle gradient for modern look
    auto bounds = getLocalBounds().toFloat();
    juce::ColourGradient gradient(juce::Colours::darkgrey.withAlpha(0.1f), bounds.getTopLeft(),
                                  juce::Colours::lightgrey.withAlpha(0.05f), bounds.getBottomRight(), false);
    g.setGradientFill(gradient);
    g.fillRoundedRectangle(bounds.reduced(5.0f), 8.0f);
}

void MainComponent::resized() {
    auto bounds = getLocalBounds().reduced(10);
    constexpr int sliderLabelWidth = 80;
    constexpr int sliderHeight = 20;
    constexpr int verticalSpacing = 30;

    // Position frequency control
    frequencySlider.setBounds(sliderLabelWidth, 15, bounds.getWidth() - sliderLabelWidth, sliderHeight);

    // Position gain control
    gainSlider.setBounds(sliderLabelWidth, 15 + verticalSpacing, bounds.getWidth() - sliderLabelWidth, sliderHeight);
}