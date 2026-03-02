#!/usr/bin/env bash

calc_duration() { # calculates the duration of a command
	local start=$1
	local end=$2
	local diff=$(( end - start ))
	echo "Duration of command: $(( diff/60 ))m : $(( diff%60 ))s"
	echo " "
}