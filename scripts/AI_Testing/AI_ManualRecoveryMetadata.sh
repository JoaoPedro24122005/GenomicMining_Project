#!/usr/bin/env bash

# File to store results
OUTPUT="manual_recovery.tsv"

# Colors for the legend
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' 

# Function to run and count
run_query() {
    local label=$1
    local cmd=$2
    
    echo -e "${YELLOW}[QUERY]:${NC} $label"
    
    # Get count before
    local before=0
    if [ -f "$OUTPUT" ]; then before=$(wc -l < "$OUTPUT"); fi
    
    # Execute the command passed as string
    eval "$cmd"
    
    # Get count after
    local after=$(wc -l < "$OUTPUT")
    local diff=$((after - before))
    
    echo -e "${GREEN}[RESULT]:${NC} Added $diff lines. (Total: $after)"
    echo "----------------------------------------------------"
    
    # Wait to avoid API throttling
    sleep 5
}

echo -e "${GREEN}Starting Manual Recovery...${NC}"

# --- EMPTY GAPS SECTION ---

run_query "2014 Gap (3 weeks)" \
'datasets summary genome taxon "2" --released-after "2014-06-18" --released-before "2014-07-09" --as-json-lines | dataformat tsv genome --elide-header --fields "accession,assminfo-biosample-isolation-source" >> "$OUTPUT"'

run_query "2019 Gap 1 (1 week)" \
'datasets summary genome taxon "2" --released-after "2019-05-12" --released-before "2019-05-18" --as-json-lines | dataformat tsv genome --elide-header --fields "accession,assminfo-biosample-isolation-source" >> "$OUTPUT"'

run_query "2019 Gap 2 (2 weeks)" \
'datasets summary genome taxon "2" --released-after "2019-07-03" --released-before "2019-07-16" --as-json-lines | dataformat tsv genome --elide-header --fields "accession,assminfo-biosample-isolation-source" >> "$OUTPUT"'

run_query "2023 Gap 1 (1 week)" \
'datasets summary genome taxon "2" --released-after "2023-03-30" --released-before "2023-04-05" --as-json-lines | dataformat tsv genome --elide-header --fields "accession,assminfo-biosample-isolation-source" >> "$OUTPUT"'

run_query "2023 Gap 2 (1 week)" \
'datasets summary genome taxon "2" --released-after "2023-04-28" --released-before "2023-05-04" --as-json-lines | dataformat tsv genome --elide-header --fields "accession,assminfo-biosample-isolation-source" >> "$OUTPUT"'

run_query "2023 Gap 3 (2 weeks)" \
'datasets summary genome taxon "2" --released-after "2023-10-05" --released-before "2023-10-19" --as-json-lines | dataformat tsv genome --elide-header --fields "accession,assminfo-biosample-isolation-source" >> "$OUTPUT"'

run_query "2024 Gap (3 weeks)" \
'datasets summary genome taxon "2" --released-after "2024-11-25" --released-before "2024-12-16" --as-json-lines | dataformat tsv genome --elide-header --fields "accession,assminfo-biosample-isolation-source" >> "$OUTPUT"'

run_query "2026 Gap (1 week)" \
'datasets summary genome taxon "2" --released-after "2026-02-02" --released-before "2026-02-07" --as-json-lines | dataformat tsv genome --elide-header --fields "accession,assminfo-biosample-isolation-source" >> "$OUTPUT"'

# --- ROUND NUMBER CAPS SECTION ---

run_query "2019 Cap (7k?)" \
'datasets summary genome taxon "2" --released-after "2019-03-15" --released-before "2019-03-22" --as-json-lines | dataformat tsv genome --elide-header --fields "accession,assminfo-biosample-isolation-source" >> "$OUTPUT"'

run_query "2019 Cap (6k?)" \
'datasets summary genome taxon "2" --released-after "2019-07-24" --released-before "2019-07-30" --as-json-lines | dataformat tsv genome --elide-header --fields "accession,assminfo-biosample-isolation-source" >> "$OUTPUT"'

run_query "2023 Cap (12k?)" \
'datasets summary genome taxon "2" --released-after "2023-03-15" --released-before "2023-03-22" --as-json-lines | dataformat tsv genome --elide-header --fields "accession,assminfo-biosample-isolation-source" >> "$OUTPUT"'

run_query "2023 Cap (20k?)" \
'datasets summary genome taxon "2" --released-after "2023-03-23" --released-before "2023-03-29" --as-json-lines | dataformat tsv genome --elide-header --fields "accession,assminfo-biosample-isolation-source" >> "$OUTPUT"'

run_query "2024 Cap (4k?)" \
'datasets summary genome taxon "2" --released-after "2024-11-18" --released-before "2024-11-24" --as-json-lines | dataformat tsv genome --elide-header --fields "accession,assminfo-biosample-isolation-source" >> "$OUTPUT"'

run_query "2026 Cap (8k?)" \
'datasets summary genome taxon "2" --released-after "2026-01-01" --released-before "2026-01-07" --as-json-lines | dataformat tsv genome --elide-header --fields "accession,assminfo-biosample-isolation-source" >> "$OUTPUT"'

run_query "2026 Cap (12k?)" \
'datasets summary genome taxon "2" --released-after "2026-02-15" --released-before "2026-02-20" --as-json-lines | dataformat tsv genome --elide-header --fields "accession,assminfo-biosample-isolation-source" >> "$OUTPUT"'

echo -e "${GREEN}Manual Recovery Script Finished.${NC}"