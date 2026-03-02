#!/usr/bin/env bash

is_leap_year() {
	YEAR="$1"
	
	if (( $YEAR <= 0 )); then
		echo "ERROR in is_leap_year()" >&2
		echo "Invalid year to check if is a leap year (Year: $YEAR)" >&2
		exit 1
	fi
	
	if (( $YEAR % 4 == 0 && ($YEAR % 100 != 0 || $YEAR % 400 == 0) )); then
		return 0 # True
	else
		return 1 # False
	fi
}

number_to_date() { # Convert the number° to the correspondent day
	NUMBER="$1"
	YEAR="$2"
	
	if ! is_leap_year "$YEAR" && (( $NUMBER >= 366 )); then # day=1-365
		echo "ERROR in number_to_date()" >&2
		echo "Invalid number to convert to date (Number: $NUMBER / Year: $YEAR)" >&2
		exit 1
	elif is_leap_year "$YEAR" && (( $NUMBER >= 367 )); then #day=1-366
		echo "ERROR: Invalid number to convert to date (Number: $NUMBER / Year: $YEAR)" >&2
		exit 1
	else
		:
	fi
	
	(( NUMBER=$NUMBER-1 ))
	
	date=$(date -d "$YEAR-01-01 + $NUMBER days" +%m-%d) # 1° day + (number - 1) = number
	echo "$date"
}

create_dates() {

	YEAR="$1"
	BREAKS="$2"
	start_array=()
	end_array=()
	
	if is_leap_year "$YEAR"; then
		local total_days=366
	else
		local total_days=365
	fi
	local start=0
	local end=0
	local n=$BREAKS
	
	(( interval=$total_days/$n-1 )) # constant
	
	for i in $(seq $n); do
		if (( $i == $n )); then # in the last iteration (last date), add the rest of division
			(( rest=$total_days%$n ))
		else
			rest=0
		fi
		(( start=$end+1 ))
		(( end=$start+$interval+$rest ))
		
		start_date=$(number_to_date $start $YEAR)
		end_date=$(number_to_date $end $YEAR)
		
		start_array+=( "$start_date" ) # global var
		end_array+=( "$end_date" ) # global var 
		
		# To execute the script directly: echo "${start_array[i-1]} - ${end_array[i-1]}"
	done
}


# # To execute the script directly
# YEAR_TO_BREAK=$1
# (( NUMBER_OF_BREAKS=$2+1 )) 

# if [[ -z $YEAR_TO_BREAK ]] || [[ -z $NUMBER_OF_BREAKS ]]; then
	# echo "ERROR: Arguments not informed (1° - Year / 2° - Number of breaks)"
	# exit 1
# elif (( $NUMBER_OF_BREAKS <= 0 || $NUMBER_OF_BREAKS >= 366 )); then
	# echo "Number of breaks invalid: $(( $NUMBER_OF_BREAKS - 1 ))"
	# echo "Min: 0; Max: 364"
	# exit 0
# else
	# :
# fi
# create_dates $YEAR_TO_BREAK $NUMBER_OF_BREAKS