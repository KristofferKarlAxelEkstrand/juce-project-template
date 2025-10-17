# Setting up LLVM/clang-format on Windows with Git Bash

## Problem

After installing LLVM via `winget install LLVM.LLVM`, clang-format is installed but not available in your Git Bash PATH.

## Solution Options

### Option 1: Add to Windows System PATH (Permanent - Recommended)

1. **Open System Environment Variables:**
   - Press `Win + R`, type `sysdm.cpl`, press Enter
   - Click "Environment Variables..." button
   - Or search "Environment Variables" in Start menu

2. **Edit System PATH:**
   - In "System Variables" section, find and select "Path"
   - Click "Edit..."
   - Click "New"
   - Add: `C:\Program Files\LLVM\bin`
   - Click "OK" on all dialogs

3. **Restart terminals:**
   - Close and reopen Git Bash, VS Code, etc.
   - Test with: `clang-format --version`

### Option 2: Add to Git Bash Profile (Git Bash only)

1. **Edit your bash profile:**

   ```bash
   # Open your .bashrc or .bash_profile
   notepad ~/.bashrc
   ```

2. **Add this line:**

   ```bash
   export PATH="/c/Program Files/LLVM/bin:$PATH"
   ```

3. **Reload your profile:**

   ```bash
   source ~/.bashrc
   ```

### Option 3: Temporary for Current Session

```bash
# Run this in your current Git Bash session
export PATH="/c/Program Files/LLVM/bin:$PATH"
```

## Verification

After applying any option, test with:

```bash
clang-format --version
which clang-format
```

Should output:

```text
clang-format version 21.1.3
/c/Program Files/LLVM/bin/clang-format
```

## VS Code Integration

Once clang-format is in your PATH, VS Code will automatically use it for:

- Format on save (if enabled)
- Manual formatting (Ctrl+Shift+I)
- Pre-commit hooks via our scripts

## Troubleshooting

- **Command not found after adding to PATH:** Restart all terminals and VS Code
- **Permission issues:** Run terminal as administrator when adding to system PATH
- **Different LLVM location:** Check where winget installed it with `winget list LLVM.LLVM`
