#!/bin/bash

# Define the alias name and the URL of the globally.sh script
ALIAS_NAME1="ggg"
ALIAS_NAME2="globally"

# SCRIPT_URL="https://raw.githubusercontent.com/michaeljamesrojas/scripts/main/globally.sh?token=$(date +%s)"
SCRIPT_URL="https://raw.githubusercontent.com/michaeljamesrojas/scripts/main/globally.sh"

# Add the alias to the user's shell configuration file
add_alias() {
    local alias_name="$1"
    local shell_rc="$HOME/.$(basename $SHELL)rc"
    echo "alias $alias_name='source <(curl -s $SCRIPT_URL)'" >> "$shell_rc"
    echo "Alias '$alias_name' has been added to $shell_rc"
}


# Main execution
add_alias "$ALIAS_NAME1"
add_alias "$ALIAS_NAME2"
echo "Please restart your terminal or run 'source $HOME/.$(basename $SHELL)rc' to use the new alias."