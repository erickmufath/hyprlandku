#!/bin/bash

# Get existing workspace numbers from hyprctl
mapfile -t workspaces < <(hyprctl workspaces | grep 'workspace ID' | awk '{print $3}' | sort -n)

# Make sure we got something
if [[ ${#workspaces[@]} -eq 0 ]]; then
  echo "No existing workspaces found."
  exit 1
fi

# Get current active workspace ID
current=$(hyprctl activeworkspace | grep 'workspace ID' | awk '{print $3}')

# Find index of current workspace
current_index=-1
for i in "${!workspaces[@]}"; do
  if [[ "${workspaces[i]}" == "$current" ]]; then
    current_index=$i
    break
  fi
done

# Error if current workspace is not found
if [[ "$current_index" == "-1" ]]; then
  echo "Current workspace not found in workspace list."
  exit 1
fi

# Decide next or previous
len=${#workspaces[@]}
if [[ "$1" == "next" ]]; then
  next_index=$(( (current_index + 1) % len ))
  target=${workspaces[$next_index]}
elif [[ "$1" == "prev" ]]; then
  next_index=$(( (current_index - 1 + len) % len ))
  target=${workspaces[$next_index]}
else
  echo "Usage: $0 next|prev"
  exit 1
fi

# Switch to target workspace
hyprctl dispatch workspace "$target"

