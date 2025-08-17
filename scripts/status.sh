#! /usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$CURRENT_DIR/helpers.sh"

log "Checking tmux plugins..."

#! /usr/bin/env bash

# export TMUX_TMP_CHECK_LOCK=$(date)

# echo $(date) > /tmp/tmux_check.lock

# set -g @plugin 'tmux-plugins/tpm'

plugins=$(cat ~/.config/tmux/tmux.conf | awk '/^[ \t]*set(-option)? +-g +@plugin/ { gsub(/'\''/,""); gsub(/'\"'/,""); print $4 }')

updates_available=0

for plugin in $plugins; do
    log "Checking plugin: $plugin"
    plugin_dir_name=$(basename "$plugin")
    log "Plugin directory name: $plugin_dir_name"
    if [ -d "$HOME/.local/state/tmux/plugins/$plugin_dir_name" ]; then
        cd "$HOME/.local/state/tmux/plugins/$plugin_dir_name"
        $(git fetch --quiet)
        git_status=$(git status)


        log "$git_status"

        if [[ "$git_status" =~ "Your branch is up to date" ]]; then
            log "Plugin $plugin up to date"
        else
            log "Plugin $plugin has updates available."
            updates_available=updates_available+1
        fi


    else
        update_available=update_available+1
        log "Plugin $plugin is not installed."
    fi
done

if [ $updates_available -eq 0 ]; then
    echo "All plugins are up to date."
else
    echo "$updates_available plugins have updates available."
fi
