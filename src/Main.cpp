#include "MainComponent.h"
#include "PluginEditor.h"

/**
 * @brief JUCE plugin entry point
 *
 * This function creates and returns instances of the AudioProcessor.
 * JUCE automatically handles both plugin and standalone builds through
 * this single entry point.
 */
juce::AudioProcessor *JUCE_CALLTYPE createPluginFilter() { return new DSPJuceAudioProcessor(); }