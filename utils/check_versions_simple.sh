#!/bin/bash

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source color utilities
. "$SCRIPT_DIR/colors.sh"

# Function to print colored output
print_message() {
    local message="$1"
    local type="$2"
    
    case $type in
        "info") echo -e "${BLUE}ℹ $message${NC}" ;;
        "success") echo -e "${GREEN}✓ $message${NC}" ;;
        "warning") echo -e "${YELLOW}⚠ $message${NC}" ;;
        "error") echo -e "${RED}✗ $message${NC}" ;;
        *) echo "$message" ;;
    esac
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to get apt package version
get_apt_version() {
    local package="$1"
    if dpkg -l | grep -q "^ii  $package "; then
        dpkg -l | grep "^ii  $package " | awk '{print $3}'
    else
        echo "Not installed"
    fi
}

# Function to get apt available version
get_apt_available_version() {
    local package="$1"
    apt-cache policy "$package" 2>/dev/null | grep "Candidate:" | awk '{print $2}'
}

# Function to get brew package version
get_brew_version() {
    local package="$1"
    if brew list | grep -q "^$package$"; then
        brew list --versions "$package" | awk '{print $2}'
    else
        echo "Not installed"
    fi
}

# Function to get brew available version
get_brew_available_version() {
    local package="$1"
    brew info "$package" 2>/dev/null | grep -E "^==> $package:" | head -1 | sed 's/.*stable //' | sed 's/ (bottled).*//'
}

# APT packages from packages.yml
APT_PACKAGES=(
    "build-essential"
    "git"
    "curl"
    "mercurial"
    "make"
    "binutils"
    "gcc"
    "bison"
    "wmctrl"
    "brave-browser"
    "zlib1g-dev"
    "shellcheck"
    "shfmt"
    "awesome"
    "i3lock-fancy"
    "kbdd"
    "rofi"
    "picom"
    "xclip"
    "flameshot"
    "xdotool"
    "light"
)

# Homebrew packages from packages.yml
BREW_PACKAGES=(
    "rbenv"
    "nvm"
    "fish"
    "eza"
    "btop"
    "atuin"
    "jless"
    "difftastic"
    "bat"
    "fzf"
    "zoxide"
    "neovim"
    "fisher"
    "ripgrep"
    "nvim"
    "unzip"
    "zellij"
    "go"
    "lazygit"
    "lazydocker"
)

# Function to check apt packages
check_apt_packages() {
    print_message "Checking APT packages..." "info"
    echo "=================================================="
    printf "%-25s %-15s %-15s %-10s\n" "Package" "Installed" "Available" "Status"
    echo "=================================================="
    
    for package in "${APT_PACKAGES[@]}"; do
        current_version=$(get_apt_version "$package")
        available_version=$(get_apt_available_version "$package")
        
        if [ "$current_version" = "Not installed" ]; then
            status="${RED}Not installed${NC}"
        elif [ "$current_version" = "$available_version" ]; then
            status="${GREEN}Up to date${NC}"
        else
            status="${YELLOW}Update available${NC}"
        fi
        
        printf "%-25s %-15s %-15s " "$package" "$current_version" "$available_version"
        echo -e "$status"
    done
    echo ""
}

# Function to check brew packages
check_brew_packages() {
    print_message "Checking Homebrew packages..." "info"
    echo "=================================================="
    printf "%-25s %-15s %-15s %-10s\n" "Package" "Installed" "Available" "Status"
    echo "=================================================="
    
    for package in "${BREW_PACKAGES[@]}"; do
        current_version=$(get_brew_version "$package")
        available_version=$(get_brew_available_version "$package")
        
        if [ "$current_version" = "Not installed" ]; then
            status="${RED}Not installed${NC}"
        elif [ "$current_version" = "$available_version" ]; then
            status="${GREEN}Up to date${NC}"
        else
            status="${YELLOW}Update available${NC}"
        fi
        
        printf "%-25s %-15s %-15s " "$package" "$current_version" "$available_version"
        echo -e "$status"
    done
    echo ""
}

# Function to update package lists
update_package_lists() {
    print_message "Updating package lists..." "info"
    
    if command_exists apt; then
        print_message "Updating APT package lists..." "info"
        sudo apt update >/dev/null 2>&1
    fi
    
    if command_exists brew; then
        print_message "Updating Homebrew package lists..." "info"
        brew update >/dev/null 2>&1
    fi
    
    echo ""
}

