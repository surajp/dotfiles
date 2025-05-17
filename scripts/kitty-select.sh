#!/bin/bash

if ! command -v kitten &> /dev/null; then
  echo "Kitten command not found. Please ensure you have kitty installed."
  exit 1
fi

if ! command -v fzf &> /dev/null; then
  export PATH="$PATH:/usr/local/bin:/opt/homebrew/bin"
fi

# Check if ~/projects directory exists
if [ ! -d "$HOME/projects" ]; then
  echo "~/projects directory not found"
  exit 1
fi

# Get list of directories in ~/projects
project_dirs=$(find "$HOME/projects" -maxdepth 1 -type d -not -path "$HOME/projects" | sort)

# Check if we found any directories
if [ -z "$project_dirs" ]; then
  echo "No project directories found in ~/projects"
  exit 1
fi

# Use fzf to select a project directory
selected_dir=$(echo "$project_dirs" | xargs -n1 basename | fzf --prompt="Select project: " --height=40% --reverse)

# Check if user made a selection (not cancelled with escape)
if [ -z "$selected_dir" ]; then
  exit 0
fi

# Get full path of selected directory (expand $HOME to absolute path)
selected_path=$(realpath "$HOME/projects/$selected_dir")

foldername=$(basename "$selected_path")

# Get current kitty tabs and check if any tab has the same title
existing_tab=$(kitten @ ls | jq -r --arg title "$foldername" '
  .[] | 
  .tabs[] | 
  select(.title == $title) | 
  .id
' | head -n1)

if [ -n "$existing_tab" ]; then
  # Focus the existing window
  kitten @ focus-tab -m id:"$existing_tab"
else
  foldername=$(basename "$selected_path")
  # Open a new kitty window in the selected directory
  kitten @ launch --type=tab --cwd="$selected_path" --tab-title="$foldername"
fi
