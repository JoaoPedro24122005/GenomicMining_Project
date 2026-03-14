#!/usr/bin/env bash

# File to store results
OUTPUT="manual_recovery_round4.tsv"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' 

run_query() {
    local label=$1
    local cmd=$2
    echo -e "${YELLOW}[ROUND 4]:${NC} $label"
    local before=0
    if [ -f "$OUTPUT" ]; then before=$(wc -l < "$OUTPUT"); fi
    
    eval "$cmd"
    
    local after=$(wc -l < "$OUTPUT")
    local diff=$((after - before))
    echo -e "${GREEN}[RESULT]:${NC} Added $diff lines."
    echo "----------------------------------------------------"
    sleep 5
}

echo -e "${GREEN}Starting Manual Recovery Round 4...${NC}"

# --- TARGET 1: 2019 Cap Part A (Still failing) ---
# It only gave 1,000 lines. Let's do it DAY BY DAY.
run_query "2019-07-24" 'datasets summary genome taxon "2" --released-after "2019-07-24" --released-before "2019-07-24" --as-json-lines | dataformat tsv genome --elide-header --fields "accession,assminfo-biosample-isolation-source" >> "$OUTPUT"'
run_query "2019-07-25" 'datasets summary genome taxon "2" --released-after "2019-07-25" --released-before "2019-07-25" --as-json-lines | dataformat tsv genome --elide-header --fields "accession,assminfo-biosample-isolation-source" >> "$OUTPUT"'
run_query "2019-07-26" 'datasets summary genome taxon "2" --released-after "2019-07-26" --released-before "2019-07-26" --as-json-lines | dataformat tsv genome --elide-header --fields "accession,assminfo-biosample-isolation-source" >> "$OUTPUT"'
run_query "2019-07-27" 'datasets summary genome taxon "2" --released-after "2019-07-27" --released-before "2019-07-27" --as-json-lines | dataformat tsv genome --elide-header --fields "accession,assminfo-biosample-isolation-source" >> "$OUTPUT"'

# --- TARGET 2: The 2026 "8k" Suspicion ---
# Your Round 2 result was exactly 8,000. Let's split it to see if more data exists.
run_query "2026 Jan 01-03" 'datasets summary genome taxon "2" --released-after "2026-01-01" --released-before "2026-01-03" --as-json-lines | dataformat tsv genome --elide-header --fields "accession,assminfo-biosample-isolation-source" >> "$OUTPUT"'
run_query "2026 Jan 04-07" 'datasets summary genome taxon "2" --released-after "2026-01-04" --released-before "2026-01-07" --as-json-lines | dataformat tsv genome --elide-header --fields "accession,assminfo-biosample-isolation-source" >> "$OUTPUT"'

echo -e "${GREEN}Manual Recovery Round 4 Finished.${NC}"