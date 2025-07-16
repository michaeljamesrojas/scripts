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
    echo "alias $ALIAS_NAME5='REPO_URL=\"https://github.com/michaeljamesrojas/scripts.git\"; REPO_NAME=\"scripts\"; TEMP_DIR=$(powershell.exe -command \"echo \\$env:TEMP\" | tr -d \"\\r\"); CACHE_DIR=\"$TEMP_DIR/scripts-cache\"; REPO_DIR=\"$CACHE_DIR/$REPO_NAME\"; if [ ! -d \"$REPO_DIR\" ]; then mkdir -p \"$CACHE_DIR\" && git clone \"$REPO_URL\" \"$REPO_DIR\" > /dev/null 2>&1 || echo \"Error: Failed to clone repository.\"; fi; cd \"$REPO_DIR\" && bash -c \"all_scripts=($(find . -maxdepth 1 -name \\\"*.sh\\\" -type f -exec basename {} \\\\;)); if [ \\\"$1\\\" != \\\"\\\" ]; then scripts=(); for script in \\\"${all_scripts[@]}\\\"; do if [[ \\\"$script\\\" == *\\\"$1\\\"* ]]; then scripts+=(\\\"$script\\\"); fi; done; shift; else scripts=(\\\"${all_scripts[@]}\\\"); fi; if [ ${#scripts[@]} -eq 0 ]; then echo \\\"No scripts found matching the filter.\\\"; exit 1; fi; if [ ${#scripts[@]} -eq 1 ]; then selected_script=\\\"${scripts[0]}\\\"; echo \\\"Only one script found: $selected_script. Executing automatically...\\\"; else for i in \\\"${!scripts[@]}\\\"; do echo \\\"$((i+1)). ${scripts[$i]}\\\"; done; read -p \\\"Enter the number of the script you want to execute: \\\" choice; if [[ ! \\\"$choice\\\" =~ ^[0-9]+$ ]] || [ \\\"$choice\\\" -lt 1 ] || [ \\\"$choice\\\" -gt \\\"${#scripts[@]}\\\" ]; then echo \\\"Invalid choice.\\\"; exit 1; fi; selected_script=\\\"${scripts[$((choice-1))]}\\\"; read -p \\\"Do you really want to execute $selected_script? (y/n): \\\" confirm; if [[ ! \\\"$confirm\\\" =~ ^[Yy]$ ]]; then echo \\\"Execution cancelled.\\\"; exit 0; fi; fi; script_path=\\\"$REPO_DIR/$selected_script\\\"; echo \\\"Executing script: $selected_script\\\"; source \\\"$script_path\\\" \\\"$@\\\"\"'" >> "$shell_rc"
    echo "One-liner alias '$ALIAS_NAME5' has been added to $shell_rc"
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