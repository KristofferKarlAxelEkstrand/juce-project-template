#include "PluginEditor.h"

//==============================================================================
DSPJuceAudioProcessorEditor::DSPJuceAudioProcessorEditor(DSPJuceAudioProcessor& processor)
    : AudioProcessorEditor(&processor), audioProcessor(processor)
{
    setupControls();
    setSize(600, 150);
}

//==============================================================================
void DSPJuceAudioProcessorEditor::setupControls()
{
    // Frequency control setup
    addAndMakeVisible(frequencySlider);
    frequencySlider.setRange(MIN_FREQUENCY, MAX_FREQUENCY, 1.0);
    frequencySlider.setValue(static_cast<double>(audioProcessor.getFrequency()));
    frequencySlider.setSkewFactorFromMidPoint(1000.0); // Logarithmic scale
    frequencySlider.setTextBoxStyle(juce::Slider::TextBoxRight, false, 100, 20);
    frequencySlider.setTextValueSuffix(" Hz");
    frequencySlider.onValueChange = [this] {
        audioProcessor.setFrequency(static_cast<float>(frequencySlider.getValue()));
    };

    addAndMakeVisible(frequencyLabel);
    frequencyLabel.setText("Frequency", juce::dontSendNotification);
    frequencyLabel.attachToComponent(&frequencySlider, true);

    // Gain control setup
    addAndMakeVisible(gainSlider);
    gainSlider.setRange(MIN_GAIN, MAX_GAIN, 0.01);
    gainSlider.setValue(static_cast<double>(audioProcessor.getGain()));
    gainSlider.setTextBoxStyle(juce::Slider::TextBoxRight, false, 100, 20);
    gainSlider.onValueChange = [this] {
        audioProcessor.setGain(static_cast<float>(gainSlider.getValue()));
    };

    addAndMakeVisible(gainLabel);
    gainLabel.setText("Gain", juce::dontSendNotification);
    gainLabel.attachToComponent(&gainSlider, true);
}

//==============================================================================
void DSPJuceAudioProcessorEditor::paint(juce::Graphics& g)
{
    // Fill background with default window color
    g.fillAll(getLookAndFeel().findColour(juce::ResizableWindow::backgroundColourId));

    // Add subtle gradient for modern look
    auto bounds = getLocalBounds().toFloat();
    juce::ColourGradient gradient(juce::Colours::darkgrey.withAlpha(0.1f), bounds.getTopLeft(),
                                  juce::Colours::lightgrey.withAlpha(0.05f), bounds.getBottomRight(), false);
    g.setGradientFill(gradient);
    g.fillRoundedRectangle(bounds.reduced(5.0f), 8.0f);
}

void DSPJuceAudioProcessorEditor::resized()
{
    auto bounds = getLocalBounds().reduced(10);
    constexpr int sliderLabelWidth = 80;
    constexpr int sliderHeight = 20;
    constexpr int verticalSpacing = 30;

    // Position frequency control
    frequencySlider.setBounds(sliderLabelWidth, 15, bounds.getWidth() - sliderLabelWidth, sliderHeight);

    // Position gain control
    gainSlider.setBounds(sliderLabelWidth, 15 + verticalSpacing, bounds.getWidth() - sliderLabelWidth, sliderHeight);
}