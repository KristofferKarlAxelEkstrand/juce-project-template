# Copilot Instructions

This directory contains path-specific custom instructions for GitHub Copilot. These instructions help Copilot
provide better, context-aware suggestions when working with different file types in this repository.

## How It Works

When you work on files in this repository, GitHub Copilot automatically loads relevant instructions based on the
file path. Each instruction file uses glob patterns to specify which files it applies to.

## Instruction Files

| File | Applies To | Purpose |
|------|-----------|---------|
| `cpp-source.instructions.md` | `src/**/*.cpp`, `src/**/*.h` | C++20 and JUCE framework best practices |
| `cmake-config.instructions.md` | `**/CMakeLists.txt`, `*.cmake` | Modern CMake 3.22+ with JUCE integration |
| `documentation.instructions.md` | `**/*.md` | Clear, actionable documentation style |
| `github-config.instructions.md` | `.github/**/*` | GitHub workflows and repository configuration |
| `scripts.instructions.md` | `scripts/**/*.sh`, `scripts/**/*.bat` | Shell script best practices |
| `workflows.instructions.md` | `.github/workflows/*.yml` | GitHub Actions CI/CD workflows |

## Repository-Wide Instructions

The `.github/copilot-instructions.md` file contains repository-wide context about the JUCE project template,
including architecture, build system, and development workflow. These instructions are always active.

## Adding New Instructions

To add instructions for a new file type:

1. Create a file named `NAME.instructions.md` in this directory
1. Add frontmatter with `applyTo` glob patterns:

   ```yaml
   ---
   applyTo:
     - 'path/to/**/*.ext'
     - 'another/**/*.pattern'
   ---
   ```

1. Write clear, actionable instructions following the documentation style guide
1. Test the instructions by working on matching files
1. Update this README with the new instruction file

## Instruction Writing Guidelines

Follow these principles when writing instructions:

- **Be specific**: Provide concrete examples and patterns
- **Be concise**: Use short sentences and clear language
- **Be practical**: Focus on actionable guidance
- **Be consistent**: Match the tone and style of existing instructions
- **Be current**: Keep instructions synchronized with codebase changes

Avoid:

- Decorative language or marketing speak
- Emoticons and emojis
- Assumptions about reader knowledge
- Vague or general advice

## Related Resources

- [GitHub Copilot Custom Instructions Documentation](https://docs.github.com/en/copilot/customizing-copilot/adding-custom-instructions-for-github-copilot)
- [Repository Documentation Style Guide](documentation.instructions.md)
- [CONTRIBUTING.md](../../CONTRIBUTING.md) - Development workflow and standards
