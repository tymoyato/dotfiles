#!/bin/bash

check_and_start() {
  local process_name=$1
  local command=$2

  echo "Checking process: $process_name"

  if pgrep -x "$process_name" >/dev/null; then
    echo "Process $process_name is running."
    if ! wmctrl -xa "$process_name"; then
      echo "Window for $process_name not found. Starting new instance."
      "$command" &
    else
      echo "Window for $process_name brought to foreground."
    fi
  else
    echo "Process $process_name is not running. Starting new instance."
    "$command" &
  fi
}


pgrep -x greenclip > /dev/null || greenclip daemon &
pgrep -fi "bruno" > /dev/null || /home/tymoyato/Downloads/bruno_3.2.2_x86_64_linux.AppImage &

declare -A processes=(
  ["Brave-browser"]="Brave-browser"
  ["kitty"]="kitty"
  ["slack"]="slack"
  ["obsidian"]="obsidian"
  ["jetbrains-rubymine"]="jetbrains-rubymine"
)

for process_name in "${!processes[@]}"; do
  command=${processes[$process_name]}
  check_and_start "$process_name" "$command"
done
