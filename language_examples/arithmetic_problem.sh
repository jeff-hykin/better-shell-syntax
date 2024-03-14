check="$((xcode-\select --install) 2>&1)"
echo $check
str="xcode-select: note: install requested for command line developer tools"
while [[ "$check" == "$str" ]];
do
    xcode-select --install
    echo "waiting for xcode command line tools to be installed"
    sleep 10
done