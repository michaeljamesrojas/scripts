#!/bin/bash

# Default target branch
DEFAULT_TARGET_BRANCH="develop"

# Prompt for target branch confirmation
read -p "Enter target branch [default: $DEFAULT_TARGET_BRANCH]: " TARGET_BRANCH

# Use default if no input provided
TARGET_BRANCH=${TARGET_BRANCH:-$DEFAULT_TARGET_BRANCH}

echo "Using target branch: $TARGET_BRANCH"

# Execute the git operations with the confirmed target branch
source <(curl -s https://raw.githubusercontent.com/michaeljamesrojas/scripts/main/git-backup-branch-local.sh) && \
git checkout "$TARGET_BRANCH" && \
git reset --hard HEAD~30 && \
git pull && \
git checkout - && \
git log "origin/$TARGET_BRANCH" -n 1 && \
git log "$TARGET_BRANCH" -n 1 && \
git rebase "$TARGET_BRANCH"

#OLD: source <(curl -s https://raw.githubusercontent.com/michaeljamesrojas/scripts/main/git-backup-branch-local.sh) && git checkout develop && git reset --hard HEAD~30 && git pull && git checkout - && git log origin/develop -n 1 && git log develop -n 1 && git rebase develop
