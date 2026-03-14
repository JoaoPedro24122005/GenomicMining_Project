#!/usr/bin/bash

# Created by Joao Pedro (14/03/2026)
# SCRIPT: Concatenate two TSV files, removing headers from the second file,
# and perform sorting and deduplication.

# --- CONFIGURATION ---
BASE_DIR=$(pwd)
SCRIPT_NAME=$(basename "$0" .sh)
WORK_DIR="$BASE_DIR/ResultFiles/$SCRIPT_NAME" 
mkdir -p "$WORK_DIR" 
LOG_DIR="$WORK_DIR/LogFiles" 
mkdir -p "$LOG_DIR"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

# --- INPUT VALIDATION ---
# Ensure two input files are provided
: "${1?Error: First input file missing. Usage: $0 <file1> <file2> [output_name]}"
: "${2?Error: Second input file missing. Usage: $0 <file1> <file2> [output_name]}"

FILE1="$(readlink -f "$1")"
FILE2="$(readlink -f "$2")"

# Define output filename (uses 3rd argument if provided, otherwise uses timestamp)
OUTPUT_FILENAME="${3:-Merged_Data_$TIMESTAMP.tsv}"
OUT_FILE="$WORK_DIR/$OUTPUT_FILENAME"

echo "[$(date)] Starting file concatenation and deduplication..."

# --- STAGE 1: COUNT INITIAL LINES ---
# Counting lines (excluding headers via tail) to give accurate "data only" counts
COUNT1=$(tail -n +2 "$FILE1" | wc -l)
COUNT2=$(tail -n +2 "$FILE2" | wc -l)
TOTAL_INITIAL=$((COUNT1 + COUNT2))

echo "[$(date)] File 1 contains $COUNT1 data rows."
echo "[$(date)] File 2 contains $COUNT2 data rows."
echo "[$(date)] Total initial data rows: $TOTAL_INITIAL"

# --- STAGE 2: CONCATENATE, SORT, AND DEDUPLICATE ---
# 1. Take the first file as is (including header)
# 2. Append the second file starting from line 2 (skipping header)
# 3. Sort and remove duplicates (ignoring the header during sort if necessary, 
#    but since headers are identical, sort -u handles it perfectly)

{
    head -n 1 "$FILE1" # Keep header from first file
    (tail -n +2 "$FILE1"; tail -n +2 "$FILE2") | sort -u
} > "$OUT_FILE"

# --- STAGE 3: COUNT FINAL LINES ---
# Subtract 1 from the count to account for the header
TOTAL_FINAL=$(($(wc -l < "$OUT_FILE") - 1))

echo "[$(date)] Stage 2 complete: Sorting and deduplication finished."
echo "[$(date)] Total final data rows: $TOTAL_FINAL"
echo "[$(date)] Rows removed (duplicates): $((TOTAL_INITIAL - TOTAL_FINAL))"

echo "[$(date)] Final result saved to: $OUT_FILE"