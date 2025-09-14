#pragma once

#include <juce_audio_utils/juce_audio_utils.h>
#include <juce_dsp/juce_dsp.h>
#include <juce_gui_basics/juce_gui_basics.h>

//==============================================================================
class MainComponent : public juce::AudioAppComponent
{
public:
	//==============================================================================
	MainComponent();
	~MainComponent() override;

	//==============================================================================
	void prepareToPlay(int samplesPerBlockExpected, double sampleRate) override;
	void getNextAudioBlock(const juce::AudioSourceChannelInfo &bufferToFill) override;
	void releaseResources() override;

	//==============================================================================
	void paint(juce::Graphics &g) override;
	void resized() override;

private:
	//==============================================================================
	juce::dsp::Oscillator<float> oscillator{[](float x)
											{ return std::sin(x); }, 200};
	juce::dsp::Gain<float> gain;

	juce::Slider frequencySlider;
	juce::Label frequencyLabel;
	juce::Slider gainSlider;
	juce::Label gainLabel;

	JUCE_DECLARE_NON_COPYABLE_WITH_LEAK_DETECTOR(MainComponent)
};