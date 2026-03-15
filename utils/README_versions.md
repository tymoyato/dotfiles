# Package Version Checker Scripts

This directory contains scripts to check the current installed versions vs available versions of packages managed by APT and Homebrew.

## Understanding Your Package Installation Setup

Your system uses two package managers:

1. **APT** (Advanced Package Tool) - Ubuntu/Debian's native package manager
   - Packages are installed via `apt install`
   - Package list defined in `linux/packages.yml` under `apt.core` and `apt.essential`
   - Examples: `git`, `curl`, `brave-browser`, `awesome`, `rofi`

2. **Homebrew** - Cross-platform package manager for macOS and Linux
   - Packages are installed via `brew install`
   - Package list defined in `linux/packages.yml` under `brew`
   - Examples: `fish`, `neovim`, `fzf`, `zoxide`, `lazygit`

## Available Scripts

### 1. `check_versions.sh` (Advanced)
- **Requires**: `yq` command-line tool
- **Features**: 
  - Reads package lists directly from `linux/packages.yml`
  - Automatically updates when you modify the YAML file
  - More maintainable for long-term use

### 2. `check_versions_simple.sh` (Simple)
- **Requires**: No additional dependencies
- **Features**:
  - Hardcoded package lists (extracted from `packages.yml`)
  - Works immediately without installing `yq`
  - Includes summary statistics

## Usage

### Run the simple version (recommended for quick checks):
```bash
./utils/check_versions_simple.sh
```

### Run the advanced version (requires yq):
```bash
./utils/check_versions.sh
```

## Output Format

Both scripts provide:

1. **Package Status Table** showing:
   - Package name
   - Currently installed version
   - Available version in repositories
   - Status (Up to date / Update available / Not installed)

2. **Summary Statistics** (simple version only):
   - Total packages vs installed packages
   - Count of up-to-date packages
   - Count of packages with updates available
   - Count of not installed packages

## Color Coding

- 🟢 **Green**: Up to date
- 🟡 **Yellow**: Update available
- 🔴 **Red**: Not installed

## Example Output

```
ℹ Checking APT packages...
==================================================
Package                   Installed       Available       Status    
==================================================
git                       1:2.39.5-0+deb12u1 1:2.39.5-0+deb12u2 Update available
curl                      7.88.1-10+deb12u12 7.88.1-10+deb12u12 Up to date
brave-browser             1.75.180        1.80.115        Update available

ℹ Checking Homebrew packages...
==================================================
Package                   Installed       Available       Status    
==================================================
fish                      3.7.1                           Update available
neovim                    0.10.4_1                        Update available
fzf                       0.56.3                          Update available
```

## Updating Packages

To update packages after checking versions:

### APT packages:
```bash
sudo apt update
sudo apt upgrade
```

### Homebrew packages:
```bash
brew update
brew upgrade
```

## Troubleshooting

### Script not found
Make sure you're running from the project root directory (where `linux/packages.yml` is located).

### Permission denied
Make the script executable:
```bash
chmod +x utils/check_versions_simple.sh
```

### yq not found (for advanced script)
Install yq:
```bash
# On Ubuntu/Debian
sudo apt install yq

# On macOS
brew install yq
```

### Package lists not updating
The simple script uses hardcoded lists. To update them, edit the arrays in `check_versions_simple.sh` or use the advanced script that reads from `packages.yml`. 