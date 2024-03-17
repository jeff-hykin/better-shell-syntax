if [[ ( $2 == "-i" ) || ( $2 == "-install" ) || ( $2 == "-add" ) ]]; then VCMD="y"
  if [[ $(( $# - 2 )) != 1 ]]; then PRINT FATAL "Expected 1 argument but got $(( $# - 2 )).";exit 2;fi
  # [..]
fi