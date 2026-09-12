#!/bin/bash

check_and_start() {
  local process_name=$1
  local command=$2

  if pgrep -x "$process_name" >/dev/null; then
    if ! wmctrl -xa "$process_name"; then
      "$command" &
    fi
  else
    "$command" &
  fi
}


pgrep -x greenclip > /dev/null || greenclip daemon &

declare -A processes=(
  ["brave"]="brave"
  ["kitty"]="kitty"
)

for process_name in "${!processes[@]}"; do
  command=${processes[$process_name]}
  check_and_start "$process_name" "$command" &
done

# Stagger heavier apps so they don't fight Brave/kitty for CPU/disk at login
(
  sleep 4
  declare -A late_processes=(
    ["zeditor"]="zeditor"
    ["obsidian"]="obsidian"
  )
  for process_name in "${!late_processes[@]}"; do
    command=${late_processes[$process_name]}
    check_and_start "$process_name" "$command" &
  done
  pgrep -fi "bruno" > /dev/null || /home/tymoyato/Downloads/bruno_3.3.0_x86_64_linux.AppImage &
) &