# Function to detect major version changes
is_major_update() {
    local current="$1"
    local available="$2"
    
    # Extract major version numbers (first number before dot)
    local current_major=$(echo "$current" | cut -d. -d- -d+ -d: -f1 | sed 's/[^0-9]//g')
    local available_major=$(echo "$available" | cut -d. -d- -d+ -d: -f1 | sed 's/[^0-9]//g')
    
    # If we can't parse major versions, assume it's not a major update
    if [ -z "$current_major" ] || [ -z "$available_major" ]; then
        return 1
    fi
    
    # Check if major version increased
    if [ "$available_major" -gt "$current_major" ]; then
        return 0
    fi
    
    return 1
}

# Function to get APT package description
get_apt_description() {
    local package="$1"
    apt-cache show "$package" 2>/dev/null | grep -E "^Description-en:" | head -1 | sed 's/Description-en: //'
}

# Function to get Homebrew package description
get_brew_description() {
    local package="$1"
    brew info "$package" 2>/dev/null | grep -A1 "^$package:" | tail -1 | sed 's/^[[:space:]]*//'
}

# Function to get APT changelog (last few entries)
get_apt_changelog() {
    local package="$1"
    local current_version="$2"
    local available_version="$3"
    
    # Try to get changelog for the package
    apt-get changelog "$package" 2>/dev/null | head -20 | grep -E "^.*\(.*\).*" | head -3 | sed 's/^/    /'
}

# Function to get Homebrew changelog info
get_brew_changelog() {
    local package="$1"
    
    # Try to get recent commits or releases from Homebrew
    brew info "$package" 2>/dev/null | grep -A5 -B5 "Updated" | head -10 | sed 's/^/    /'
}

# Function to show changelog
show_changelog() {
    print_message "📋 Update Changelog:" "info"
    echo "=================================================="
    
    local apt_updates_found=false
    local brew_updates_found=false
    local major_updates_found=false
    
    # Check APT packages for updates
    for package in "${APT_PACKAGES[@]}"; do
        current_version=$(get_apt_version "$package")
        available_version=$(get_apt_available_version "$package")
        
        if [ "$current_version" != "Not installed" ] && [ "$current_version" != "$available_version" ]; then
            if [ "$apt_updates_found" = false ]; then
                echo -e "${BLUE}APT Updates:${NC}"
                apt_updates_found=true
            fi
            
            # Get package description
            description=$(get_apt_description "$package")
            
            # Check if it's a major update
            if is_major_update "$current_version" "$available_version"; then
                echo -e "  ${RED}🚀 $package${NC}: $current_version → $available_version (Major Update!)"
                if [ -n "$description" ]; then
                    echo -e "    ${BLUE}📝${NC} $description"
                fi
                major_updates_found=true
            else
                echo -e "  ${YELLOW}• $package${NC}: $current_version → $available_version"
                if [ -n "$description" ]; then
                    echo -e "    ${BLUE}📝${NC} $description"
                fi
            fi
            echo ""
        fi
    done
    
    # Check Homebrew packages for updates
    for package in "${BREW_PACKAGES[@]}"; do
        current_version=$(get_brew_version "$package")
        available_version=$(get_brew_available_version "$package")
        
        if [ "$current_version" != "Not installed" ] && [ "$current_version" != "$available_version" ]; then
            if [ "$brew_updates_found" = false ]; then
                if [ "$apt_updates_found" = true ]; then
                    echo ""
                fi
                echo -e "${BLUE}Homebrew Updates:${NC}"
                brew_updates_found=true
            fi
            
            # Get package description
            description=$(get_brew_description "$package")
            
            # Check if it's a major update
            if is_major_update "$current_version" "$available_version"; then
                echo -e "  ${RED}🚀 $package${NC}: $current_version → $available_version (Major Update!)"
                if [ -n "$description" ]; then
                    echo -e "    ${BLUE}📝${NC} $description"
                fi
                major_updates_found=true
            else
                echo -e "  ${YELLOW}• $package${NC}: $current_version → $available_version"
                if [ -n "$description" ]; then
                    echo -e "    ${BLUE}📝${NC} $description"
                fi
            fi
            echo ""
        fi
    done
    
    if [ "$apt_updates_found" = false ] && [ "$brew_updates_found" = false ]; then
        echo -e "${GREEN}No updates available! All packages are up to date.${NC}"
    fi
    
    echo "=================================================="
    
    # Show major update warning
    if [ "$major_updates_found" = true ]; then
        echo ""
        echo -e "${RED}⚠️  Major updates detected! Please review changelogs before updating.${NC}"
    fi
    
    echo ""
}

