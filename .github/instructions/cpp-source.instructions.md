---
applyTo: 'src/**/*.cpp,src/**/*.h'
---

# C++ Source Code Instructions

Apply modern C++20 standards with JUCE framework best practices. Focus on performance, memory safety, and
maintainable code.

## Code Standards

- Use RAII and smart pointers for memory management
- Prefer const correctness and immutable data where possible
- Use auto keyword judiciously for type deduction
- Implement proper move semantics for performance
- Follow JUCE naming conventions (camelCase for methods, PascalCase for classes)

## JUCE-Specific Patterns

- Inherit from appropriate JUCE base classes (Component, AudioAppComponent, etc.)
- Use JUCE's memory management patterns (ReferenceCountedObject when needed)
- Implement proper audio thread safety (use MessageManagerLock appropriately)
- Use JUCE's event system (Listener patterns, AsyncUpdater)
- Follow JUCE's paint/resized pattern for UI components

## Error Handling

- Use exceptions for exceptional cases, not control flow
- Implement proper RAII for resource cleanup
- Use JUCE's assertion macros (jassert) for debug-time checks
- Handle audio dropouts gracefully in real-time code
- Validate user inputs and provide meaningful error messages

## Performance Considerations

- Avoid allocations in audio callbacks
- Use lock-free patterns for audio thread communication
- Prefer stack allocation over heap when possible
- Profile and optimize hot paths
- Use appropriate data structures for access patterns

## Documentation

- Document public interfaces with clear comments
- Explain complex algorithms and non-obvious code
- Include usage examples for public APIs
- Document thread safety guarantees
- Explain ownership and lifetime semantics
