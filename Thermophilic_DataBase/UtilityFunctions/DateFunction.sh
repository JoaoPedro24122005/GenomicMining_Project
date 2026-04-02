#!/usr/bin/env bash

# Getting the current directory 
SCRIPT_PATH="${BASH_SOURCE[0]}"
SCRIPT_DIR=$(dirname "$SCRIPT_PATH")
CUR_DIR=$(cd "$SCRIPT_DIR" && pwd)

source "$CUR_DIR/ErrorMessage.sh"

is_leap_year() {
	local YEAR="${1:-0}"
	(( $YEAR > 0 )) || { log_error "Year value invalid (Year: $YEAR)"; return 1; }
	(( $YEAR % 4 == 0 && ($YEAR % 100 != 0 || $YEAR % 400 == 0) )) && return 0 || return 1
}

number_to_date() { # Convert the number° to the correspondent day
	local NUMBER="${1:-0}"
	local YEAR="${2:-0}"
	
	local max_days=365
	is_leap_year $YEAR && max_days=366

	if (( NUMBER > 0 && NUMBER <= max_days )); then
		:
	else
		log_error "Number value invalid (Year: $YEAR, Max: $max_days)"
		return 1
	fi
		
	date=$(date -d "$YEAR-01-01 + $((NUMBER-1)) days" +%m-%d) # 1° day + (number - 1) = number
	echo "$date"
	
	return 0
}

create_dates() {

	local YEAR="${1:-0}"
	local NUMBER_OF_DATES="${2:-0}"
	
	(( $YEAR > 0 )) || { log_error "Year value invalid (Year: $YEAR)"; return 1; }
	(( $NUMBER_OF_DATES > 0 )) || { log_error "Number of dates value invalid (Number of dates: $NUMBER_OF_DATES)"; return 1; }
	
	start_array=() # global var
	end_array=() # global var
	
	local total_days=365
	is_leap_year $YEAR && total_days=366
	local start=0
	local end=0
	local n=$NUMBER_OF_DATES
	
	(( interval=$total_days/$n-1 )) # constant
	
	for i in $(seq $n); do
		if (( $i == $n )); then # in the last iteration (last date), add the rest of division
			(( rest=$total_days%$n ))
		else
			rest=0
		fi
		
		(( start=$end+1 ))
		(( end=$start+$interval+$rest ))
		
		start_date=$(number_to_date $start $YEAR) || return 1
		end_date=$(number_to_date $end $YEAR) || return 1
		
		start_array+=( "$start_date" ) 
		end_array+=( "$end_date" ) 
		# To execute the script directly: echo "${start_array[i-1]} - ${end_array[i-1]}"
	done
	
	return 0
}