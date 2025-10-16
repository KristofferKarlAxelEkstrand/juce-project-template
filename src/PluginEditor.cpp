#include "PluginEditor.h"

//==============================================================================
DSPJuceAudioProcessorEditor::DSPJuceAudioProcessorEditor(DSPJuceAudioProcessor &processor)
    : AudioProcessorEditor(processor), audioProcessor(processor) {
    setupControls();
    setSize(600, 150);
}

//==============================================================================
void DSPJuceAudioProcessorEditor::setupControls() {
    // Frequency control setup
    addAndMakeVisible(frequencySlider);
    frequencySlider.setSliderStyle(juce::Slider::LinearHorizontal);
    frequencySlider.setTextBoxStyle(juce::Slider::TextBoxRight, false, 100, 20);
    frequencySlider.setTextValueSuffix(" Hz");
    frequencySlider.setSkewFactorFromMidPoint(1000.0);

    addAndMakeVisible(frequencyLabel);
    frequencyLabel.setText("Frequency", juce::dontSendNotification);
    frequencyLabel.attachToComponent(&frequencySlider, true);

    // Create APVTS attachment for frequency
    frequencyAttachment = std::make_unique<juce::AudioProcessorValueTreeState::SliderAttachment>(
        audioProcessor.parameters, 
        DSPJuceAudioProcessor::PARAM_ID_FREQUENCY, 
        frequencySlider);

    // Gain control setup
    addAndMakeVisible(gainSlider);
    gainSlider.setSliderStyle(juce::Slider::LinearHorizontal);
    gainSlider.setTextBoxStyle(juce::Slider::TextBoxRight, false, 100, 20);

    addAndMakeVisible(gainLabel);
    gainLabel.setText("Gain", juce::dontSendNotification);
    gainLabel.attachToComponent(&gainSlider, true);

    // Create APVTS attachment for gain
    gainAttachment = std::make_unique<juce::AudioProcessorValueTreeState::SliderAttachment>(
        audioProcessor.parameters, 
        DSPJuceAudioProcessor::PARAM_ID_GAIN, 
        gainSlider);
}

//==============================================================================
void DSPJuceAudioProcessorEditor::paint(juce::Graphics &g) {
    // Fill background with default window color
    g.fillAll(getLookAndFeel().findColour(juce::ResizableWindow::backgroundColourId));

    // Add subtle gradient for modern look
    auto bounds = getLocalBounds().toFloat();
    juce::ColourGradient gradient(juce::Colours::darkgrey.withAlpha(0.1f), bounds.getTopLeft(),
                                  juce::Colours::lightgrey.withAlpha(0.05f), bounds.getBottomRight(), false);
    g.setGradientFill(gradient);
    g.fillRoundedRectangle(bounds.reduced(5.0f), 8.0f);
}

void DSPJuceAudioProcessorEditor::resized() {
    auto bounds = getLocalBounds().reduced(10);
    constexpr int sliderLabelWidth = 80;
    constexpr int sliderHeight = 20;
    constexpr int verticalSpacing = 30;

    // Position frequency control
    frequencySlider.setBounds(sliderLabelWidth, 15, bounds.getWidth() - sliderLabelWidth, sliderHeight);

    // Position gain control
    gainSlider.setBounds(sliderLabelWidth, 15 + verticalSpacing, bounds.getWidth() - sliderLabelWidth, sliderHeight);
}