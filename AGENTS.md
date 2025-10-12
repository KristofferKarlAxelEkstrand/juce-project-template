# Agent Instructions

This file provides contextual instructions for GitHub Copilot coding agent when working on issues and tasks in this
repository.

## Repository Overview

This is a JUCE 8.0.10 audio plugin project template providing a development environment with:

- Modern CMake build system with automatic JUCE dependency management
- Cross-platform support (Windows, macOS, Linux)
- Fast development workflow using Ninja (1-3 second incremental builds)
- GitHub Actions CI/CD with multi-platform builds
- Comprehensive documentation and coding standards

## Working with Issues

When assigned to an issue in this repository, follow these steps:

### 1. Understand the Context

- Read `.github/copilot-instructions.md` for repository-wide context
- Check relevant path-specific instructions in `.github/instructions/`
- Review related documentation in `docs/` directory
- Examine existing code patterns in `src/` for consistency

### 2. Validate Environment

Before making changes:

```bash
# Install dependencies
npm install

# Validate setup
./scripts/validate-setup.sh

# Run linting
npm test
```

### 3. Make Minimal Changes

- Make the smallest possible changes to address the issue
- Follow existing patterns and conventions
- Do not refactor unrelated code
- Preserve working functionality

### 4. Build and Test

```bash
# Configure build
cmake --preset=default          # Linux/macOS
cmake --preset=vs2022           # Windows

# Build
cmake --build --preset=default

# Validate artifacts
./scripts/validate-builds.sh
```

### 5. Lint and Format

```bash
# Format C++ code
clang-format -i src/*.cpp src/*.h

# Lint documentation
npm run lint:md:fix

# Run all tests
npm test
```

## Code Modification Guidelines

### C++ Source Files (`src/**/*.cpp`, `src/**/*.h`)

Follow instructions in `.github/instructions/cpp-source.instructions.md`:

- Use modern C++20 standards
- Follow JUCE framework best practices
- Avoid allocations in audio callbacks
- Use `std::atomic<T>` for thread-safe parameter communication
- Apply RAII and smart pointers for memory management

### CMake Files (`**/CMakeLists.txt`, `*.cmake`)

Follow instructions in `.github/instructions/cmake-config.instructions.md`:

- Use modern CMake 3.22+ practices
- Use target-based approach (target_link_libraries, target_include_directories)
- Use FetchContent for dependencies (never commit JUCE source)
- Support all platform presets (default, vs2022, xcode, ninja)

### Documentation Files (`**/*.md`)

Follow instructions in `.github/instructions/documentation.instructions.md`:

- Apply KISS principles
- Use precise, concise, correct language
- Avoid decorative language, emojis, emoticons
- Provide working code examples
- Document prerequisites and troubleshooting

### Scripts (`**/*.sh`, `**/*.bat`)

Follow instructions in `.github/instructions/scripts.instructions.md`:

- Maintain both .sh (Unix) and .bat (Windows) versions
- Use `set -euo pipefail` in bash scripts
- Include proper error handling
- Provide `--help` flags
- Test on all target platforms

### Configuration Files (`**/*.json`)

Follow instructions in `.github/instructions/json-config.instructions.md`:

- Use 2-space indentation
- Validate JSON syntax
- Keep configuration minimal and focused
- Document non-obvious choices

## Build System

### Critical Build Commands

```bash
# Configure (90+ seconds first time - downloads JUCE 8.0.10)
cmake --preset=default          # Linux/macOS
cmake --preset=vs2022           # Windows

# Build (2m45s Debug, 4m30s Release)
cmake --build --preset=default

# Fast incremental builds (1-3 seconds with Ninja)
cmake --preset=ninja
cmake --build --preset=ninja
```

### Build Output Locations

Artifacts are created in `build/<preset>/JucePlugin_artefacts/`:

- VST3: `<preset>/JucePlugin_artefacts/Debug/VST3/<PLUGIN_NAME>.vst3/`
- Standalone: `<preset>/JucePlugin_artefacts/Debug/Standalone/<PLUGIN_NAME>`
- Library: `<preset>/JucePlugin_artefacts/Debug/lib<PLUGIN_TARGET>_SharedCode.a`

Actual paths depend on `PLUGIN_NAME` and `PLUGIN_TARGET` set in `CMakeLists.txt`.

## Git Workflow

### Branch Strategy

- `main`: Production-ready code
- `develop`: Integration branch
- `feature/*`: New features (branch from `develop`)
- `fix/*`: Bug fixes (branch from `develop`)

### Commit Messages

Use Conventional Commits format:

