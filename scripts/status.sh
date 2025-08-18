#! /usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$CURRENT_DIR/helpers.sh"

get_plugins_directory() {
    if [[ -v TMUX_PLUGIN_MANAGER_PATH ]]; then
        # use the TMUX_PLUGIN_MANAGER_PATH variable
        echo "$TMUX_PLUGIN_MANAGER_PATH"

    elif [[ -v XDG_CONFIG_HOME ]]; then
        # use the XDG_CONFIG_HOME variable
        echo "$XDG_CONFIG_HOME/tmux/plugins"

    elif [[ -d "$HOME/.config/tmux/plugins" ]]; then
        # use the default XDG config directory
        echo "$HOME/.config/tmux/plugins"

    elif [[ -d "$HOME/.tmux/plugins" ]]; then
        # use the default tmux plugins directory
        echo "$HOME/.tmux/plugins"

    else
        echo ""
    fi
}

get_plugins() {
    echo $(cat ~/.config/tmux/tmux.conf | awk '/^[ \t]*set(-option)? +-g +@plugin/ { gsub(/'\''/,""); gsub(/'\"'/,""); print $4 }')
}

get_environment_variable() {
    echo $(tmux show-environment -g "$1" 2>/dev/null | cut -d= -f2-)
}

lock_timestamp=$(get_environment_variable "TMUX_TMP_CHECK_LOCK")
current_timestamp=$(date +%s)

# log "Lock timestamp: $lock_timestamp"
# log "Current timestamp: $current_timestamp"

outdated_plugins=()

if [ -z "$lock_timestamp" ] || [ $((current_timestamp - lock_timestamp)) -gt 900 ]; then
    # log "Lock is missing or too old, proceeding with status check."
    tmux set-environment -g TMUX_TMP_CHECK_LOCK "$(date +%s)"

    for plugin in $(get_plugins); do
        # log "Checking plugin: $plugin"

        plugin_directory="$(get_plugins_directory)/$(basename "$plugin")"

        if [ -d "$plugin_directory" ]; then
            cd "$plugin_directory"
            $(git fetch --quiet)
            git_status=$(git status)

            if [[ ! "$git_status" =~ "Your branch is up to date" ]]; then
                outdated_plugins+="$plugin"
            fi

        else
            outdated_plugins+="$plugin"
        fi
    done

    tmux set-environment -g TMUX_TMP_OUTDATED_PLUGINS "$outdated_plugins"
else
    # Load the cached outdated plugins
    outdated_plugins=($(get_environment_variable "TMUX_TMP_OUTDATED_PLUGINS"))
fi

# log "Outdated plugins: ${outdated_plugins[@]}"

if [ ${#outdated_plugins[@]} -gt 0 ]; then
    echo "Updates available for ${outdated_plugins[@]}"
fi
