[[ $T =~ "a string" ]] && echo "yes" || echo "no"
function testo() {  ### this loses highlighting due to the space in "a string" above
    ls -la
    pwd
}