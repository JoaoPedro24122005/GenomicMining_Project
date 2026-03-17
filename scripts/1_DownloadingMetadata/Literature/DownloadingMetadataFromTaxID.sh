#!/usr/bin/env bash


# --- CONFIGURATION ---
BASE_DIR=$(pwd)
WORK_DIR="$BASE_DIR/ResultFiles/$(basename "$0" .sh)" 
mkdir -p "$WORK_DIR" 
LOG_DIR="$WORK_DIR/LogFiles" 
mkdir -p "$LOG_DIR" 
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S") # Get the current date and time

# Validating Input
: "${1?Error: No input file was provided.}" # stop script if there isnt a input
INPUT_TSV="$(readlink -f $1)"

OUTPUT_TSV="$WORK_DIR/${2:-MetadataFromAcessions_$TIMESTAMP.tsv}" 
LOG_FILE="$LOG_DIR/${TIMESTAMP}.log"
FIELDS="$(cat ../data/SearchingForThermophiles/ListMetadataFields.txt)"
TEMP_TAXIDS="temp.json"
COUNT_ASSEMBLIES_JSON=0
COUNT_ASSEMBLIES_TSV=0

# Putting the HEADER in the OUTPUT file (using taxid from Geobacillus)
datasets summary genome taxon "2263" --as-json-lines > "$TEMP_TAXIDS"
if [[ -s "$TEMP_TAXIDS" ]]; then
	# Include the HEADER and Truncate (>) the output file
	cat "$TEMP_TAXIDS" | dataformat tsv genome --fields "$FIELDS" | head -n1 > "$OUTPUT_TSV"
else
	echo "ERROR: Assembly with the HEADER couldn't be recovered"
	exit 1
fi

# Loop over the lines of the input
while IFS=$'\t' read -r TAXON NAME TAXID TRASH; do # IFS (Internal Field Separator). -r: consider \ as escape char
	
	echo "Proccessing - $TAXON: $NAME ..."
	
	# Downloading the JSON file
	datasets summary genome taxon $TAXID --as-json-lines 2>> "$LOGFILE" > "$TEMP_TAXIDS"
	
	# Checking if JSON file has content (with -s flag)
	if [[ -s "$TEMP_TAXIDS" ]]; then 
		# Converting JSON file to TSV file and concatenating in OUTPUT file
		cat "$TEMP_TAXIDS" | dataformat tsv genome --elide-header --fields "$FIELDS" 2>> "$LOGFILE" >> "$OUTPUT_TSV" # elide-header (remove the HEADER)
		
		# Writing imporant info to stdout
		COUNT_ASSEMBLIES_JSON=$(( COUNT_ASSEMBLIES_JSON + $(wc -l < "$TEMP_TAXIDS") ))
		COUNT_ASSEMBLIES_TSV=$(( $(wc -l < $OUTPUT_TSV) - 1 ))
		echo "$TAXON: $NAME added lines: $(wc -l < "$TEMP_TAXIDS")"
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
	
done < <(tail -n +2 "$INPUT_TSV") # Process Substitution for the INPUT file (read command reads from here)

# --- CLEANUP ---
echo -e "${CYAN}[4/4]${NC} Cleaning up temporary files..."
rm "$TEMP_TAXIDS"

echo -e "${GREEN}Process complete!${NC}"
echo -e "Final Metadata: ${YELLOW}$OUTPUT_TSV_TSV${NC}"
echo -e "Log file: ${YELLOW}$LOG_FILE${NC}"