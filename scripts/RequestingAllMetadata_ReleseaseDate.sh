#!/usr/bin/env bash

# Created by Joao Pedro
# 25/02/2026

set -o pipefail # Forces the entire pipeline to fail if any of the commands inside it fail

import() {
	array=( "$@" )
	for file in array; do
	
	# Check if imported file exist
	if [[ ! -f "$file" ]]; then
		echo "Import Error at line ${LINENO}: $file not founded in current directory"
		exit 1
	else
		source $file # execute it
	fi
	done
}

IMPORT1="UtilityFunctions/DateFunction.sh" # import the var: start_array, end_array / import func: create_dates
IMPORT2="UtilityFunctions/RequestMetadataNCBI" # import the func: request_taxon_ncbi
IMPORT3="UtilityFunctions/CommandDuration.sh" # import the func: calc_duration

import $IMPORT1 $IMPORT2

calc_duration() { # calculates the duration of a command
	local start=$1
	local end=$2
	local diff=$(( end - start ))
	echo "Duration of command: $(( diff/60 ))m : $(( diff%60 ))s"
	echo " "
}

# 0 - Preparing the directorys where the data will be save

current_dir=$(pwd | grep "GenomicMining_Project/scripts$") # Check if the file is being executed in the RELATIVE PATH: ../GenomicMining_Project/scripts/
if [[ -z current_dir ]]; then
	echo "ERROR: The script need to be executed inside the 'scripts directory' (../GenomicMining_Project/scripts)"
	exit 1
else
	: # just continue
fi
WORK_DIR="TempFiles/$(basename $0)" # Defining the working directory
mkdir -p "$WORK_DIR" # Create it if it doesn't exist
cd "$WORK_DIR" || { echo "ERROR: Can't move to Working Directoty: $WORK_DIR"; exit 1} # Move the script's execution to the WORK_DIR

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S") # Get the current date and time
LOG_DIR="LogFiles" # Defining log directory
mkdir -p "$LOG_DIR" # Create it if it doesn't exist
LOG_FILE="LogFiles/ERROR_$TIMESTAMP.log" # Defining log file name

BAC_FILE="AllBacAssemblies.tsv" # Files used to store the data
ARC_FILE="AllArcAssemblies.tsv" # Files used to store the data
> $BAC_FILE
> $ARC_FILE

# 1 - Download the metadata from all Bacteria and Archaea members

TOTAL_ASSEMBLY_BAC="2.938.712" # Total number of Bacteria Assemblys in NCBI site (manually checked at 26/02/2025 - 09:51)
TOTAL_ASSEMBLY_ARC="34.827" #  # Total number of Archaea Assemblys in NCBI site (manually checked at 26/02/2025 - 09:51)

ARC_TAXID=2157
BAC_TAXID=2

for organism in "ARC" "BAC"; do
	if [[ "$organism" == "ARC" ]]; then
		# ARCHAEA - Direct requesting for all assemblies
		request_taxon_ncbi "$ARC_TAXID" "$ARC_FILE" "$LOG_FILE" "$FIELDS"
	elif [[ "$organism" == "BAC" ]] 
		# BACTERIA - Request with release date split
		start_year=2010
		end_year=2026
		DATE_SPLITS=50 # 50 different dates within a year
		for year in $(seq $start_year $end_year); do
			if [[ $year = $start_year ]]; then
				AFTER=""
				BEFORE="${year}-12-31"
				request_taxon_ncbi "$BAC_TAXID" "$BAC_FILE" "$LOG_FILE" "$FIELDS" "$AFTER" "$BEFORE"
			elif [[ $year = $end_year ]]; then
				AFTER="${year}-01-01"
				BEFORE=""
				request_taxon_ncbi "$BAC_TAXID" "$BAC_FILE" "$LOG_FILE" "$FIELDS" "$AFTER" "$BEFORE"
			else
				create_dates $year $DATE_SPLITS # Creating array with dates start dates and end dates
				# Generate 2 array with the dates from the $year: start_array, end_array
			
				for date in $(seq $DATE_SPLITS); do # DATE_SPLITS = number of dates 
					AFTER=${start_array[date-1]}
					BEFORE=${end_array[date-1]}
					if [[ -z $AFTER ]] || [[ -z BEFORE ]]; then
						echo "ERROR at line ${LINENO}: After or Before date invalid"
						echo "After: $AFTER; Before: $BEFORE"
						exit 1
					fi
					request_taxon_ncbi "$BAC_TAXID" "$BAC_FILE" "$LOG_FILE" "$FIELDS" "$AFTER" "$BEFORE"
				done
			fi
		
			
	else
		echo "ERROR at line ${LINENO}: Name of organism invalid (organism=$organism)"
	fi
done
