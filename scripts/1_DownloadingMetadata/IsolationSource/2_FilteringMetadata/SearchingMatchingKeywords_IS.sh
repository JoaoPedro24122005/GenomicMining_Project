#!/usr/bin/env bash

# Created by Joao Pedro
# 06/03/2026

# SCRIPT - Reading the TSV files containing the Assemblies gathered using the Isolation Source keywords and listing the keywords founded

BASE_DIR=$(pwd)
TIMESTAMP="$(date +"%Y-%m-%d_%H-%M-%S")" # Get the current date and time

# Preparing the directorys and files where the data will be save
WORK_DIR="$BASE_DIR/ResultFiles/$(basename $0 .sh)" # Defining the working directory
mkdir -p "$WORK_DIR" # Create it if it doesn't exist

# Creating the variables to access the files (readlink -f -> get the full path)
: "${1?Error: No input file was provided.}" # stop script if there isnt a input
INPUT_TSV="$(readlink -f $1)"
SAVE_FILE="$WORK_DIR/${2:-ListOfISKeywords_$TIMESTAMP.txt}" 
PATTERNS_FILE="$(readlink -f "../data/SearchingForThermophiles/IsolationSourceSearch/ThermophilesIsolationSource.txt ")"

# Truncating files
> "$SAVE_FILE"

# Searching for words containing the pattern
cont=0
echo "Words that containing the pattern" >> "$SAVE_FILE"
while IFS= read -r line || [[ -n "$line" ]]; do # IFS=*nothing - makes the read command treat the the text as raw (dont split when there`s spaces, tabs, etc )
	(( cont++ ))
	echo "${cont}) ${line}:" >> "$SAVE_FILE"
	grep -oiE "\w*${line}\w*" "$INPUT_FILE" | sort | uniq -c >> "$SAVE_FILE"
	echo >> "$SAVE_FILE"
done < "$PATTERNS_FILE"

# Searching for the "Neighbor" words
cont=0
echo "Words neighboring the pattern" >> "$SAVE_FILE"
while IFS= read -r line || [[ -n "$line" ]]; do
	(( cont++ ))
	echo "${cont}) ${line}:" >> "$SAVE_FILE"
	grep -oiE "(\w+\s)?\w*${line}\w*(\s\w+)?" "$INPUT_FILE" | sort | uniq -c >> "$SAVE_FILE"
	echo >> "$SAVE_FILE"
done < "$PATTERNS_FILE"

echo "SEARCH COMPLETE!"
echo "10 first lines of the Output file: $(basename $SAVE_FILE)"
head "$SAVE_FILE"
echo "File $(basename $SAVE_FILE) saved in $(dirname $SAVE_FILE)"

# Cant use the alias (notepad)
# read -p "Open the $(basename $SAVE_FILE) in notepad [y/n]: " confirm
# if [[ "$confirm" == "Y" || "$confirm" == "y" ]]; then
	# notepad "$SAVE_FILE" 
# else
	# echo "End of Script"
# fi
