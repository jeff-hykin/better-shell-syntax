function aaa(){
    local O="${O:-$___XX_DEFAULT}"
    local O="${O:-___XX_DEFAULT}"
    local O="${1:?"Please provide xxx"}"
    local O="${1:+"p=path"}"
    local O="${1##"cut"*}"
}
aaa