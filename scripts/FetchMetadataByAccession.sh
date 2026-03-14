#!/usr/bin/env bash

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
TEMP_ACC_LIST="$WORK_DIR/temp_accessions.txt"

echo -e "${CYAN}[1/4]${NC} Extracting accessions from: ${YELLOW}$INPUT_TSV${NC}"
awk -F'\t' 'NR>1 {print $1}' "$INPUT_TSV" > "$TEMP_ACC_LIST"

# Cleaning the output file
> "$OUTPUT_TSV"

# --- EXECUTION ---

echo -e "${CYAN}[2/4]${NC} Initializing output file with headers..."
# Note: Ensure all data in reference list is correct to allow linking
insert_ncbi_header "$OUTPUT_TSV" "$METADATA_FIELDS"

echo -e "${CYAN}[3/4]${NC} Starting NCBI metadata request via ${GREEN}request_file_acession_ncbi${NC}..."
request_file_acession_ncbi "$TEMP_ACC_LIST" "$OUTPUT_TSV" "$LOG_FILE" "$METADATA_FIELDS"

# --- CLEANUP ---
echo -e "${CYAN}[4/4]${NC} Cleaning up temporary files..."
rm "$TEMP_ACC_LIST"

echo -e "${GREEN}Process complete!${NC}"
echo -e "Final Metadata: ${YELLOW}$OUTPUT_TSV${NC}"
echo -e "Log file: ${YELLOW}$LOG_FILE${NC}"