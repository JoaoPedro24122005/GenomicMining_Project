#!/usr/bin/env bash

# Created by Joao Pedro
# 25/02/2026

source "./UtilityFunctions/ErrorMessage.sh"
source "./UtilityFunctions/DateFunction.sh"
source "./UtilityFunctions/RequestMetadataNCBI.sh"

TIMESTAMP="$(date +"%Y-%m-%d_%H-%M-%S")" # Get the current date and time

# Preparing the directorys and files where the data will be save
WORK_DIR="ResultFiles/$(basename $0 .sh)" # Defining the working directory
mkdir -p "$WORK_DIR" # Create it if it doesn't exist
cd "$WORK_DIR" || { log_error "Can't move to Working Directoty: $WORK_DIR"; exit 1; } # Move the script's execution to the WORK_DIR
LOG_DIR="LogFiles" # Defining log directory
mkdir -p "$LOG_DIR" # Create it if it doesn't exist

# Creating the save and log files
LOG_FILE="LogFiles/ERROR_$TIMESTAMP.log" # Defining log file name
BAC_FILE="AllBacAssemblies.tsv" # Files used to Bacteria the data
ARC_FILE="AllArcAssemblies.tsv" # Files used to Archaea the data
> "$LOG_FILE"; echo "Creating save file $LOG_FILE in $(cd "$(dirname $LOG_FILE)" && pwd)"  
> "$BAC_FILE"; echo "Creating save file $BAC_FILE in $(cd "$(dirname $BAC_FILE)" && pwd)" 
> "$ARC_FILE"; echo "Creating save file $ARC_FILE in $(cd "$(dirname $ARC_FILE)" && pwd)" 

# Setting up variables for request
FIELDS="accession,assminfo-biosample-isolation-source"
ARC_TAXID=2157
BAC_TAXID=2
TOTAL_ASSEMBLY_BAC="2.938.712" # REFERENCE: Total number of Bacteria Assemblys in NCBI site (manually checked at 26/02/2025 - 09:51)
TOTAL_ASSEMBLY_ARC="34.827" #  # REFERENCE: Total number of Archaea Assemblys in NCBI site (manually checked at 26/02/2025 - 09:51)
# Only for Bacteria Domains request
START_YEAR=2010 # All data from the start of NCBI (1980) to $START_YEAR
END_YEAR=2026 # All data from the $END_YEAR to the current time
DATE_SPLITS=5 # Divide each year in $DATE_SPLITS dates

# Inserting the HEADER in the Save Files
insert_ncbi_header "$BAC_FILE" "$FIELDS"
insert_ncbi_header "$ARC_FILE" "$FIELDS"

# Download the metadata from all Bacteria and Archaea members
for organism in "ARC" "BAC"; do
	if [[ "$organism" == "ARC" ]]; then
		# ARCHAEA - Request directly with no split in date
		request_taxon_ncbi "$ARC_TAXID" "$ARC_FILE" "$LOG_FILE" "$FIELDS"
	elif [[ "$organism" == "BAC" ]]; then
		# BACTERIA - Request with date split
		for year in $(seq $START_YEAR $END_YEAR); do
			if [[ $year = $START_YEAR ]]; then
				AFTER=""
				BEFORE="${year}-12-31"
				request_taxon_ncbi "$BAC_TAXID" "$BAC_FILE" "$LOG_FILE" "$FIELDS" "$AFTER" "$BEFORE"
			elif [[ $year = $END_YEAR ]]; then
				AFTER="${year}-01-01"
				BEFORE=""
				request_taxon_ncbi "$BAC_TAXID" "$BAC_FILE" "$LOG_FILE" "$FIELDS" "$AFTER" "$BEFORE"
			else
				create_dates $year $DATE_SPLITS # Creating array with dates start dates and end dates: start_array, end_array
				CONT_SPLITS=0
				for date in $(seq $DATE_SPLITS); do # DATE_SPLITS = number of dates 
					(( CONT_SPLITS++ ))
					echo "Starting split request ($CONT_SPLITS / $DATE_SPLITS)"
					: "${start_array[date-1]?Value in array start_array[$((date-1))] invalid}"
					: "${end_array[date-1]?Value in array end_array[$((date-1))] invalid}"
					AFTER="${year}-${start_array[date-1]}"
					BEFORE="${year}-${end_array[date-1]}"
					request_taxon_ncbi "$BAC_TAXID" "$BAC_FILE" "$LOG_FILE" "$FIELDS" "$AFTER" "$BEFORE"
				done
			fi
		done
	fi
done