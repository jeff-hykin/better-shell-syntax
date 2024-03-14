#!/bin/sh

case a in
	b) echo "wrongcolors(): this breaks highlighting"
esac
echo "this is highlighted incorrectly"
# until the " character is encountered
echo "now highlighting is correct again"