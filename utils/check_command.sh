#!/bin/bash

check_command() {
	if [ $? -ne 0 ]; then
		printf '%sCommand failed: %s%s\n' "${RED}" "$1" "${NC}"
		exit 1
	fi
}
