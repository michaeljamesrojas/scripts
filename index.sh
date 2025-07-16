#!/bin/bash

# Define the alias names and the URLs of the scripts
ALIAS_NAME1="ggg"
ALIAS_NAME2="globally"
ALIAS_NAME3="gg"
ALIAS_NAME4="x"
ALIAS_NAME5="ggf"

# SCRIPT_URL="https://raw.githubusercontent.com/michaeljamesrojas/scripts/main/globally.sh?token=$(date +%s)"
SCRIPT_URL="https://raw.githubusercontent.com/michaeljamesrojas/scripts/main/globally.sh"
AUTO_SCRIPT_URL="https://raw.githubusercontent.com/michaeljamesrojas/scripts/main/globally-auto.sh"
FAST_SCRIPT_URL="https://raw.githubusercontent.com/michaeljamesrojas/scripts/main/globally-auto-fast.sh"

# Add the alias to the user's shell configuration file
add_alias() {
    local alias_name="$1"
    local script_url="$2"
    local shell_rc="$HOME/.$(basename $SHELL)rc"
    echo "alias $alias_name='source <(curl -s $script_url)'" >> "$shell_rc"
    echo "Alias '$alias_name' has been added to $shell_rc"
}

# Add the ggf alias as a one-liner that doesn't require fetching from GitHub
add_ggf_alias() {
    local shell_rc="$HOME/.$(basename $SHELL)rc"
    
    # First add the function that will be used by the alias
    cat >> "$shell_rc" << 'EOF'
# Function to run globally-auto-fast script with local cache check
function run_ggf() {
    if [ -f "$TEMP/scripts-cache/scripts/globally-auto-fast.sh" ]; then
        echo "Using local script from $TEMP/scripts-cache/scripts/globally-auto-fast.sh"
        source "$TEMP/scripts-cache/scripts/globally-auto-fast.sh" "$@"
    else
        echo "Fetching script from GitHub..."
        source <(curl -s https://raw.githubusercontent.com/michaeljamesrojas/scripts/main/globally-auto-fast.sh) "$@"
    fi
}
EOF

    # Then add the alias that calls the function
    echo "alias $ALIAS_NAME5='run_ggf'" >> "$shell_rc"
    echo "Alias '$ALIAS_NAME5' has been added to $shell_rc"
}

# Main execution
add_alias "$ALIAS_NAME1" "$SCRIPT_URL"
add_alias "$ALIAS_NAME2" "$SCRIPT_URL"
add_alias "$ALIAS_NAME3" "$AUTO_SCRIPT_URL"
add_ggf_alias

# Add alias for exit command
echo "alias $ALIAS_NAME4='exit'" >> "$HOME/.$(basename $SHELL)rc"
echo "Alias '$ALIAS_NAME4' has been added to $HOME/.$(basename $SHELL)rc"

echo "Please restart your terminal or run 'source $HOME/.$(basename $SHELL)rc' to use the new aliases."