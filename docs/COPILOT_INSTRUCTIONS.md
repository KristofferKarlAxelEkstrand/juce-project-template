# GitHub Copilot Instructions Setup

This document describes the GitHub Copilot custom instructions configuration for this repository.

## Overview

This repository is configured with comprehensive GitHub Copilot custom instructions that provide context-aware
guidance for different file types. This improves Copilot's suggestions and helps maintain consistency across
the codebase.

## Configuration Structure

### Repository-Wide Instructions

**File:** `.github/copilot-instructions.md`

This file contains general context about the JUCE project template that applies to all files:

- Project architecture and core components
- Build system essentials and commands
- Development workflow and patterns
- Project-specific conventions
- Common tasks and troubleshooting

The repository-wide instructions are always active when working in this repository.

### Path-Specific Instructions

**Directory:** `.github/instructions/`

Path-specific instructions provide targeted guidance based on file type or location:

| Instruction File | File Patterns | Purpose |
|-----------------|---------------|---------|
| `cpp-source.instructions.md` | `src/**/*.cpp`, `src/**/*.h` | Modern C++20 standards, JUCE framework best practices, real-time audio safety |
| `cmake-config.instructions.md` | `**/CMakeLists.txt`, `*.cmake` | Modern CMake 3.22+ practices, JUCE integration, cross-platform builds |
| `documentation.instructions.md` | `**/*.md` | Clear documentation style, KISS principles, no decorative language |
| `github-config.instructions.md` | `.github/**/*` | Repository settings, workflows, automation, agent framework support |
| `scripts.instructions.md` | `scripts/**/*.sh`, `scripts/**/*.bat` | Shell script standards, cross-platform compatibility, error handling |
| `workflows.instructions.md` | `.github/workflows/*.yml` | GitHub Actions best practices, build matrix strategy, cost optimization |

Each instruction file uses YAML frontmatter to specify which files it applies to using glob patterns.

### Chat Modes

**Directory:** `.github/chatmodes/`

Custom chat modes for specialized assistance:

- `project-developer.chatmode.md`: Expert DSP-JUCE developer with action-first principles
- `tech-writer.chatmode.md`: Technical documentation specialist

### Prompts

**Directory:** `.github/prompts/`

Prompt templates for common workflows:

- `research-phase.prompt.md`: Multi-source research before implementation
- `architecture-planning.prompt.md`: Architecture and design planning
- `implementation-framework.prompt.md`: Structured implementation approach
- `validation-testing.prompt.md`: Testing and validation strategies
- `pr-comments-fix.prompt.md`: Addressing PR review comments
- `pr-comments-fix-cleanup.prompt.md`: Post-PR cleanup tasks

## Best Practices

### Writing Custom Instructions

When creating or modifying instruction files:

1. **Be specific**: Provide concrete examples and code patterns
2. **Be concise**: Use short sentences and clear language
3. **Be practical**: Focus on actionable guidance
4. **Be consistent**: Match existing instruction style
5. **Be current**: Keep synchronized with codebase changes

### Frontmatter Format

Use YAML array format for `applyTo` patterns:

```yaml
---
applyTo:
  - 'path/to/**/*.ext'
  - 'another/**/*.pattern'
---
```

This format is more readable and matches GitHub's official documentation.

### Testing Instructions

After modifying instructions:

1. Work on files matching the instruction patterns
2. Verify Copilot provides appropriate suggestions
3. Run `npm test` to validate markdown formatting
4. Commit changes with descriptive messages

## How Copilot Uses These Instructions

GitHub Copilot combines instructions from multiple sources:

1. **Global settings**: User's personal Copilot settings
2. **Repository-wide**: `.github/copilot-instructions.md` (always active)
3. **Path-specific**: Matching `.github/instructions/*.instructions.md` files
4. **File context**: The actual code being edited

Instructions closer to the file being edited take precedence over more general instructions.

## Coverage Summary

The current instruction setup provides comprehensive coverage:

- **Source Code**: C++ and header files (JUCE patterns, real-time safety)
- **Build System**: CMake files (modern practices, cross-platform)
- **Documentation**: Markdown files (clear style, KISS principles)
- **Automation**: Scripts and workflows (best practices, optimization)
- **Configuration**: GitHub settings (repository management)

This ensures consistent, high-quality suggestions across all major file types in the repository.

## Maintenance

### Regular Updates

Review and update instructions when:

- Adding new file types or patterns
- Changing coding standards or conventions
- Adopting new tools or frameworks
- Receiving feedback about Copilot suggestions

### Documentation

Keep the following files synchronized:

- `.github/copilot-instructions.md` (list of instruction files)
- `.github/instructions/README.md` (instruction directory overview)
- This document (overall setup description)

## References

- [GitHub Copilot Custom Instructions Documentation](https://docs.github.com/en/copilot/customizing-copilot/adding-custom-instructions-for-github-copilot)
- [Best Practices for Custom Instructions](https://github.blog/ai-and-ml/github-copilot/5-tips-for-writing-better-custom-instructions-for-copilot/)
- [Repository Contributing Guide](../CONTRIBUTING.md)
- [Development Workflow](../DEVELOPMENT_WORKFLOW.md)
