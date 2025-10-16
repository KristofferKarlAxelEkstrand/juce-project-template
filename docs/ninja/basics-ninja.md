# Ninja Build System Basics

Ninja is a fast, minimal build system used with CMake for rapid C++ development.

## Installation

### Windows

1. Download Ninja from the official releases: <https://github.com/ninja-build/ninja/releases>
2. Extract `ninja.exe` to a folder (e.g., `C:\Tools\Ninja`).
3. Add the folder to your system PATH:
   - Open Start, search for "Environment Variables".
   - Edit the `Path` variable and add the folder path (e.g., `C:\Tools\Ninja`).
4. Open a new terminal and run:

   ```bash
   ninja --version
   ```

   You should see the installed version.

### macOS

```bash
brew install ninja
```

### Linux (Debian/Ubuntu)

```bash
sudo apt-get install ninja-build
```

## Usage with CMake

Configure your project to use Ninja:

```bash
cmake -G Ninja -B build
cmake --build build
```

Or use a CMake preset with Ninja.

## Why Use Ninja?

- Much faster incremental builds than Visual Studio/MSBuild
- Minimal overhead, ideal for automation and scripting
- Works on all major platforms

## Troubleshooting

- If `ninja` is not found, check your PATH and restart your terminal.
- For Windows, ensure you added the correct folder to the PATH.
