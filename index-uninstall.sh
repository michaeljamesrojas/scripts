#!/bin/bash

# Define the alias names to be removed
ALIAS_NAME1="ggg"
ALIAS_NAME2="globally"

# Remove the aliases from the user's shell configuration file
remove_alias() {
    local alias_name="$1"
    local shell_rc="$HOME/.$(basename $SHELL)rc"
    sed -i "/alias $alias_name=/d" "$shell_rc"
    echo "Alias '$alias_name' has been removed from $shell_rc"
}

# Main execution
remove_alias "$ALIAS_NAME1"
remove_alias "$ALIAS_NAME2"
echo "Please restart your terminal or run 'source $HOME/.$(basename $SHELL)rc' to apply the changes."
