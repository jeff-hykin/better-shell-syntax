alias gswr='git switch -r'
alias gsws='git switch -s'

function sim
    if test $argv[1] = '--help'
        npm run p -- --help
    else
        make ls; and npm run p -- $argv
    end
end
declare -fadsfa adsafd=1203
set -x PATH /Users/ulugbekna/.dotnet $PATH