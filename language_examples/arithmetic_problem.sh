check="$((xcode-\select --install) 2>&1)"
echo $check
str="xcode-select: note: install requested for command line developer tools"
while [[ "$check" == "$str" ]];
do
    xcode-select --install
    echo "waiting for xcode command line tools to be installed"
    sleep 10
done

if [[ ( $2 == "-i" ) || ( $2 == "-install" ) || ( $2 == "-add" ) ]]; then VCMD="y"
  if [[ $(( $# - 2 )) != 1 ]]; then PRINT FATAL "Expected 1 argument but got $(( $# - 2 )).";exit 2;fi
  # [..]
fi