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