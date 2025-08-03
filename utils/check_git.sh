#!/bin/bash

check_git() {
	if ! command -v git &>/dev/null; then
		printf '%sgit is not installed.%s\n' "${YELLOW}" "${NC}"
		exit 1
	fi
}
