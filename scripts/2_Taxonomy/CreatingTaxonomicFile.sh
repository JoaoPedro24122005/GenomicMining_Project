#!/usr/bin/bash

# Created by Joao Pedro (14/03/2026)
# SCRIPT: Processes a list of TaxIDs to generate structured taxonomic tables.
# It creates two separate files: one with Taxon Names and another with corresponding TaxIDs.

# --- CONFIGURATION ---
BASE_DIR=$(pwd)
# Set work directory based on script name (excluding .sh extension)
SCRIPT_NAME=$(basename "$0" .sh)
WORK_DIR="$BASE_DIR/ResultFiles/$SCRIPT_NAME" 
mkdir -p "$WORK_DIR" 
LOG_DIR="$WORK_DIR/LogFiles" 
mkdir -p "$LOG_DIR"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

# --- INPUT VALIDATION ---
# Stop script if no input file is provided
: "${1?Error: No input file was provided.}" 
INPUT_TSV="$(readlink -f "$1")"

# --- OUTPUT FILE DEFINITIONS ---
FILE_PREFIX="${2:-TaxonomyResults_$TIMESTAMP}"

OUT_NAMES="$WORK_DIR/${FILE_PREFIX}_TaxonNames.tsv"
OUT_IDS="$WORK_DIR/${FILE_PREFIX}_TaxID.tsv"
TEMP_MASTER="$WORK_DIR/temp_master_$TIMESTAMP.tsv"

echo "[$(date)] Stage 1: Generating Master Taxonomy file using TaxonKit..."

# 1 - Create a temporary master file with all taxonomic information
# The input is pre-processed to remove header and select columns 1, 2, and 3.
# Col 1: Accession, Col 2: Organism Name, Col 3: TaxID (Input for reformat2)
# Col 4: Generated Lineage Names, Col 5: Generated Lineage TaxIDs (due to -t flag)
taxonkit reformat2 \
    -I 3 \
    -f "{domain|superkingdom};{phylum};{class};{order};{family};{genus};{species};{subspecies|strain|no rank}" \
    -r "Unclassified" \
    -t \
    --no-ranks "clade" \
    <(tail -n +2 "$INPUT_TSV" | cut -f1,2,3) > "$TEMP_MASTER"

echo "[$(date)] Stage 2: Splitting Master file into specific output tables..."

# 2 - Create TAXON NAMES file
# Extracts columns 1-3 (original data) and column 4 (lineage names).
# Replaces semicolons with tabs to expand the lineage into individual columns.
cut -f 1,2,3,4 "$TEMP_MASTER" | \
tr ';' '\t' | \
csvtk add-header -t -n "Accession,Organism_Name,TaxID_Original,Domain,Phylum,Class,Order,Family,Genus,Species,Subspecies" \
> "$OUT_NAMES"

# 3 - Create TAXIDs file
# Extracts columns 1-3 (original data) and column 5 (lineage TaxIDs).
# Replaces semicolons with tabs to expand the lineage into individual columns.
cut -f 1,2,3,5 "$TEMP_MASTER" | \
tr ';' '\t' | \
csvtk add-header -t -n "Accession,Organism_Name,TaxID_Original,TaxID_Domain,TaxID_Phylum,TaxID_Class,TaxID_Order,TaxID_Family,TaxID_Genus,TaxID_Species,TaxID_Subspecies" \
> "$OUT_IDS"

# --- CLEANUP ---
# Remove the temporary master file to save space
if [ -f "$TEMP_MASTER" ]; then
    rm "$TEMP_MASTER"
fi

echo "[$(date)] Process complete!"
echo "Taxon Names table: $OUT_NAMES"
echo "TaxIDs table     : $OUT_IDS"