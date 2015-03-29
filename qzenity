#!/bin/bash
# A wrapper for qarma to allow for piping the input
# (like in regular zenity) rather than requiring it
# to be specified in place on the command line.

## just check for tty

if tty -s ; then
	qarma "$@"
else
	PIPEDIN="$(cat /dev/fd/0)"
	qarma "$@" $PIPEDIN
fi


