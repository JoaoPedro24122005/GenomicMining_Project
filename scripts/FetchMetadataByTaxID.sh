#!/usr/bin/env bash

# SCRIPT: Downloading genome metadata using the TaxID as the key search

# 1. Source the functions from your provided file
source "./UtilityFunctions/AI_RequestMetadataNCBI.sh"

# --- COLORS ---
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

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

# Reading metadata fields from the provided file path
FIELDS_FILE="$(readlink -f ../data/SearchingForThermophiles/ListMetadataFields.txt)"
if [[ -f "$FIELDS_FILE" ]]; then
    METADATA_FIELDS=$(cat "$FIELDS_FILE" | tr '\n' ',' | sed 's/,$//')
else
    echo -e "${RED}Error: Metadata fields file not found at $FIELDS_FILE${NC}"
    exit 1
fi

# --- PREPARATION ---
TEMP_TAXIDS="$WORK_DIR/temp_taxids.txt"

echo -e "${CYAN}[1/4]${NC} Extracting taxids from: ${YELLOW}$INPUT_TSV${NC}"
awk -F'\t' 'NR>1 {print $3}' "$INPUT_TSV" > "$TEMP_TAXIDS" # Deleting the HEADER and selecting the TaxID colunm (third one)

if [[ ! -s "$TEMP_TAXIDS" ]]; then # Check if TEMP_TAXIDS actually has content
    echo -e "${RED}Error: Temp TaxID file is empty. Check if column 3 is correct.${NC}"
    exit 1
fi

# Cleaning the output file
> "$OUTPUT_TSV"

# --- EXECUTION ---

echo -e "${CYAN}[2/4]${NC} Initializing output file with headers..."
# Note: Ensure all data in reference list is correct to allow linking
insert_ncbi_header "$OUTPUT_TSV" "$METADATA_FIELDS"

# Do the request passing the taxid or taxon name
echo -e "${CYAN}[3/4]${NC} Starting NCBI metadata request via ${GREEN}request_file_taxon_ncbi${NC}..."
request_file_taxon_ncbi "$TEMP_TAXIDS" "$OUTPUT_TSV" "$LOG_FILE" "$METADATA_FIELDS"

# --- CLEANUP ---
echo -e "${CYAN}[4/4]${NC} Cleaning up temporary files..."
rm "$TEMP_TAXIDS"

echo -e "${GREEN}Process complete!${NC}"
echo -e "Final Metadata: ${YELLOW}$OUTPUT_TSV${NC}"
echo -e "Log file: ${YELLOW}$LOG_FILE${NC}"