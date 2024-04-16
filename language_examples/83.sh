#!/usr/bin/env bash

function eval_wrapper {
	while test "$1" = '--'; do
		shift
	done
}