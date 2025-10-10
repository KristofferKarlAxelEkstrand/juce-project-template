# Contributing to DSP-JUCE

Thank you for contributing to DSP-JUCE. This guide outlines the development workflow,
coding standards, and contribution process.

## Development Setup

### Prerequisites

- Follow the complete setup in [BUILD.md](BUILD.md)
- Install `clang-format` for code formatting
- Install Node.js for documentation linting

### Initial Setup

```bash
# Clone and configure
git clone <your-fork-url>
cd dsp-juce
cmake --preset=default

# Install documentation tools
npm install

# Validate setup
./scripts/validate-setup.sh
npm test
```

## Git Workflow

This project uses a Git Flow-inspired workflow to optimize CI/CD resource usage:

### Branch Structure

- **`main`**: Production-ready code, protected branch
- **`develop`**: Integration branch for features, protected branch  
- **`feature/*`**: Feature branches created from `develop`

### Development Process

1. **Create Feature Branch**:

   ```bash
   git checkout develop
   git pull origin develop
   git checkout -b feature/your-feature-name
   ```

2. **Develop and Test**:

   ```bash
   # Make changes, format code
   clang-format -i src/*.cpp src/*.h
   npm test
   
   # Test builds locally
   cmake --preset=default && cmake --build --preset=default
   ```

3. **Create PR to Develop**:
   - Push your feature branch
   - Create PR from `feature/your-feature-name` → `develop`
   - CI will run on the PR (linting + cross-platform builds)

4. **Merge to Develop**:
   - After approval, merge feature branch to `develop`
   - `develop` branch accumulates tested features

5. **Release to Main**:
   - Create PR from `develop` → `main` when ready for release
   - CI runs full test suite on release PR
   - After approval, merge to `main`

### CI/CD Strategy

- **CI runs only on PRs** to `main` and `develop` branches (saves action minutes)
- **No CI on direct pushes** to feature branches
- **Full cross-platform testing** on PRs to protected branches
- **Security scanning** on PRs and weekly schedule

## Coding Standards

### C++ Guidelines

**Modern C++20**:

- Use `auto` for type deduction
- Prefer `constexpr` for compile-time constants
- Use structured bindings for multiple returns
- Apply RAII principles for resource management

**Real-Time Safety**:

- No dynamic allocation in audio callbacks (`getNextAudioBlock`)
- Use `std::atomic` for thread-safe parameter updates
- Pre-allocate all buffers in `prepareToPlay`
- Avoid blocking operations in audio thread

**Code Style**:

```bash
# Format before committing
clang-format -i src/*.cpp src/*.h
```

### JUCE Best Practices

**Audio Processing**:

- Initialize DSP modules in `prepareToPlay`
- Use `juce::dsp` modules for audio operations
- Handle sample rate and buffer size changes
- Implement proper bypass functionality

**GUI Development**:

- Separate GUI logic from audio processing
- Use `juce::AudioProcessorValueTreeState` for parameters
- Implement proper component lifecycle management
- Follow platform-specific UI guidelines

## Contribution Workflow

### 1. Issue Discussion

- Open an issue to discuss significant changes
- Reference existing issues in your PRs
- Use clear, descriptive titles

### 2. Branch Strategy

```bash
# Create feature branch
git checkout -b feature/your-feature-name

# Or bug fix branch  
git checkout -b fix/issue-number-description
```

### 3. Development Process

```bash
# Make changes following coding standards
# ...edit files...

# Format and validate
clang-format -i src/*.cpp src/*.h
npm test

# Build and test
cmake --build --preset=default
./scripts/validate-setup.sh
```

### 4. Commit Guidelines

Use [Conventional Commits](https://conventionalcommits.org/):

```bash
# Feature additions
git commit -m "feat: Add frequency modulation to oscillator"

# Bug fixes
git commit -m "fix: Resolve audio dropout on buffer size change"

# Documentation
git commit -m "docs: Update build instructions for Windows"

# Code style
git commit -m "style: Apply clang-format to source files"
```

### 5. Pull Request Process

**Before Submitting**:

- [ ] Code builds successfully on your platform
- [ ] All tests pass: `npm test`
- [ ] Code is formatted: `clang-format -i src/*.cpp src/*.h`
- [ ] Documentation updated if needed
- [ ] Commit messages follow conventional format

**PR Description**:

- Describe the change and motivation
- Link related issues: `Fixes #123`
- Include testing steps
- Add screenshots for UI changes

## Code Review

### Review Criteria

- **Functionality**: Does it work as intended?
- **Performance**: No audio dropouts or excessive CPU usage
- **Safety**: Real-time safe, no undefined behavior
- **Style**: Follows project conventions
- **Documentation**: Clear and up-to-date

### Addressing Feedback

- Respond to all review comments
- Make requested changes in new commits
- Update PR description if scope changes

## Testing

### Manual Testing

```bash
# Build both configurations
cmake --preset=default && cmake --build --preset=default
cmake --preset=release && cmake --build --preset=release

# Test standalone application
./build/DSPJucePlugin_artifacts/Debug/Standalone/DSP-JUCE\ Plugin

# Verify plugin installation (platform-specific)
ls -la ~/.vst3/DSP-JUCE\ Plugin.vst3/  # Linux
```

### Performance Testing

- Test with various buffer sizes (32, 64, 128, 512, 1024 samples)
- Verify no audio dropouts during parameter changes
- Check CPU usage in your DAW
- Test plugin loading/unloading

## Documentation

### Documentation Standards

- Use clear, concise language
- Include practical examples
- Follow Markdown best practices
- Test all code examples

### Building Documentation

```bash
# Lint documentation
npm test

# Fix common issues
npm run lint:md:fix
```

## Common Issues

### Build Problems

- **Clean rebuild**: `rm -rf build/ && cmake --preset=default`
- **Dependency issues**: Check internet connection for JUCE download
- **Compiler errors**: Verify C++20 support

### Audio Issues  

- **Dropouts**: Check for allocations in audio thread
- **Clicks/pops**: Verify smooth parameter changes
- **No sound**: Check audio device settings and sample rate

### Plugin Issues

- **Not detected**: Check installation directory and architecture
- **Crashes**: Use debug build and check logs
- **Parameter automation**: Verify thread-safe implementation

## Resources

### Learning

- [JUCE Documentation](https://docs.juce.com/)
- [JUCE Forum](https://forum.juce.com/)
- [Audio Programming Resources](docs/)

### Development Tools

- **Debugger**: Use IDE debugger or GDB/LLDB
- **Profiler**: Intel VTune, Instruments (macOS), perf (Linux)
- **Memory**: Valgrind (Linux), AddressSanitizer
- **Audio**: Plugin Host, DAW testing environment

## Questions?

- Open a [GitHub issue](https://github.com/KristofferKarlAxelEkstrand/dsp-juce/issues) for bugs or feature requests
- Check existing [documentation](docs/) for technical details
- Review [JUCE examples](https://github.com/juce-framework/JUCE/tree/master/examples) for reference implementations
