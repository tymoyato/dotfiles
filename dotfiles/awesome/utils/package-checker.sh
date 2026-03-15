#!/bin/bash

# Package Checker Script for AwesomeWM
# This script runs the version checker and stores output in a log file

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the project root directory (parent of dotfiles)
PROJECT_ROOT="$(dirname "$(dirname "$(dirname "$SCRIPT_DIR")")")"

# Define log file path
LOG_FILE="$PROJECT_ROOT/linux/package_updates.log"

# Create linux directory if it doesn't exist
mkdir -p "$PROJECT_ROOT/linux"

# Check if we should run today
TODAY=$(date '+%Y-%m-%d')
LAST_RUN_FILE="$PROJECT_ROOT/linux/last_package_check.txt"

# Check if force run is requested (from widget click)
FORCE_RUN=false
if [ "$1" = "--force" ]; then
    FORCE_RUN=true
    echo "Force run requested - bypassing daily limit"
fi

# Check if we already ran today (unless force run)
if [ "$FORCE_RUN" = false ] && [ -f "$LAST_RUN_FILE" ]; then
    LAST_RUN=$(cat "$LAST_RUN_FILE" 2>/dev/null)
    if [ "$LAST_RUN" = "$TODAY" ]; then
        echo "Package check already run today ($TODAY). Skipping."
        exit 0
    fi
fi

# Log that we're starting the check
echo "Starting package check for $TODAY"

# Remove existing log file if it exists
if [ -f "$LOG_FILE" ]; then
    rm "$LOG_FILE"
fi

# Function to log with timestamp
log_with_timestamp() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $message" >> "$LOG_FILE"
}

# Start logging
log_with_timestamp "=== Package Version Check Started ==="

# Change to the project root directory
cd "$PROJECT_ROOT" || {
    log_with_timestamp "ERROR: Could not change to project root directory"
    exit 1
}

# Check if the version checker script exists
if [ ! -f "./utils/check_versions_simple.sh" ]; then
    log_with_timestamp "ERROR: Version checker script not found at ./utils/check_versions_simple.sh"
    exit 1
fi

# Run the version checker and capture output
log_with_timestamp "Running version checker..."
{
    echo "=== Package Version Check Output ==="
    echo "Date: $(date)"
    echo "User: $(whoami)"
    echo "Host: $(hostname)"
    echo ""
    
    # Run the version checker script
    bash ./utils/check_versions_simple.sh 2>&1
    
    echo ""
    echo "=== Check Completed ==="
} >> "$LOG_FILE"

# Log completion
log_with_timestamp "Package version check completed successfully"
log_with_timestamp "Log file: $LOG_FILE"

# Optional: Keep only last 10 log entries to prevent file from growing too large
if [ -f "$LOG_FILE" ]; then
    # Count total lines
    total_lines=$(wc -l < "$LOG_FILE")
    
    # If more than 1000 lines, keep only the last 500
    if [ "$total_lines" -gt 1000 ]; then
        log_with_timestamp "Truncating log file to last 500 lines"
        tail -n 500 "$LOG_FILE" > "${LOG_FILE}.tmp" && mv "${LOG_FILE}.tmp" "$LOG_FILE"
    fi
fi

log_with_timestamp "=== Package Version Check Finished ==="
echo "" >> "$LOG_FILE"

# Record that we ran today
echo "$TODAY" > "$LAST_RUN_FILE"
echo "Recorded run date: $TODAY in $LAST_RUN_FILE" 