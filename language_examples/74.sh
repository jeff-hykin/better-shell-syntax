#!/bin/bash
declare -A a=();
a["[]"]=x;
b=${a["[]"]}; # this is incorrectly highlighted as part of a string
echo ${b}; # this too, it only ends after this double quote: " (this is highlighted as script)