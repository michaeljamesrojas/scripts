#!/bin/bash

# Check if branch name is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <branch_name>"
    exit 1
fi

BRANCH_NAME="$1"
PARENT_DIR=".."
WORKTREE_PATH="$PARENT_DIR/$BRANCH_NAME"

# Create worktree with new branch
```bash
git worktree add -b "$BRANCH_NAME" "$WORKTREE_PATH" HEAD
cd "$WORKTREE_PATH"
git reset --hard HEAD
git reset --soft HEAD~1