# Git Commit Script 📝✨

A powerful, interactive Git commit script that standardizes commit
messages with emojis, types, scopes, and built-in spell checking.

------------------------------------------------------------------------

## Features 🌟

-   **Standardized Commit Format**: Consistent commit messages with emojis and types.
-   **Interactive Mode**: Guided commit creation with menu options.
-   **Spell Checking**: Built-in spell checking with correction suggestions.
-   **Technical Term Recognition**: Smart detection of programming terms.
-   **Colorful UI**: Beautiful terminal interface with colors.
-   **Scope Support**: Optional scope specification for better organization.
-   **Cross-Platform**: Works on Linux, macOS, and Windows (via WSL/Git/Bash)

------------------------------------------------------------------------

## Quick Install 🚀

### One-line Install (Linux/macOS)

``` bash
curl -sSL https://raw.githubusercontent.com/theDevOli/git-commit/main/install.sh | bash
```

### Windows (Git Bash)

``` bash
curl -sSL https://raw.githubusercontent.com/theDevOli/git-commit/main/install-windows.sh | bash
```

------------------------------------------------------------------------

## Manual Installation 🔧

### Linux & macOS

``` bash
# Download the script
curl -o git-commit https://raw.githubusercontent.com/theDevOli/git-commit/main/git-commit.sh

# Make executable
chmod +x git-commit

# Install to system path
sudo mv git-commit /usr/.local/bin/
```

### Windows

1.  Download `git-commit.sh` from the repository
2.  Rename to `git-commit` (no extension)
3.  Place in a directory in your PATH, or use with Git Bash

------------------------------------------------------------------------

## Usage 📖

### Interactive Mode

``` bash
git-commit
```

### Quick Mode

``` bash
git-commit <type-number> [scope] <description>
```

### Examples

``` bash
git-commit 1 auth "add login functionality"
git-commit 2 database "fix connection leak"
git-commit 3 "refactor user service"
```

------------------------------------------------------------------------

## Commit Types 📋

| Type      | Emoji | Description                 |
|-----------|-------|-----------------------------|
| **feat**  | ✨    | New feature                 |
| **fix**   | 🐛    | Bug fix                     |
| **refactor** | ♻️ | Code restructuring          |
| **perf**  | ⚡    | Performance improvement      |
| **test**  | 🧪    | Adding/updating tests       |
| **chore** | 🔧    | Build process, dependencies |
| **docs**  | 📚    | Documentation changes       |
| **style** | 💄    | Formatting changes          |

------------------------------------------------------------------------

## Spell Checking 🔍

The script includes intelligent spell checking with:

-   Interactive word-by-word correction.
-   Smart suggestions using **aspell/hunspell**.
-   Technical term recognition (50+ programming terms).
-   Flexible options: Correct, ignore, or abort.

------------------------------------------------------------------------

## Requirements 📦

-   Bash 4.0+
-   Git (for commit functionality).
-   curl (for installation).
-   aspell or hunspell (optional, for spell checking).

------------------------------------------------------------------------
## Download Instructions

### Quick Download Options

#### Option 1: One-line Install (Recommended)
```bash
# Linux/macOS
curl -sSL https://raw.githubusercontent.com/theDevOli/git-commit/main/install.sh | bash

# Windows (Git Bash)
curl -sSL https://raw.githubusercontent.com/theDevOli/git-commit/main/install-windows.sh | bash
```

#### Option 2: Manual Download
1. Download the main script: `git-commit.sh`  
2. Make it executable:  
   ```bash
   chmod +x git-commit.sh
   ```
3. Rename and move:  
   ```bash
   mv git-commit.sh /usr/local/bin/git-commit
   ```

#### Option 3: Clone Repository
```bash
git clone https://github.com/theDevOli/git-commit.git
cd git-commit
chmod +x install.sh
./install.sh
```

---

## Files in This Repository
- `git-commit.sh` - Main script file  
- `install.sh` - Linux/macOS installer  
- `install-windows.sh` - Windows installer  
- `README.md` - Documentation  
- `LICENSE` - MIT License  

---

## Need Help?
- Check the README for detailed usage instructions  
- Open an issue for bugs or questions  

---

✅ Now users can install your script with a single command! 🎉

## Support 🤝

Found a bug or have a feature request? Open an issue on GitHub!

------------------------------------------------------------------------

## License 📄

MIT License - see LICENSE file for details.

------------------------------------------------------------------------

✨ Happy committing! 🎉
--------------------------------------------------------------------------

![version](https://img.shields.io/badge/version-1.2.0-blue)
![Linux](https://img.shields.io/badge/platform-Linux-green?logo=linux)
![Windows](https://img.shields.io/badge/platform-Windows-blue?logo=windows)
![macOS](https://img.shields.io/badge/platform-macOS-lightgrey?logo=apple)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](./LICENSE)
