#!/bin/bash

# Installs CLI tools used across the dotfiles configs (tmux, nvim, kitty, etc.)
# Official repo packages via pacman, AUR-only ones via paru/yay.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils/colors.sh"

PACMAN_PACKAGES=(
	tmux
	fzf
	fd
	bat
	ripgrep
	lazygit
	neovim
	kitty
	picom
	rofi
	btop
	awesome
)

AUR_PACKAGES=(
	sesh-bin
)

install_cli_tools() {
	print_message "Installing CLI tools via pacman..." "instruction"
	sudo pacman -S --needed "${PACMAN_PACKAGES[@]}"

	local aur_helper=""
	if command -v paru &>/dev/null; then
		aur_helper="paru"
	elif command -v yay &>/dev/null; then
		aur_helper="yay"
	fi

	if [ -z "$aur_helper" ]; then
		print_message "No AUR helper (paru/yay) found — skipping: ${AUR_PACKAGES[*]}" "warning"
		return
	fi

	print_message "Installing CLI tools via $aur_helper (AUR)..." "instruction"
	"$aur_helper" -S --needed "${AUR_PACKAGES[@]}"
}

install_cli_tools
