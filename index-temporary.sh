#!/bin/bash

# Define the alias name and the URL of the globally.sh script
ALIAS_NAME="globally"
SCRIPT_URL="https://raw.githubusercontent.com/michaeljamesrojas/scripts/main/globally.sh"

# Add the alias to the current shell session
add_alias_temp() {
    alias $ALIAS_NAME="source <(curl -s $SCRIPT_URL)"
    echo "Temporary alias '$ALIAS_NAME' has been added to the current shell session."
}

# Main execution
add_alias_temp