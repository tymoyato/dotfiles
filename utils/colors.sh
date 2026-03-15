#!/bin/bash

# ANSI color codes
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export RED='\033[0;31m'
export BLUE='\033[0;34m'
export ORANGE='\033[0;33m'
export NC='\033[0m' # No Color

print_message() {
    local message=$1
    local type=$2

    case $type in
        warning)
            printf "${YELLOW}%s${NC}\n" "$message"
            ;;
        instruction)
            printf "${YELLOW}%s${NC}\n" "$message"
            ;;
        success)
            printf "${GREEN}%s${NC}\n" "$message"
            ;;
        fail)
            printf "${RED}%s${NC}\n" "$message"
            ;;
        *)
            printf "%s\n" "$message"  # No color for unknown types
            ;;
    esac
}