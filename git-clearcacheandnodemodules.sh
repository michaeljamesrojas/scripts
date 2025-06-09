#!/bin/bash

# Remove node_modules directory in current repo
echo "Removing node_modules folder..."
rm -rf node_modules

# Clear npm cache
if command -v npm >/dev/null 2>&1; then
  echo "Clearing npm cache..."
  npm cache clean --force
fi

# Clear yarn cache
if command -v yarn >/dev/null 2>&1; then
  echo "Clearing yarn cache..."
  yarn cache clean
fi

# Clear pnpm store cache
if command -v pnpm >/dev/null 2>&1; then
  echo "Pruning pnpm store..."
  pnpm store prune
fi

echo "Cache cleared and node_modules removed. You can now run your package manager install command."
