#!/bin/bash

check_sudo() {
	print_message "Checking if the user has sudo privileges..." "instruction"

	# Check if the user has sudo privileges
	if ! sudo -n true 2>/dev/null; then
		print_message "User does not have sudo privileges. Adding user to sudoers..." "warning"

		if [[ "$OS" == "Linux" ]]; then
			sudo_user=$(whoami)
			sudo_command="echo '$sudo_user ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers"

			# Add the user to sudoers
			print_message "Enter superuser password" "instruction"
			if ! su -c "$sudo_command"; then
				print_message "Failed to add user to sudoers." "fail"
				exit 1
			fi
		else
			print_message "Unsupported operating system for adding sudo privileges: ${OS}" "fail"
			exit 1
		fi
	else
		print_message "User has sudo privileges." "success"
	fi

	return 0
}
