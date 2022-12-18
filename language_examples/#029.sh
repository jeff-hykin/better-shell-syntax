#!/usr/bin/env sh

# works:
a="${-:+"-$-"}"
1="`mpp`"

# works:
date() {
    a="${-:+"-$-"}"
    set +x; if [ -n "${a}" ]; then set -x; else set +x; fi

    if [ "$(uname)" = "Darwin" ]; then
        command date -j "$@"
    else
        command date "$@"
    fi

    set +x ${a}
    unset a
}

# works:
nulldef; date()
{
    a="${-:+"-$-"}"
    set +x; if [ -n "${a}" ]; then set -x; else set +x; fi

    if [ "$(uname)" = "Darwin" ]; then
        command date -j "$@"
    else
        command date "$@"
    fi

    set +x ${a}
    unset a
}

# does not work:
nulldef; date() {
    a="${-:+"-$-"}"
    set +x; if [ -n "${a}" ]; then set -x; else set +x; fi

    if [ "$(uname)" = "Darwin" ]; then
        command date -j "$@"
    else
        command date "$@"
    fi

    set +x ${a}
    unset a
}