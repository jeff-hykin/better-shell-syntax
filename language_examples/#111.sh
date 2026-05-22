# issue #111: unquoted argument before `>` lost its last character

# placeholders with `<...>` -- last char must stay in string.unquoted.argument
mkdir <name>
git clone <url>
cd <repo name>
git cherry-pick -x <squash-merge-sha>
git checkout <target-branch>

# digit-suffix placeholders -- whole word stays in the argument, `>` is its own token
echo <sha256>
echo <h264>
echo <8080>

# `word>file` -- the word must not be split before `>`
echo ab>c
echo word>file

# unchanged-behavior controls: fd redirects still fall through to the redirect rule
echo hello 2>&1
echo foo 1>out 2>err
exec 3>&-
exec 255>file
echo foo 10>out

# numeric argument with no redirect: unchanged
echo 42

# heredoc: unchanged
cat <<EOF
hi
EOF
