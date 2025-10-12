# Copilot Instructions

This repository is configured with comprehensive GitHub Copilot custom instructions to provide context-aware assistance
for development tasks.

All instructions follow these core principles:

- **Precise**: Provide exact solutions for specific needs
- **Concise**: Keep code and documentation simple and direct
- **Correct**: Ensure all suggestions compile and function properly
- **Down-to-earth**: Use clear, practical approaches without over-engineering
- **KISS**: Keep everything simple and straightforward
- **Pedagogic**: Generate code and documentation that is easy to understand

Instructions avoid decorative language, emojis, emoticons, and promotional adjectives.

## Structure

The Copilot instructions are organized into three levels:

### Coding Agent Instructions

**File**: `AGENTS.md`

Provides contextual instructions for GitHub Copilot coding agent when working on issues and tasks:

- Issue workflow and environment validation
- Code modification guidelines for each file type
- Build system commands and output locations
- Git workflow and commit message format
- Testing requirements and validation steps
- Common tasks and troubleshooting

This file guides the Copilot coding agent through the complete development workflow when assigned to issues.

### Repository-Wide Instructions

**File**: `.github/copilot-instructions.md`

Provides general context about the JUCE project template, including:

- Architecture overview and core components
- Build system essentials and CMake presets
- Development workflow patterns
- Project structure and key files
- JUCE-specific conventions and best practices
- Common validation scenarios

This file is automatically loaded for all Copilot requests in this repository.

### Path-Specific Instructions

**Directory**: `.github/instructions/`

Contains specialized instructions that apply to specific file types:

| File | Applies To | Purpose |
|------|------------|---------|
| `cpp-source.instructions.md` | `src/**/*.cpp`, `src/**/*.h` | C++20/JUCE patterns, memory safety, real-time audio constraints |
| `cmake-config.instructions.md` | `**/CMakeLists.txt`, `*.cmake` | Modern CMake practices, JUCE integration, cross-platform builds |
| `documentation.instructions.md` | `**/*.md` | Documentation style, formatting rules, KISS principles |
| `github-config.instructions.md` | `.github/**/*` | Workflow configuration, CI/CD patterns, automation |
| `scripts.instructions.md` | `**/*.sh`, `**/*.bat` | Shell script standards, error handling, cross-platform scripting |
| `json-config.instructions.md` | `**/*.json` | JSON configuration, package.json, CMakePresets.json |

Each path-specific instruction file uses YAML frontmatter with the `applyTo` field to specify which files it applies to.

## How It Works

When you interact with GitHub Copilot in this repository:

1. Copilot automatically loads `.github/copilot-instructions.md` for repository context
2. Based on the file you are working on, Copilot loads matching path-specific instructions
3. These instructions guide Copilot to follow project conventions and best practices

For example, when editing a C++ file in `src/`, Copilot will:

- Apply general repository knowledge from `copilot-instructions.md`
- Follow C++20 and JUCE patterns from `cpp-source.instructions.md`
- Understand threading requirements and memory safety constraints

## Using Copilot Effectively

### Code Generation

When asking Copilot to generate code, the instructions ensure:

- C++ code follows JUCE naming conventions and uses appropriate base classes
- CMake configurations use modern target-based approach
- Documentation follows KISS principles without decorative language
- Scripts include proper error handling and help messages

### Code Reviews

Copilot can review your code against the instruction guidelines:

- Check if C++ code avoids allocations in audio callbacks
- Verify CMake uses FetchContent instead of committing dependencies
- Ensure documentation is clear and practical
- Validate scripts have cross-platform considerations

### Refactoring

When refactoring, Copilot will:

- Maintain JUCE patterns and thread safety
- Keep build configurations cross-platform
- Update documentation to match code changes
- Preserve error handling in scripts

## Customizing Instructions

To modify or extend the instructions:

1. Edit `.github/copilot-instructions.md` for repository-wide changes
2. Modify files in `.github/instructions/` for path-specific updates
3. Create new instruction files for additional file types
4. Test with `npm test` to validate markdown formatting

### Creating New Instruction Files

Format for new instruction files:

```markdown
---
applyTo: 'pattern/**/*.ext'
---

# Title

Instructions for this file type...
```

The `applyTo` field uses glob patterns to match files. Examples:

- `**/*.py` - All Python files
- `src/**/*.cpp` - C++ files in src directory
- `*.json,!node_modules/**` - JSON files excluding node_modules

## Best Practices

### Clear Context

Provide Copilot with clear context when asking questions:

- Mention the file type you are working on
- Describe what you are trying to achieve
- Reference relevant JUCE classes or CMake functions

### Specific Requests

Make requests specific and actionable:

- Bad example: "Make this better"
- Good example: "Refactor this function to avoid allocations in the audio callback"

### Iterative Refinement

Work with Copilot iteratively:

1. Ask for initial implementation
2. Review against instruction guidelines
3. Request adjustments as needed
4. Validate with linting and tests

## Validation

The instructions are validated as part of the repository testing:

```bash
npm test  # Runs markdownlint on all instruction files
```

All instruction files must pass markdown linting before being committed.

## See Also

- [AGENTS.md](../AGENTS.md) - Instructions for GitHub Copilot coding agent
- [GitHub Copilot Documentation](https://docs.github.com/en/copilot)
- [Custom Instructions Guide](https://docs.github.com/en/copilot/customizing-copilot/adding-custom-instructions-for-github-copilot)
- [CONTRIBUTING.md](../CONTRIBUTING.md) - Contribution guidelines
- [DEVELOPMENT_WORKFLOW.md](../DEVELOPMENT_WORKFLOW.md) - Development workflow patterns
