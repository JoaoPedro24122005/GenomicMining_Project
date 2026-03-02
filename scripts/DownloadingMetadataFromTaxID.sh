#!/usr/bin/env bash

# Check if the input file is valid
if [[ -f "$1" ]]; then
	:
else
	echo "ERROR: File $1 is not a valid file"
	exit 1
fi

# Setting up variables
if [[ "$2" == "Arc" ]]; then  # Deciding if the input file has Bacteria or Archaea info
    DOMAIN="Arc"
else
    DOMAIN="Bac"
fi
OUTPUT="Metadata_$DOMAIN.tsv"
FIELDS="$(cat ../data/SearchingForThermophiles/ListMetadataFields.txt)"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S") # Get the current date and time
LOGFILE="$(basename $0)_$TIMESTAMP.log"
COUNT_ASSEMBLIES_JSON=0
COUNT_ASSEMBLIES_TSV=0

# Putting the HEADER in the OUTPUT file (using taxid from Geobacillus)
datasets summary genome taxon "2263" --as-json-lines > temp.json
if [[ -s temp.json ]]; then
	# Include the HEADER and Truncate (>) the output file
	cat temp.json | dataformat tsv genome --fields "$FIELDS" | head -n1 > "$OUTPUT"
else
	echo "ERROR: Assembly with the HEADER couldn't be recovered"
	exit 1
fi

# Loop over the lines of the input
while IFS=$'\t' read -r TAXON NAME TAXID TRASH; do # IFS (Internal Field Separator). -r: consider \ as espace char
	
	echo "Proccessing - $TAXON: $NAME ..."
	
	# Downloading the JSON file
	datasets summary genome taxon $TAXID --as-json-lines 2>> "$LOGFILE" > temp.json
	
	# Checking if JSON file has content (with -s flag)
	if [[ -s temp.json ]]; then 
		# Converting JSON file to TSV file and concatenating in OUTPUT file
		cat temp.json | dataformat tsv genome --elide-header --fields "$FIELDS" 2>> "$LOGFILE" >> "$OUTPUT" # elide-header (remove the HEADER)
		
		# Writing imporant info to stdout
		COUNT_ASSEMBLIES_JSON=$(( COUNT_ASSEMBLIES_JSON + $(wc -l < temp.json) ))
		COUNT_ASSEMBLIES_TSV=$(( $(wc -l < $OUTPUT) - 1 ))
		echo "$TAXON: $NAME added lines: $(wc -l < temp.json)"
		echo "Total lines: $COUNT_ASSEMBLIES_JSON Assemblies in JSON"
		echo "Total lines: $COUNT_ASSEMBLIES_TSV Assemblies in TSV"
		
		# Check if there was multiple rows in the JSON or TSV file
		if [[ $COUNT_ASSEMBLIES_JSON != $COUNT_ASSEMBLIES_TSV ]]; then
			echo "ERROR: Discrepancy founded:"
			echo "JSON Lines - $COUNT_ASSEMBLIES_JSON"
			echo "TSV Lines - $COUNT_ASSEMBLIES_TSV"
			echo "When processing Taxon: $NAME"
			exit 1
		fi
	else
		echo "ERROR: Assemblys from TaxID: $TAXID were not recovered" >> "$LOGFILE"
	fi
	
done < <(tail -n +2 "$1") # Process Substituin for the INPUT file (read command reads from here)

# Moving LOGFILE to a specific directory
DIR="./LogFiles/"
if [[ -d "$DIR" ]]; then
	mv "$LOGFILE" "$DIR"
else
	mkdir "$DIR"
	mv "$LOGFILE" "$DIR"
fi

echo "End of Script: $(basename "$0")"
read -n 1 -p "See log file [y/n]: " resp 
echo
if [[ $resp =~ ^[Yy]$ ]]; then
	less "$DIR/$LOGFILE"
else
	echo "End of script at $TIMESTAMP"
fi