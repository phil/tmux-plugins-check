#! /usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$CURRENT_DIR/scripts/helpers.sh"

tmux_plugins_interpolations=(
    "\#{tmux_plugins_status}"
)

tmux_plugins_commands=(
    "#($CURRENT_DIR/scripts/status.sh)"
)

# Usage
# # interpolate_tmux_option <option>
interpolate_tmux_option() {
    local option=$1
    local option_value=$(get_tmux_option "$option")

    for ((i = 0; i < ${#tmux_plugins_commands[@]}; i++)); do
      option_value=${option_value/${tmux_plugins_interpolations[$i]}/${tmux_plugins_commands[$i]}}
    done

    set_tmux_option "$option" "$option_value"
}


main() {
    interpolate_tmux_option "status-right"
    interpolate_tmux_option "status-left"
}

main

