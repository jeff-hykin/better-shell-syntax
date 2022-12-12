#        (   )    zsh glob qualifiers
#         #q      glob expansion inside conditional expressions
#           N     null glob for no error if no matches
#                 then/fi not required in zsh
if [[ ! *(#qN) ]] echo nothing to see here