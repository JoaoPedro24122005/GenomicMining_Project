#!/usr/bin/env bash

# File to store results
OUTPUT="manual_recovery_round3.tsv"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' 

run_query() {
    local label=$1
    local cmd=$2
    echo -e "${YELLOW}[ROUND 3 RETRY]:${NC} $label"
    local before=0
    if [ -f "$OUTPUT" ]; then before=$(wc -l < "$OUTPUT"); fi
    
    eval "$cmd"
    
    local after=$(wc -l < "$OUTPUT")
    local diff=$((after - before))
    echo -e "${GREEN}[RESULT]:${NC} Added $diff lines."
    echo "----------------------------------------------------"
    sleep 5
}

echo -e "${GREEN}Starting Manual Recovery Round 3...${NC}"

# --- TARGET 1: 2024 GAP (3 Weeks) ---
# Breaking the 2024-11-25 to 2024-12-16 gap into smaller pieces
run_query "2024 Gap Part A" \
'datasets summary genome taxon "2" --released-after "2024-11-25" --released-before "2024-12-05" --as-json-lines | dataformat tsv genome --elide-header --fields "accession,assminfo-biosample-isolation-source" >> "$OUTPUT"'

run_query "2024 Gap Part B" \
'datasets summary genome taxon "2" --released-after "2024-12-06" --released-before "2024-12-16" --as-json-lines | dataformat tsv genome --elide-header --fields "accession,assminfo-biosample-isolation-source" >> "$OUTPUT"'

# --- TARGET 2: 2019 CAP (1 Week) ---
# This specific week (July 24-30) keeps hitting TLS timeouts. Let's split it in half.
run_query "2019 Cap Part A" \
'datasets summary genome taxon "2" --released-after "2019-07-24" --released-before "2019-07-27" --as-json-lines | dataformat tsv genome --elide-header --fields "accession,assminfo-biosample-isolation-source" >> "$OUTPUT"'

run_query "2019 Cap Part B" \
'datasets summary genome taxon "2" --released-after "2019-07-28" --released-before "2019-07-30" --as-json-lines | dataformat tsv genome --elide-header --fields "accession,assminfo-biosample-isolation-source" >> "$OUTPUT"'

echo -e "${GREEN}Manual Recovery Round 3 Finished.${NC}"
echo -e "${YELLOW}Next Step:${NC} Once this finishes, merge all files and remove duplicates."