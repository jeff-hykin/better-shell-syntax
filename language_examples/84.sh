#!/usr/bin/env dash

case "${1}" in
    (opt1)
        opt1=true

        if [ -n "${2}" ]
        then
            opt1arg="${2}"
            shift
        fi
    ;;
    (opt2)
        opt2=true

        case "${2}" in
            (s)
                echo "S"
            ;;
            (d)
                echo "D"
            ;;
            (*)
                echo "Missing"
            ;;
        esac

        if [ -n "${HOME}" ]
        then
            echo "${HOME}"
        fi
    ;;
    (opt3)
        opt3=true

        if [ -n "${2}" ]
        then
            opt3arg="${2}"
            shift
        fi

        echo "This is opt3"
    ;;
esac