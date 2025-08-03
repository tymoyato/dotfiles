#!/bin/bash

check_curl() {
	if ! command -v curl &>/dev/null; then
		printf '%scurl is not installed.%s\n' "$YELLOW" "$NC"
		exit 1
	fi
}
