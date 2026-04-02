#!/usr/bin/env bash

# Getting the current directory
SCRIPT_PATH="${BASH_SOURCE[0]}"
SCRIPT_DIR=$(dirname "$SCRIPT_PATH")
CUR_DIR=$(cd "$SCRIPT_DIR" && pwd)

source "$CUR_DIR/ErrorMessage.sh"

calc_duration() { # calculates the duration of a command

	start="${1:-0}"
	end="${2:-0}"
	
	(( $start <= 0 )) || { log_error "start value invalid (start: $start)"; return 1; }
	(( $end <= 0 )) || { log_error "end value invalid (end: $end)"; return 1; }
	
	diff=$(( end - start ))
	echo "Duration of command: $(( diff/60 ))m : $(( diff%60 ))s"
	echo " "
	
	return 0
}