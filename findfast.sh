#!/bin/bash

# Function to check if fd is installed
check_fd() {
  command -v fd >/dev/null 2>&1
}

# Function to install fd (Windows binary) if not present
install_fd() {
  echo "fd not found. Installing fd..."
  FD_VERSION="8.7.0"
  FD_ZIP="fd-v${FD_VERSION}-x86_64-pc-windows-msvc.zip"
  FD_URL="https://github.com/sharkdp/fd/releases/download/v${FD_VERSION}/${FD_ZIP}"
  TMP_DIR="/tmp/fd_install"

  mkdir -p "$TMP_DIR"
  cd "$TMP_DIR" || exit 1

  echo "Downloading fd from $FD_URL ..."
  curl -L -o "$FD_ZIP" "$FD_URL" || { echo "Failed to download fd"; exit 1; }

  echo "Extracting fd archive..."
  unzip -o "$FD_ZIP" || { echo "Failed to unzip fd archive"; exit 1; }

  EXTRACTED_DIR="fd-v${FD_VERSION}-x86_64-pc-windows-msvc"
  BIN_DIR="$HOME/.local/bin"
  mkdir -p "$BIN_DIR"

  echo "Installing fd.exe to $BIN_DIR ..."
  mv "$EXTRACTED_DIR/fd.exe" "$BIN_DIR/" || { echo "Failed to move fd.exe"; exit 1; }

  # Add ~/.local/bin to PATH if not already present
  if ! echo "$PATH" | grep -q "$BIN_DIR"; then
    echo "Adding $BIN_DIR to PATH in ~/.bashrc"
    echo 'export PATH=$PATH:'"$BIN_DIR" >> "$HOME/.bashrc"
    export PATH=$PATH:"$BIN_DIR"
  fi

  echo "fd installed successfully to $BIN_DIR/fd.exe"

  cd - >/dev/null || exit 1
  rm -rf "$TMP_DIR"
}

# Check and install fd if necessary
if ! check_fd; then
  install_fd
fi

# Prompt user for filename pattern and optional flags
read -rp "Enter filename pattern to search (e.g. '*.txt'): " pattern
read -rp "Enter additional fd flags (e.g. -i for case-insensitive) or leave empty: " flags

# Define drives to search (modify as needed)
drives=(/c /d /e /f /g)

# Run fd on each existing drive
echo "Searching for pattern '$pattern' with flags '$flags' on drives: ${drives[*]}"
for drive in "${drives[@]}"; do
  if [ -d "$drive" ]; then
    echo "Searching in $drive ..."
    fd $flags "$pattern" "$drive"
  fi
done
