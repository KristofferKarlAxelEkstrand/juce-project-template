#include "MainComponent.h"

/**
 * @brief Simple JUCE audio application demonstrating modern C++ and DSP practices
 * 
 * This application showcases:
 * - Modern JUCE 8.0+ patterns and architecture
 * - Real-time audio processing with thread safety
 * - Clean separation between GUI and audio threads
 * - Modern C++20 features and best practices
 */
class SimpleJuceAppApplication : public juce::JUCEApplication
{
public:
    //==============================================================================
    SimpleJuceAppApplication() = default;

    const juce::String getApplicationName() override { return "Simple JUCE App"; }
    const juce::String getApplicationVersion() override { return "1.0.0"; }
    bool moreThanOneInstanceAllowed() override { return true; }

    //==============================================================================
    void initialise(const juce::String &commandLine) override
    {
        juce::ignoreUnused(commandLine);
        
        // Create main window with modern initialization
        mainWindow = std::make_unique<MainWindow>(getApplicationName());
    }

    void shutdown() override
    {
        // Clean shutdown - RAII handles cleanup automatically
        mainWindow.reset();
    }

    //==============================================================================
    void systemRequestedQuit() override
    {
        // Allow graceful shutdown
        quit();
    }

    void anotherInstanceStarted(const juce::String &commandLine) override
    {
        // Handle multiple instances if needed
        juce::ignoreUnused(commandLine);
    }

private:
    //==============================================================================
    /**
     * @brief Main application window containing the audio component
     * 
     * This window provides the desktop container for our MainComponent
     * and handles window-specific behavior like resizing and closing.
     */
    class MainWindow : public juce::DocumentWindow
    {
    public:
        explicit MainWindow(const juce::String &name)
            : DocumentWindow(name,
                           juce::Desktop::getInstance().getDefaultLookAndFeel()
                               .findColour(juce::ResizableWindow::backgroundColourId),
                           DocumentWindow::allButtons)
        {
            setUsingNativeTitleBar(true);
            setContentOwned(new MainComponent(), true);

            // Platform-specific window setup
#if JUCE_IOS || JUCE_ANDROID
            setFullScreen(true);
#else
            setResizable(true, true);
            centreWithSize(getWidth(), getHeight());
#endif

            setVisible(true);
        }

        void closeButtonPressed() override
        {
            // Request application shutdown when window is closed
            JUCEApplication::getInstance()->systemRequestedQuit();
        }

    private:
        JUCE_DECLARE_NON_COPYABLE_WITH_LEAK_DETECTOR(MainWindow)
    };

    //==============================================================================
    std::unique_ptr<MainWindow> mainWindow;
};

//==============================================================================
// Application entry point - generates main() function
START_JUCE_APPLICATION(SimpleJuceAppApplication)