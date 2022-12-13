out="$(netstat -tn | while read -r x; do
echo sample
done)"

# the rest of the file is treated as if it's in a string
x="it runs just fine"
echo $x

#!/usr/bin/env bash
some="something with spaces"

foo="$(echo "$some" | tr ' ' 'X')"
echo "foo=$foo"

pip="$(echo "$some" | while IFS= read -r pip_thing; do echo -n "pip_thing=${pip_thing}"; done | tr ' ' 'X')"
echo "pip=$pip"

one="$(echo "$some" | while IFS= read -r one_thing; do echo -n "one_thing=${one_thing}"; done)"
echo "one=$one"

pip="$(echo "$some" | while IFS= read -r pip_thing; do echo -n "pip_thing=${pip_thing}"; done | tr ' ' 'X')"
echo "pip=$pip"

two="$(echo "$some" | while IFS= read -r two_thing; do echo -n "two_thing=${two_thing}"; done)"
echo "two=$two"