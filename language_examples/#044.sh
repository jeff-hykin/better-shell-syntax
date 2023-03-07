#!/usr/bin/env zsh

function foo {
  echo "foo: $1"
}

foo bar  # trailing comments
foo baz		# tab trailing comments