#!/bin/bash

# Repo root = wherever this script lives, so the repo can be cloned anywhere
repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/dotfiles"

# Link $1 -> $2. A real file/dir already at $2 is moved to $2.bak, never deleted.
link() {
	local src="$1" dest="$2"
	if [ -L "$dest" ]; then
		rm "$dest"
	elif [ -e "$dest" ]; then
		mv "$dest" "$dest.bak.$(date +%s)"
		echo "Backed up existing $dest"
	fi
	ln -s "$src" "$dest"
}

setup_configs() {
	local config_dir="$HOME/.config"
	mkdir -p "$config_dir"

	# List of configuration directories and files
	local configs=(
		"fish"
		"kitty"
		"nvim"
		"awesome"
		"picom"
		"rofi"
		"lazygit"
		"btop"
		"zed"
		"tmux"
		"betterlockscreen"
	)

	for config in "${configs[@]}"; do
		link "$repo_dir/$config" "$config_dir/$config"
	done

	echo "Configurations have been set up."
}

setup_home_configs() {
	local home_configs=(
		"xinitrc:.xinitrc"
	)

	for entry in "${home_configs[@]}"; do
		link "$repo_dir/${entry%%:*}" "$HOME/${entry##*:}"
	done

	echo "Home configurations have been set up."
}

setup_dmenu_scripts() {
	local scripts_dir="$repo_dir/dmenu_scripts"
	local bin_dir="$HOME/.local/bin"

	mkdir -p "$bin_dir"

	for script in "$scripts_dir"/*; do
		[ -e "$script" ] || continue
		chmod +x "$script"
		link "$script" "$bin_dir/$(basename "$script")"
	done

	echo "Dmenu scripts have been set up."
}

# Call the functions
setup_configs
setup_home_configs
setup_dmenu_scripts
exec fish
