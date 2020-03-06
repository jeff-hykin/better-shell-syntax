#!/bin/bash

# Author: Christoph Marz
# Created 2020-02-14 20:55:51, last modified 2020-02-14 21:17:05

exit 0

foo=$(grep foo bar) && do-something-awesome-with "$foo"
foo=$1; shift
foo=bar ;
foo+=bar
foo='bar 'baz ;
foo+='bar 'baz;
foo="$foo bar"\ baz
foo+="$foo bar"\ baz
foo=${foo#/a}
bar[i + 1]=abc;
bar[i + 1]+=abc ;
bar[i + 1]+=${foo#/a}
bar=(x y z $(echo x) $((i++)) ${foo^^} ${foo#/a});
bar+=(x y z $(echo x) $((i++))) ;

export foo='bar 'baz"${foo#/a}"
declare foo='bar 'baz"${foo#/a}"
local foo='bar 'baz"${foo#/a}"

if [[ $1 =~ ^--arg-re=(.*)$ ]]; then echo foo; fi
 [[ $1 =~ ^--arg-re=(.*)$ ]]
[[ $1 =~ ^--arg-re=(.*)$ ]]

[[$1 == --some-opt]]
[$1 == --some-opt]

alias xy=z

[[ -z $foo || -f /foo/bar ]] && echo yo
((i > 0)) && [[ -z $foo || -f /foo/bar ]] && echo yo

if ((count)); then
	echo $((count++));

	foo=bar;
	foo=bar ;
	foo=bar
	foo+=bar
	foo='bar 'baz
	foo+='bar 'baz
	foo="$foo bar"\ baz
	foo+="$foo bar"\ baz
	bar[i + 1]=abc
	bar[i + 1]+=abc
	bar=(x y z $(echo x) $((i++)))
	bar+=(x y z $(echo x) $((i++)))
elif [ "$a" == b || "$a" != c && $a -lt 10 ]; then
	ls --all -a *
	(ls $(echo x) $((i++)))
	{ echo x; echo y; }
	cat foo | grep bar
	if [[ -n $foo && $foo =~ ^-*o(pti|on:)?[[:alnum:]]+$bar$ || $foo == bar && $foo != baz ]] && echo foooo || echo bar; then
		sed -E 's/.*x(.+)$bar.*/\1/g' foo > bar
		sed -E "s/.*x(.+)$bar.*/$foo/" <<< $foo >> bar
		read ans < /dev/stdin
		git remote show global 2>&1
		gedit foo & echo hello
		echo "$foo"
		echo '$foo'
	fi
fi

for file in $files; do
	ln -f "$repoDir/$file" "$destDir/$file"
done

for ((i = 1; i <= 10; i++)); do
	echo $((i & 1))
done

cd /

while true; do ls; done

while true
do
	ls
done

if grep -q foo bar; then echo yo; fi

if grep -q foo bar
then
	echo yo
fi

function foo
{
	echo $* $@ $# $? $- $$ $! $_ "${#bar[@]}" ${bar[@]} ${#bar[@]} ${a[*]} "${bar[i + 1]}"
	echo ${x#/a} ${x%a/*} ${x:0:1} ${#x} ${x^a} ${x^^} ${x,} ${x,,} ${!p@}
	echo $(echo $foo)
	diff <(echo $foo) <(echo "$bar")
	echo $0 $1 $# $- ${-} ${0} ${1} ${#} ${@} ${*} ${10} ${foo}
}

foo a b c "x y z"

grep -q foo bar && echo yes
foo & bar
foo | bar
foo || bar
foo && bar
