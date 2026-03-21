#!/usr/bin/env bash

# Created by AI (Gemini 3 Flash model) 
# Updated with Robust Retry Logic: 05/03/2026 

set -o pipefail 
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

# --- INTERNAL HELPER: THE ROBUST ENGINE ---
# This helper handles retries, provides terminal feedback, and checks for partial transfers .
execute_ncbi_call() {
    local label="$1"
    local cmd="$2"
    local save_file="$3"
    local log_file="$4"
    local attempt=1
    local max_attempts=5
    local success=false

    # Colors
    local GREEN='\033[0;32m'
    local RED='\033[0;31m'
    local YELLOW='\033[1;33m'
    local NC='\033[0m'

    local TEMP_WORK_FILE="${save_file}.tmp"

    while [ $attempt -le $max_attempts ] && [ "$success" = false ]; do
        echo -e "${YELLOW}[Attempt $attempt/$max_attempts]:${NC} $label"
        
        # 1. Start with an empty temp file for THIS attempt
        > "$TEMP_WORK_FILE"
        
        # 2. Update the command to write to the TEMP file, not the SAVE file
        # We replace the final output path in the command string dynamically
        local current_cmd=$(echo "$cmd" | sed "s|>> \"$save_file\"|> \"$TEMP_WORK_FILE\"|")
        
        eval "$current_cmd"
        local exit_code=$?
        
        local count=$(wc -l < "$TEMP_WORK_FILE")
        
        # 3. Validation: Must be a clean exit code AND have data
        if [[ $exit_code -eq 0 ]] && [[ $count -gt 0 ]]; then
            cat "$TEMP_WORK_FILE" >> "$save_file"
            echo -e "${GREEN}[SUCCESS]:${NC} Retrieved $count records."
            success=true
            rm "$TEMP_WORK_FILE"
        else
            echo -e "${RED}[FAILED]:${NC} Attempt $attempt failed or was truncated."
            ((attempt++))
            sleep 10
        fi
    done

    if [[ "$success" = false ]]; then
        cat <<-EOF >> "$log_file"
		-------------------------
		NCBI Request Failed after $max_attempts attempts!
		Query: $label
		Timestamp: $(date)
		-------------------------
		EOF
        return 1
    fi
    return 0
}

# --- PRIMARY FUNCTIONS ---

insert_ncbi_header() {
    local SAVE_FILE="$1"
    local FIELDS="$2"
    [[ -z $SAVE_FILE ]] && return 1
    
    # Standard call to grab the header row for the requested fields 
    datasets summary genome taxon "Geobacillus" --as-json-lines | \
    dataformat tsv genome --fields "$FIELDS" | head -n1 >> "$SAVE_FILE" 
}

request_taxon_ncbi() {
    local TAX="$1"
    local SAVE_FILE="${2:-NCBI_Metadata_${TIMESTAMP}.tsv}"
    local LOG_FILE="${3:-Log_Metadata_${TIMESTAMP}.log}"
    local FIELDS="$4"
    local RELEASE_AFTER="$5"
    local RELEASE_BEFORE="$6"

    [[ -z $TAX ]] && return 1

    local CMD="datasets summary genome taxon \"$TAX\" \
        --released-after \"$RELEASE_AFTER\" \
        --released-before \"$RELEASE_BEFORE\" \
        --as-json-lines | \
        dataformat tsv genome --elide-header --fields \"$FIELDS\" >> \"$SAVE_FILE\""

    execute_ncbi_call "Taxon: $TAX ($RELEASE_AFTER to $RELEASE_BEFORE)" "$CMD" "$SAVE_FILE" "$LOG_FILE"
}

request_file_taxon_ncbi() {
    local INPUT_FILE="$1"
    local SAVE_FILE="${2:-NCBI_Metadata_${TIMESTAMP}.tsv}"
    local LOG_FILE="${3:-Log_Metadata_${TIMESTAMP}.log}"
    local FIELDS="$4"
    local RELEASE_AFTER="$5"
    local RELEASE_BEFORE="$6"

    [[ ! -f "$INPUT_FILE" ]] && return 1

    local CMD="datasets summary genome taxon --inputfile \"$INPUT_FILE\" \
        --released-after \"$RELEASE_AFTER\" \
        --released-before \"$RELEASE_BEFORE\" \
        --as-json-lines | \
        dataformat tsv genome --elide-header --fields \"$FIELDS\" >> \"$SAVE_FILE\""

    execute_ncbi_call "File-Taxon: $INPUT_FILE ($RELEASE_AFTER to $RELEASE_BEFORE)" "$CMD" "$SAVE_FILE" "$LOG_FILE"
}

request_file_acession_ncbi() {
    local INPUT_FILE="$1"
    local SAVE_FILE="${2:-NCBI_Metadata_${TIMESTAMP}.tsv}"
    local LOG_FILE="${3:-Log_Metadata_${TIMESTAMP}.log}"
    local FIELDS="$4"
    # Note: Accession searches ignore release dates

    [[ ! -f "$INPUT_FILE" ]] && return 1

    # Accession-based search uses 'accession --inputfile' instead of 'taxon --inputfile' 
    local CMD="datasets summary genome accession --inputfile \"$INPUT_FILE\" \
        --as-json-lines | \
        dataformat tsv genome --elide-header --fields \"$FIELDS\" >> \"$SAVE_FILE\""

    execute_ncbi_call "File-Accession: $INPUT_FILE" "$CMD" "$SAVE_FILE" "$LOG_FILE"
}
