# C++ in this Project

This project is written in modern C++20, a version of the C++ language that provides numerous features for writing safer, cleaner, and more efficient code.

## Why C++ for Audio?

- **Performance**: C++ provides low-level control over system resources, which is critical for real-time audio processing where low latency and high efficiency are required.
- **Control**: It allows for precise memory management, preventing common audio issues like dropouts and glitches.
- **Ecosystem**: C++ is the language of the JUCE framework and is the industry standard for professional audio software development.

## C++20 Features Used

This project leverages several modern C++20 features:

- **`std::atomic`**: Used for thread-safe communication between the GUI and the real-time audio thread, ensuring that parameters can be updated without causing data races or audio artifacts.
- **Lambda Expressions**: Used for concisely defining callback functions, such as for GUI slider updates.
- **`constexpr`**: Used to define constants that can be evaluated at compile-time, improving performance.
- **Structured Bindings**: Used for cleaner syntax when working with pairs or tuples.
- **RAII (Resource Acquisition Is Initialization)**: A core C++ principle used throughout the project (e.g., `juce::ScopedNoDenormals`) to ensure that resources are properly managed.

By using these features, the project serves as a practical example of how to apply modern C++ practices to audio development.