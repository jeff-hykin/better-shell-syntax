aaa(){
    local bbb="Hello"
    printf "%s\n" "Hello World"
    echo "Hello World"

    case "${1}" in
        1)
            local bbb="World"
            echo "$bbb"
            ;;
        2)  local bbb="World";   echo "$bbb" ;;
        3)  printf "%s\n" "$bbb"             ;;
        *)  echo "$bbb"                      ;;
    esac
}