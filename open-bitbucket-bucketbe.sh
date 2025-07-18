cd 'C:\Users\micha\OneDrive\Documents\Skand\skand.platform.backend2'


remote_url=$(git config --get remote.origin.url) && [ -n "$remote_url" ] && remote_url=$(echo "$remote_url" | sed -E 's/^git@(.*):(.*)\.git$/https:\/\/\1\/\2/; s/\.git$//') && (uname | grep -q Darwin && open "$remote_url" || (uname | grep -q Linux && (command -v gio >/dev/null 2>&1 && gio open "$remote_url" || xdg-open "$remote_url") || (uname | grep -E 'MINGW|MSYS|CYGWIN' >/dev/null && start "" "$remote_url" || echo "Unsupported OS. Open manually: $remote_url")))