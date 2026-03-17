#!/usr/bin/env bash

# Created by Joao Pedro
# 05/03/2026

# SCRIPT - Filtering the metadata from Thermophiles

source "./UtilityFunctions/ErrorMessage.sh"
source "./UtilityFunctions/ReadPath.sh"
TIMESTAMP="$(date +"%Y-%m-%d_%H-%M-%S")" # Get the current date and time
BASE_DIR=$(pwd)

# Preparing the directorys and files where the data will be save
WORK_DIR="$BASE_DIR/ResultFiles/$(basename $0 .sh)" # Defining the working directory
mkdir -p "$WORK_DIR" # Create it if it doesn't exist
LOG_DIR="$WORK_DIR/LogFiles" # Defining log directory
mkdir -p "$LOG_DIR" # Create it if it doesn't exist

# Creating the variables to access the files (readlink -f -> get the full path)
: "${1?Error: No input file was provided.}" # stop script if there isnt a input
INPUT_TSV="$(readlink -f $1)"
SAVE_FILE="$WORK_DIR/${2:-MetadataFromIS_$TIMESTAMP.tsv}" 
KEYWORD_THERM="$(readlink -f "../data/SearchingForThermophiles/IsolationSourceSearch/ThermophilesIsolationSource.txt")"
KEYWORD_NON_THERM="$(readlink -f "../data/SearchingForThermophiles/IsolationSourceSearch/Non-ThermophilesIsolationSource.txt")"
TEMP_FILE1="$WORK_DIR/temp_file1" # Temporary file to store the entries as they are process
TEMP_FILE2="$WORK_DIR/temp_file2" # Temporary file to store the entries as they are process
TEMP_FILE3="$WORK_DIR/temp_file3" # Temporary file to store the entries as they are process
LOG_FILE="$LOG_DIR/$TIMESTAMP.log"

# Setting up variables for request
THERMOPHILES_IS="$( sed -e '/^#/d' -e '/^$/d' $KEYWORD_THERM | cut -f2 -d$' ' )" # storing the text inside the var
NON_THERMOPHILES_IS="$( sed -e '/^#/d' -e '/^$/d' $KEYWORD_NON_THERM | cut -f2 -d$' ' )" # storing the text inside the var

echo -e "Thermophiles Keywords for Isolation Source: \n$THERMOPHILES_IS"
echo
echo -e "Non-Thermophiles Keywords for Isolation Source: \n$NON_THERMOPHILES_IS"
echo

# Truncating the files (overwrite old versions)
> "$SAVE_FILE"
> "$TEMP_FILE1"
> "$TEMP_FILE2"
> "$TEMP_FILE3"
> "$LOG_FILE"

echo -e "Number of assemblys: $(wc -l < $INPUT_FILE)\n"

# Pre-Filtering - Deleting entries with GCF_ in-line (there is always a correspondent GCA Assembly, so the GCF is not necessary)
echo "Deleting assemblies with accession GCF_..."
sed '/^GCF_/d' "$INPUT_FILE" >> "$TEMP_FILE1"
echo -e "Number of assemblys: $(wc -l < $TEMP_FILE1)\n"

# Filtering the assemblies without any IS
echo "Deleting assemblies with empty Isolation Source"
tail -n +2 "$TEMP_FILE1" | awk -F $'\t' '$2 != ""' >> "$TEMP_FILE2"
echo -e "Number of assemblys: $(wc -l < $TEMP_FILE2)\n"

# Selecting rows with Thermophiles IS keywords and Removing Non_Thermophiles 
echo "Selecting the thermophiles assemblys and removing the non-thermophilic ones..."
grep -F -i -f <(echo "$THERMOPHILES_IS") "$TEMP_FILE2" | \
grep -v -F -i -f <(echo "$NON_THERMOPHILES_IS") >> "$TEMP_FILE3" 
echo -e "Number of assemblys: $(wc -l < $TEMP_FILE3)\n"

# Sorting and removing any duplicates
echo "Sorting and deleting duplicates..."
sort "$TEMP_FILE3" | uniq >> "$SAVE_FILE" # Sort using the first column and remove duplicates
echo -e "Number of assemblys: $(wc -l < $SAVE_FILE)\n"

# Cleaning
rm "$TEMP_FILE1" "$TEMP_FILE2" "$TEMP_FILE3" # This the literal rm cmd (not an alias)

# Showing the head of the files
echo "10 first lines of the final Output file: $(basename $SAVE_FILE):"
head "$SAVE_FILE"
echo
echo "10 first lines of the Log file: $(basename $LOG_FILE):"
head "$LOG_FILE"
echo