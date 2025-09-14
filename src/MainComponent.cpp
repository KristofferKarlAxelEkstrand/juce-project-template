#include "MainComponent.h"

//==============================================================================
MainComponent::MainComponent()
{
	addAndMakeVisible(frequencySlider);
	frequencySlider.setRange(50.0, 5000.0);
	frequencySlider.setValue(440.0);
	frequencySlider.setTextBoxStyle(juce::Slider::TextBoxRight, false, 100, 20);
	frequencySlider.onValueChange = [this]
	{
		if (juce::MessageManager::getInstance()->isThisTheMessageThread())
			oscillator.setFrequency((float)frequencySlider.getValue());
	};

	addAndMakeVisible(frequencyLabel);
	frequencyLabel.setText("Frequency", juce::dontSendNotification);
	frequencyLabel.attachToComponent(&frequencySlider, true);

	addAndMakeVisible(gainSlider);
	gainSlider.setRange(0.0, 1.0);
	gainSlider.setValue(0.5);
	gainSlider.setTextBoxStyle(juce::Slider::TextBoxRight, false, 100, 20);
	gainSlider.onValueChange = [this]
	{
		if (juce::MessageManager::getInstance()->isThisTheMessageThread())
			gain.setGainLinear((float)gainSlider.getValue());
	};

	addAndMakeVisible(gainLabel);
	gainLabel.setText("Gain", juce::dontSendNotification);
	gainLabel.attachToComponent(&gainSlider, true);

	setSize(600, 150);
	setAudioChannels(0, 2); // no inputs, two outputs
}

MainComponent::~MainComponent()
{
	shutdownAudio();
}

//==============================================================================
void MainComponent::prepareToPlay(int samplesPerBlockExpected, double sampleRate)
{
	juce::dsp::ProcessSpec spec;
	spec.sampleRate = sampleRate;
	spec.maximumBlockSize = samplesPerBlockExpected;
	spec.numChannels = 2;

	oscillator.prepare(spec);
	oscillator.setFrequency((float)frequencySlider.getValue());

	gain.prepare(spec);
	gain.setGainLinear((float)gainSlider.getValue());
}

void MainComponent::getNextAudioBlock(const juce::AudioSourceChannelInfo &bufferToFill)
{
	auto *buffer = bufferToFill.buffer;
	juce::dsp::AudioBlock<float> block(*buffer);
	juce::dsp::ProcessContextReplacing<float> context(block);
	oscillator.process(context);
	gain.process(context);
}

void MainComponent::releaseResources()
{
	// This will be called when the audio device stops, or when it is being
	// restarted due to a setting change.

	// For more details, see the help for AudioProcessor::releaseResources()
}

//==============================================================================
void MainComponent::paint(juce::Graphics &g)
{
	g.fillAll(getLookAndFeel().findColour(juce::ResizableWindow::backgroundColourId));
}

void MainComponent::resized()
{
	auto bounds = getLocalBounds().reduced(10);
	auto sliderLabelWidth = 80;

	frequencySlider.setBounds(sliderLabelWidth, 10, bounds.getWidth() - sliderLabelWidth, 20);
	gainSlider.setBounds(sliderLabelWidth, 40, bounds.getWidth() - sliderLabelWidth, 20);
}