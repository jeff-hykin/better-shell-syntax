#!/bin/bash

command_args=("/usr/bin/test-program" "arg1" "arg2")
posts=(1 3 4 10)

echo "Start"

for post in "${posts[@]}"; do
	"${command_args[@]}" "$post"
done

echo "End"
"${command_args[@]}" "$post"
 "${command_args[@]}" "$post"
${command_args[@]} "$post"

