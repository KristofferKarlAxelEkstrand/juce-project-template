---
applyTo: '**/*.json,!node_modules/**,!build/**,!third_party/**'
---

# JSON Configuration Instructions

Maintain clean, well-structured JSON configuration files for build systems, package management, and IDE integration.

## Writing Principles

- **Precise**: Configure exactly what is needed, no extra properties
- **Concise**: Keep configuration files minimal and focused
- **Correct**: Validate JSON syntax and test configurations
- **Down-to-earth**: Use standard configuration patterns
- **KISS**: Avoid overcomplicating configuration structures
- **Pedagogic**: Organize configuration so it is easy to understand

Avoid decorative descriptions, emojis, emoticons, and promotional language in configuration comments.

## General Standards

- Use 2-space indentation for readability
- Keep objects and arrays well-formatted
- Add trailing commas where supported (package.json, tsconfig.json)
- Validate JSON syntax before committing
- Group related configuration properties

## Package.json

- Keep dependencies minimal and purposeful
- Pin versions for reproducible builds
- Use semantic versioning ranges appropriately
- Document scripts with clear, descriptive names
- Organize scripts by category (build, test, lint)

## CMakePresets.json

- Provide presets for all target platforms (Windows, macOS, Linux)
- Use descriptive preset names (vs2022, xcode, ninja)
- Configure appropriate build directories
- Set platform-specific CMake variables
- Document preset usage in comments

## VSCode Configuration

- Configure editor settings for consistency
- Define useful tasks for common operations
- Set up launch configurations for debugging
- Configure file associations for syntax highlighting
- Use workspace-relative paths

## Best Practices

- Never commit credentials or secrets
- Use environment variables for sensitive data
- Keep configuration DRY (Don't Repeat Yourself)
- Document non-obvious configuration choices
- Version control all configuration files

## Validation

- Use schema validation where available
- Test configuration changes locally
- Verify cross-platform compatibility
- Check for syntax errors before committing
- Validate against tool documentation
