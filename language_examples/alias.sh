#!/usr/bin/env dash

alias end="fi"

[[ 10 -eq 10 ]]; then
    echo hi
    alias end="fi"
    alias whatif='if'
fi