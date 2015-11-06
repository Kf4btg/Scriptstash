#!/bin/bash

[[ $# -lt 1 || "$1" =~ ^-h ]] && echo -e "Usage: $0 LAYOUT_FILE\nReturns count of all [BASEOBJECT] tags in LAYOUT_FILE" && exit 0

if [[ -r "$1" ]]; then
    open_count=$(grep -ic -F '[BASEOBJECT]' "$1")
    close_count=$(grep -ic -F '[/BASEOBJECT]' "$1")
    
    if (( $open_count != $close_count )) ; then
        echo "WARNING! Number of opening tags ($open_count) does not equal number of closing tags ($close_count)!" >&2
        _exit=1
    fi
    
    echo $open_count
else
    _exit=66
fi

exit ${_exit:-0}
