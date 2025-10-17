# Development Formatting Setup

This project has automated formatting configured for both **format on save** in VS Code and **format on commit** via
Husky hooks.

## What Gets Formatted

### Automatically Formatted File Types

- **Markdown** (`.md`) - via Prettier + markdownlint-cli2
- **JSON/JSONC** (`.json`, `.jsonc`) - via Prettier
- **C++** (`.cpp`, `.h`) - via clang-format (if available)

### Format on Save (VS Code)

The `.vscode/settings.json` configuration enables automatic formatting when you save files:

```json
{
  "[markdown]": {
    "editor.formatOnSave": true,
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[cpp]": {
    "editor.formatOnSave": true,
    "editor.defaultFormatter": "ms-vscode.cpptools"
  }
}
```

### Format on Commit (Husky + lint-staged)

Pre-commit hooks automatically format staged files before each commit:

```json
{
  "lint-staged": {
    "*.md": ["prettier --write", "markdownlint-cli2 --fix"],
    "src/**/*.{cpp,h}": ["clang-format -i"],
    "*.{json,jsonc}": ["prettier --write"]
  }
}
```

## Manual Formatting Commands

```bash
# Format all files
npm run format

# Format only markdown files
prettier --write "**/*.md"

# Format only C++ files (requires clang-format)
npm run format:cpp

# Fix all markdown and format issues
npm run fix
```

## Required Tools

### Included in project

- **Prettier** - JavaScript/JSON/Markdown formatting
- **markdownlint-cli2** - Markdown linting and fixing
- **Husky** - Git hooks
- **lint-staged** - Run commands on staged files

### External dependencies

- **clang-format** - C++ code formatting (optional but recommended)

## Installing clang-format

### Windows

```powershell
# Via Visual Studio Installer (recommended)
# Install "C++ CMake tools for Visual Studio" component

# Or via Chocolatey
choco install llvm

# Or via winget
winget install LLVM.LLVM
```

### macOS

```bash
# Via Homebrew
brew install clang-format

# Or via MacPorts
sudo port install clang-format
```

### Linux (Ubuntu/Debian)

```bash
sudo apt install clang-format
```

## Configuration Files

- `.prettierrc` - Prettier formatting configuration
- `.prettierignore` - Files to exclude from Prettier
- `.clang-format` - C++ formatting style (LLVM-based)
- `.husky/pre-commit` - Git pre-commit hook script
- `package.json` - lint-staged configuration

## VS Code Extensions

Recommended extensions for optimal formatting experience:

- **Prettier - Code formatter** (`esbenp.prettier-vscode`)
- **C/C++** (`ms-vscode.cpptools`)
- **markdownlint** (`DavidAnson.vscode-markdownlint`)

## Troubleshooting

### Format on save not working

1. Ensure required VS Code extensions are installed
2. Check that `.vscode/settings.json` has correct configuration
3. Restart VS Code

### Pre-commit hook failing

1. Run `npm install` to ensure dependencies are installed
2. Check if clang-format is installed: `which clang-format`
3. Run `npm run fix` to manually fix formatting issues

### Disabling formatting for specific files

Add paths to `.prettierignore` or use format-disable comments:

```cpp
// clang-format off
void unformatted_code() {
    // This won't be formatted
}
// clang-format on
```

```markdown
<!-- prettier-ignore -->
| This | table | won't | be | formatted |
|------|-------|-------|----|-----------:|
| even | if    | it's  | ugly |         |
```
