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

for ((i=0; i<${#ID[@]}; i++)); {
    do_something
}

A=$(
    for ((i=0; i<${#ID[@]}; i++)); {
       do_something
    }
) # <- check this

A=$(
    for ((i=0; i<${#ID[@]}; i++)); do
        do_something
    done
)

A=$(\
    for ((i=0; i<${#ID[@]}; i++)); {
        do_something
    }
)

for profile_target in "${PROFILE_TARGETS[@]}"; do
    # TODO: I think it would be good to accumulate a list of all
    #       of the copies so that people don't hit this 2 or 3x in
    #       a row for different files.
    if [ -e "$profile_target$PROFILE_BACKUP_SUFFIX" ]; then
        # this backup process first released in Nix 2.1
        at_least_one_failed="true"
        failed_check "$profile_target$PROFILE_BACKUP_SUFFIX already exists"
    else
        passed_check "$profile_target$PROFILE_BACKUP_SUFFIX does not exist yet"
    fi
done