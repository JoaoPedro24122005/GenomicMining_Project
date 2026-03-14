#!/usr/bin/env bash

# File to store results
OUTPUT="manual_recovery_round5.tsv"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' 

# New Robust Function: Retries up to 5 times if 0 lines are added
run_query_robust() {
    local label=$1
    local cmd=$2
    local attempt=1
    local success=false

    while [ $attempt -le 5 ] && [ "$success" = false ]; do
        echo -e "${YELLOW}[ROUND 5 - Attempt $attempt]:${NC} $label"
        local before=0
        if [ -f "$OUTPUT" ]; then before=$(wc -l < "$OUTPUT"); fi
        
        eval "$cmd"
        
        local after=$(wc -l < "$OUTPUT")
        local diff=$((after - before))
        
        if [ $diff -gt 0 ]; then
            echo -e "${GREEN}[SUCCESS]:${NC} Added $diff lines."
            success=true
        else
            echo -e "${RED}[FAILED]:${NC} No data retrieved. Retrying in 10s..."
            ((attempt++))
            sleep 10
        fi
    done
    echo "----------------------------------------------------"
}

echo -e "${GREEN}Starting Manual Recovery Round 5 (Brute Force Mode)...${NC}"

# --- TARGET 1: The 2019-07-24 DNS Failure ---
run_query_robust "2019-07-24" 'datasets summary genome taxon "2" --released-after "2019-07-24" --released-before "2019-07-24" --as-json-lines | dataformat tsv genome --elide-header --fields "accession,assminfo-biosample-isolation-source" >> "$OUTPUT"'

# --- TARGET 2: 2026 Jan 01-07 (Day-by-Day) ---
# Since 2026-01-01 gave 1000 and crashed, let's treat every day as a separate mission
for DAY in {01..07}; do
    run_query_robust "2026-01-$DAY" "datasets summary genome taxon \"2\" --released-after \"2026-01-$DAY\" --released-before \"2026-01-$DAY\" --as-json-lines | dataformat tsv genome --elide-header --fields \"accession,assminfo-biosample-isolation-source\" >> \"$OUTPUT\""
done

echo -e "${GREEN}Manual Recovery Round 5 Finished.${NC}"