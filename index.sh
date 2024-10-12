#!/bin/bash

# Define the alias name and the URL of the globally.sh script
ALIAS_NAME="globally"
SCRIPT_URL="https://raw.githubusercontent.com/michaeljamesrojas/scripts/main/globally.sh"

# Add the alias to the user's shell configuration file
add_alias() {
    local shell_rc="$HOME/.$(basename $SHELL)rc"
    echo "alias $ALIAS_NAME='bash <(curl -s $SCRIPT_URL)'" >> "$shell_rc"
    echo "Alias '$ALIAS_NAME' has been added to $shell_rc"
}

# Main execution
add_alias
echo "Please restart your terminal or run 'source $HOME/.$(basename $SHELL)rc' to use the new alias."