# Function to show detailed changelog for major updates
show_detailed_changelog() {
    local major_updates_found=false
    
    # Check for major updates
    for package in "${APT_PACKAGES[@]}" "${BREW_PACKAGES[@]}"; do
        if [[ " ${APT_PACKAGES[@]} " =~ " ${package} " ]]; then
            current_version=$(get_apt_version "$package")
            available_version=$(get_apt_available_version "$package")
        else
            current_version=$(get_brew_version "$package")
            available_version=$(get_brew_available_version "$package")
        fi
        
        if [ "$current_version" != "Not installed" ] && [ "$current_version" != "$available_version" ]; then
            if is_major_update "$current_version" "$available_version"; then
                if [ "$major_updates_found" = false ]; then
                    print_message "🔍 Detailed Changelog for Major Updates:" "info"
                    echo "=================================================="
                    major_updates_found=true
                fi
                
                echo -e "${RED}🚀 $package${NC}: $current_version → $available_version"
                
                # Try to get changelog information
                if [[ " ${APT_PACKAGES[@]} " =~ " ${package} " ]]; then
                    changelog=$(get_apt_changelog "$package" "$current_version" "$available_version")
                else
                    changelog=$(get_brew_changelog "$package")
                fi
                
                if [ -n "$changelog" ]; then
                    echo -e "${BLUE}📋 Recent changes:${NC}"
                    echo "$changelog"
                else
                    echo -e "${YELLOW}📋 No detailed changelog available${NC}"
                fi
                echo ""
            fi
        fi
    done
    
    if [ "$major_updates_found" = true ]; then
        echo "=================================================="
        echo ""
    fi
}

# Function to show summary
show_summary() {
    print_message "📊 Summary:" "info"
    
    local apt_installed=0
    local apt_up_to_date=0
    local apt_updates=0
    local apt_not_installed=0
    
    local brew_installed=0
    local brew_up_to_date=0
    local brew_updates=0
    local brew_not_installed=0
    
    # Count APT packages
    for package in "${APT_PACKAGES[@]}"; do
        current_version=$(get_apt_version "$package")
        available_version=$(get_apt_available_version "$package")
        
        if [ "$current_version" = "Not installed" ]; then
            ((apt_not_installed++))
        elif [ "$current_version" = "$available_version" ]; then
            ((apt_up_to_date++))
            ((apt_installed++))
        else
            ((apt_updates++))
            ((apt_installed++))
        fi
    done
    
    # Count Homebrew packages
    for package in "${BREW_PACKAGES[@]}"; do
        current_version=$(get_brew_version "$package")
        available_version=$(get_brew_available_version "$package")
        
        if [ "$current_version" = "Not installed" ]; then
            ((brew_not_installed++))
        elif [ "$current_version" = "$available_version" ]; then
            ((brew_up_to_date++))
            ((brew_installed++))
        else
            ((brew_updates++))
            ((brew_installed++))
        fi
    done
    
    echo "APT Packages:"
    echo "  - Installed: ${apt_installed}/${#APT_PACKAGES[@]}"
    echo "  - Up to date: ${apt_up_to_date}"
    echo "  - Updates available: ${apt_updates}"
    echo "  - Not installed: ${apt_not_installed}"
    echo ""
    echo "Homebrew Packages:"
    echo "  - Installed: ${brew_installed}/${#BREW_PACKAGES[@]}"
    echo "  - Up to date: ${brew_up_to_date}"
    echo "  - Updates available: ${brew_updates}"
    echo "  - Not installed: ${brew_not_installed}"
    echo ""
}

# Main function
main() {
    print_message "Package Version Checker (Simple)" "info"
    print_message "This script checks current vs available versions for APT and Homebrew packages" "info"
    echo ""
    
    # Update package lists first
    update_package_lists
    
    # Check APT packages
    if command_exists apt; then
        check_apt_packages
    else
        print_message "APT not found. Skipping APT packages." "warning"
    fi
    
    # Check Homebrew packages
    if command_exists brew; then
        check_brew_packages
    else
        print_message "Homebrew not found. Skipping Homebrew packages." "warning"
    fi
    
    # Show changelog
    show_changelog
    
    # Show detailed changelog for major updates
    show_detailed_changelog
    
    # Show summary
    show_summary
    
    print_message "Version check completed!" "success"
}

# Run main function
main "$@" 