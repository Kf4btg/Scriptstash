#!/bin/sh

CONFIG="$HOME/.config/synclient-customrc"


cat "$CONFIG" | egrep -v '^\s*(#|$)' | while IFS= read -r setParam; do 
    eval "synclient $setParam"
done 
