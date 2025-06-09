#!/bin/bash

# Define the alias names and the URLs of the scripts
ALIAS_NAME1="ggg"
ALIAS_NAME2="globally"
ALIAS_NAME3="gg"
ALIAS_NAME4="x"

# SCRIPT_URL="https://raw.githubusercontent.com/michaeljamesrojas/scripts/main/globally.sh?token=$(date +%s)"
SCRIPT_URL="https://raw.githubusercontent.com/michaeljamesrojas/scripts/main/globally.sh"
AUTO_SCRIPT_URL="https://raw.githubusercontent.com/michaeljamesrojas/scripts/main/globally-auto.sh"

# Add the alias to the user's shell configuration file
add_alias() {
    local alias_name="$1"
    local script_url="$2"
    local shell_rc="$HOME/.$(basename $SHELL)rc"
    echo "alias $alias_name='source <(curl -s $script_url)'" >> "$shell_rc"
    echo "Alias '$alias_name' has been added to $shell_rc"
}

# Main execution
add_alias "$ALIAS_NAME1" "$SCRIPT_URL"
add_alias "$ALIAS_NAME2" "$SCRIPT_URL"
add_alias "$ALIAS_NAME3" "$AUTO_SCRIPT_URL"

# Add alias for exit command
echo "alias $ALIAS_NAME4='exit'" >> "$HOME/.$(basename $SHELL)rc"
echo "Alias '$ALIAS_NAME4' has been added to $HOME/.$(basename $SHELL)rc"

echo "Please restart your terminal or run 'source $HOME/.$(basename $SHELL)rc' to use the new aliases."