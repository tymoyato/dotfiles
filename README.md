# dotfiles

Personal configuration files for an Arch Linux setup with Awesome WM.

## Stack

| Layer | Tool |
|---|---|
| Shell | [Fish](https://fishshell.com/) |
| Window Manager | [Awesome WM](https://awesomewm.org/) |
| Terminal | [Kitty](https://sw.kovidgoyal.net/kitty/) |
| Editor | [Neovim](https://neovim.io/) |
| Compositor | [Picom](https://github.com/yshui/picom) |
| Launcher | [Rofi](https://github.com/davatorium/rofi) |
| System Monitor | [btop](https://github.com/aristocratos/btop) |
| Git TUI | [Lazygit](https://github.com/jesseduffield/lazygit) |

## Structure

```
dotfiles/
├── dotfiles/          # Config files (symlinked to ~/.config/)
│   ├── awesome/       # Awesome WM config (rc.lua, themes, widgets)
│   ├── btop/          # btop config & themes
│   ├── bruno/         # Bruno API client preferences
│   ├── fish/          # Fish shell config, functions, completions
│   ├── kitty/         # Kitty terminal config & theme
│   ├── lazygit/       # Lazygit config
│   ├── nvim/          # Neovim config (Lua, lazy.nvim)
│   ├── picom/         # Compositor config
│   └── rofi/          # Launcher config & scripts
├── packages/          # Install scripts (e.g. JetBrains Toolbox)
├── utils/             # Helper scripts (version checks, OS detection)
├── .devtools/         # Git identity setup
├── symlink.sh         # Creates ~/.config symlinks
└── setup.fish         # Installs language runtimes & tools
```

## Setup

### 1. Clone

```bash
git clone git@github.com:tymoyato/dotfiles.git ~/.dotfiles
```

### 2. Symlink configs

Links everything in `dotfiles/` into `~/.config/`:

```bash
bash ~/.dotfiles/symlink.sh
```

> **Note:** The script expects the repo at `~/.dotfiles`. If you cloned elsewhere, edit `repo_dir` in `symlink.sh` accordingly.

### 3. Install language runtimes & tools

Run inside Fish shell:

```fish
fish ~/.dotfiles/setup.fish
```

This installs:
- Fisher plugins
- Ruby 3.3.0 via rbenv + bundler
- Latest Node via NVM + yarn
- Go 1.23.2 via GVM

### 4. Configure git identity

Edit `.devtools/git.yml`:

```yaml
git:
  user:
    name: Your Name
    email: your@email.com
```

Then run:

```bash
bash ~/.dotfiles/.devtools/git.sh
```

## Version Checks

Check installed vs available package versions:

```bash
# No dependencies required
./utils/check_versions_simple.sh

# Requires yq
./utils/check_versions.sh
```

See [`utils/README_versions.md`](utils/README_versions.md) for details.
