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
│   ├── betterlockscreen/
│   ├── btop/          # btop config & themes
│   ├── fish/          # Fish shell config, functions, completions
│   ├── kitty/         # Kitty terminal config & theme
│   ├── lazygit/       # Lazygit config
│   ├── nvim/          # Neovim config (Lua, lazy.nvim)
│   ├── picom/         # Compositor config
│   ├── rofi/          # Launcher config & scripts
│   ├── tmux/          # tmux config & scripts (plugins auto-installed)
│   └── zed/           # Zed editor config
├── symlink.sh         # Creates ~/.config symlinks
└── setup.fish         # Installs language runtimes & tools
```

## Setup

### 1. Install packages

Every package these configs call is installed by [tymoyato/arch](https://github.com/tymoyato/arch):

```bash
git clone https://github.com/tymoyato/arch.git ~/arch
bash ~/arch/packages.sh
```

### 2. Clone

```bash
git clone git@github.com:tymoyato/dotfiles.git ~/.dotfiles
```

### 3. Symlink configs

Links everything in `dotfiles/` into `~/.config/` (plus `~/.xinitrc` and `~/.local/bin/rofi`). Existing real configs are moved to `<name>.bak.<timestamp>`, never deleted. Works from any clone location.

```bash
bash ~/.dotfiles/symlink.sh
```

### 4. Install language runtimes & tools

Run inside Fish shell:

```fish
fish ~/.dotfiles/setup.fish
```

This installs:
- Fisher plugins listed in `dotfiles/fish/fish_plugins`
- Ruby 3.3.0 via rbenv + bundler
- Latest Node via NVM + yarn

tmux plugins (TPM) install themselves on the first tmux start.

## Per-machine behavior

- **Display:** `awesome/display-setup.sh` sets each connected output to its preferred resolution at its highest refresh rate. The NVIDIA `ForceCompositionPipeline` line in `xinitrc` only runs when `DP-2` is connected.
- **Battery / CPU temp widgets:** auto-detect `BAT*` and the CPU hwmon sensor (`coretemp`, `k10temp`, `zenpower`).
- **Brightness widget:** uses `ddcutil` (external monitors over DDC/CI); does nothing on laptop panels.
- **PipeWire 96 kHz config** (`dotfiles/pipewire/`) is not linked by default. Link it manually on machines with a hi-res DAC.