```bash
feat: Add frequency modulation to oscillator
fix: Resolve audio dropout on buffer size change
docs: Update build instructions for Windows
style: Apply clang-format to source files
test: Add unit tests for DSP processing
```

### Pre-Commit Checks

Husky runs `lint-staged` on commit:

- Automatically formats markdown files
- Blocks commits that fail linting
- Fix issues with `npm run lint:md:fix`

## Testing Requirements

### Documentation Testing

```bash
# Run markdown linting
npm test

# Fix markdown issues
npm run lint:md:fix
```

### Build Testing

```bash
# Validate build artifacts exist
./scripts/validate-builds.sh

# Test specific configuration
./scripts/validate-builds.sh Debug
./scripts/validate-builds.sh Release
```

### Manual Validation

1. Build succeeds on target platform
2. All expected artifacts are created
3. Documentation linting passes
4. Code follows existing patterns
5. No unrelated changes included

## Common Tasks

### Adding New Source Files

1. Create `.cpp` and `.h` files in `src/`
2. Update `CMakeLists.txt` to include new files
3. Follow JUCE patterns (inherit from appropriate base classes)
4. Format code with `clang-format`
5. Build and validate

### Updating Plugin Metadata

Edit these values in `CMakeLists.txt`:

```cmake
set(PLUGIN_NAME "JUCE Project Template Plugin")
set(PLUGIN_TARGET "JucePlugin")
set(PLUGIN_VERSION "0.0.1")
set(PLUGIN_COMPANY_NAME "MyCompany")
```

Metadata automatically propagates to all outputs.

### Modifying Build Configuration

1. Edit `CMakeLists.txt` for build system changes
2. Edit `CMakePresets.json` for preset configurations
3. Test all presets (default, vs2022, xcode, ninja)
4. Update documentation if user-facing changes

### Adding Documentation

1. Create markdown file in appropriate directory
2. Follow KISS principles (no decorative language)
3. Provide working examples
4. Document prerequisites
5. Run `npm run lint:md:fix` to format
6. Update relevant guides to reference new documentation

## Troubleshooting

### Build Failures

- Verify CMake 3.22+ is installed
- Check C++ compiler is available
- Install platform-specific dependencies (see `BUILD.md`)
- Clean build directory and reconfigure: `rm -rf build`

### Linting Failures

- Run `npm run lint:md:fix` to auto-fix markdown issues
- Check for trailing whitespace
- Verify heading hierarchy
- Ensure code blocks have language tags

### Missing Dependencies (Linux)

```bash
sudo apt-get install -y libasound2-dev libx11-dev libxcomposite-dev \
                        libxcursor-dev libxinerama-dev libxrandr-dev \
                        libfreetype6-dev libfontconfig1-dev libgl1-mesa-dev \
                        libcurl4-openssl-dev libwebkit2gtk-4.1-dev pkg-config \
                        build-essential
```

## Quality Standards

Code must meet these standards before PR approval:

1. Builds successfully on target platform
2. All tests pass (npm test)
3. Code is formatted (clang-format)
4. Documentation is updated if needed
5. Commit messages follow conventional format
6. No unrelated changes included
7. Follows existing patterns and conventions

## JUCE Development Anti-Patterns

Avoid these common mistakes:

- Allocating memory in `processBlock()` or other real-time contexts
- Using blocking operations (file I/O, network) in audio threads
- Ignoring sample rate changes in `prepareToPlay()`
- Not handling buffer size variations
- Mixing GUI and audio thread operations without synchronization
- Creating audio dropouts through inefficient processing

## Real-Time Safety

Audio processing code must be real-time safe:

- No memory allocations in `processBlock()`
- No mutex locks (use lock-free patterns)
- No blocking operations
- Pre-allocate all buffers in `prepareToPlay()`
- Use `std::atomic<T>` for parameter communication
- Test with various buffer sizes (32-2048 samples)

## Additional Resources

- `.github/copilot-instructions.md`: Repository-wide context
- `.github/instructions/`: Path-specific coding guidelines
- `docs/COPILOT_INSTRUCTIONS.md`: How to use Copilot in this repository
- `CONTRIBUTING.md`: Contribution guidelines and workflow
- `BUILD.md`: Platform-specific build instructions
- `DEVELOPMENT_WORKFLOW.md`: Fast development workflow setup
- `docs/`: Technical documentation (JUCE, CMake, C++, etc.)

## Success Criteria

A successful agent contribution should:

- Address the issue with minimal changes
- Follow all existing patterns and conventions
- Pass all linting and build tests
- Include updated documentation if needed
- Be ready for review without additional fixes
- Work correctly on all target platforms
