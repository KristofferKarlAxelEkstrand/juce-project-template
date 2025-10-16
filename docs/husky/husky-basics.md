# Husky in This Project

Husky is a tool for managing Git hooks in JavaScript and TypeScript projects. It allows you to run scripts automatically
at key points in your Git workflow, such as before commits or pushes.

## Why Husky Is Used Here

- **Enforces code quality**: Runs linters and formatters before code is committed.
- **Prevents bad commits**: Blocks commits that don't meet project standards.
- **Automates checks**: Ensures all contributors follow the same rules.

## How Husky Works in This Project

- Git hooks are defined in the `.husky/` directory.
- When you commit or push, Husky runs scripts (like linting or formatting) automatically.
- If a check fails, the commit or push is blocked until you fix the issue.

## Typical Usage

1. **Install dependencies** (done automatically with `npm install`).
2. **Make changes and commit**:

   ```bash
   git add .
   git commit -m "your message"
   # Husky runs pre-commit hooks (e.g., linting)
   ```

3. **If a hook fails**: Fix the reported issues and try committing again.

Husky helps maintain code quality and consistency across all contributions.
