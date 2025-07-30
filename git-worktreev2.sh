#!/bin/bash

# Prompt user for branch name
read -p "Enter the branch name (e.g. origin/feature-x): " BRANCH

# Create a safe folder name from the branch (replace / with -)
FOLDER_BRANCH=$(echo "$BRANCH" | sed 's|/|-|g' | sed 's|origin-||')

# Generate human-readable datetime suffix with seconds included
DATE_SUFFIX=$(date +"%Y%m%d-%H%M%S")

# Worktree & folder root: one level above current, in 'worktrees'
WORKTREES_ROOT="../worktrees"
TARGET_FOLDER="${WORKTREES_ROOT}/${FOLDER_BRANCH}-${DATE_SUFFIX}"

# Ensure worktrees root exists
if [[ ! -d "$WORKTREES_ROOT" ]]; then
  mkdir -p "$WORKTREES_ROOT"
fi

# Optionally create a new branch with the suffix
NEW_BRANCH="${FOLDER_BRANCH}-${DATE_SUFFIX}"
git branch "$NEW_BRANCH" "$BRANCH"

# Add worktree
git worktree add "$TARGET_FOLDER" "$NEW_BRANCH"

echo "Worktree created at: $TARGET_FOLDER"

# Change directory to the new worktree folder and run 'windsurf .'
cd "$TARGET_FOLDER" && windsurf .
