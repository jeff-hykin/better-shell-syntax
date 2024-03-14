#!/bin/sh

# The following line is valid shell code but everything after it is highlighted as a quote
case a in b ) printf '%s ' c; esac
&
test="$( case a in b ) printf '%s ' c; esac )"

case $1 in
    req*)
        ...
        ;;
    met*|meet*)
        ...
        ;;
    *)
        # You should have a default one too.
esac


shopt -s extglob
for arg in apple be cd meet o mississippi
do
    # call functions based on arguments
    case "$arg" in
        a*             ) foo;;    # matches anything starting with "a"
        b?             ) bar;;    # matches any two-character string starting with "b"
        c[de]          ) baz;;    # matches "cd" or "ce"
        me?(e)t        ) qux;;    # matches "met" or "meet"
        @(a|e|i|o|u)   ) fuzz;;   # matches one vowel
        m+(iss)?(ippi) ) fizz;;   # matches "miss" or "mississippi" or others
        *              ) bazinga;; # catchall, matches anything not matched above
    esac
done
