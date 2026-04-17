#!/bin/bash

setup_configs() {
	local config_dir="$HOME/.config"
	local repo_dir="$HOME/.dotfiles/dotfiles"

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
    "zellij"
    "zed"
    "yazi"
    "tmux"
	)

	# Remove existing configurations
	for config in "${configs[@]}"; do
		rm -rf "${config_dir:?}/${config:?}"
	done

	# Create symbolic links
	for config in "${configs[@]}"; do
		ln -sf "$repo_dir/$config" "$config_dir/$config"
	done

	echo "Configurations have been set up."
}

setup_home_configs() {
	local home_configs=(
		"xinitrc:.xinitrc"
		"claude:.claude"
	)

	for entry in "${home_configs[@]}"; do
		src="${entry%%:*}"
		dest="${entry##*:}"
		rm -f "$HOME/$dest"
		ln -sf "$HOME/.dotfiles/dotfiles/$src" "$HOME/$dest"
	done

	echo "Home configurations have been set up."
}

setup_dmenu_scripts() {
	local scripts_dir="$HOME/.dotfiles/dotfiles/dmenu_scripts"
	local bin_dir="$HOME/.local/bin"

	mkdir -p "$bin_dir"

	for script in "$scripts_dir"/*; do
		name=$(basename "$script")
		ln -sf "$script" "$bin_dir/$name"
		chmod +x "$script"
	done

	echo "Dmenu scripts have been set up."
}

# Call the functions
setup_configs
setup_home_configs
setup_dmenu_scripts
exec fish
