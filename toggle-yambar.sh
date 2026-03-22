#!/bin/sh

STATE_FILE="/tmp/yambar_hidden"

# Kill existing yambar cleanly
pkill -x yambar

# Give it a moment to fully exit
sleep 0.2

if [ -f "$STATE_FILE" ]; then
    rm "$STATE_FILE"
    yambar -c ~/.config/yambar/config.yml &
else
    touch "$STATE_FILE"
    yambar -c ~/.config/yambar/config-hidden.yml &
fi
