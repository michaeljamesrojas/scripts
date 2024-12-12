#!/bin/bash

# Check if branch name is provided
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: $0 <branch_name> <commit_sha>"
    exit 1
fi

BRANCH_NAME="$1"
COMMIT_SHA="$2"
PARENT_DIR=".."
WORKTREE_PATH="$PARENT_DIR/$BRANCH_NAME"

# Verify if the provided SHA exists
if ! git rev-parse --quiet --verify "$COMMIT_SHA" >/dev/null; then
    echo "Error: Invalid commit SHA provided"
    exit 1
fi

git worktree add -b "$BRANCH_NAME" "$WORKTREE_PATH" HEAD && cd "$WORKTREE_PATH" && git reset --hard "$COMMIT_SHA" && git reset --soft HEAD~1 && git reset --soft HEAD~1