#!/usr/bin/env bash

# File to store results
OUTPUT="manual_recovery_round2.tsv"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' 

run_query() {
    local label=$1
    local cmd=$2
    echo -e "${YELLOW}[RETRYING]:${NC} $label"
    local before=0
    if [ -f "$OUTPUT" ]; then before=$(wc -l < "$OUTPUT"); fi
    
    eval "$cmd"
    
    local after=$(wc -l < "$OUTPUT")
    local diff=$((after - before))
    echo -e "${GREEN}[RESULT]:${NC} Added $diff lines."
    echo "----------------------------------------------------"
    sleep 5
}

echo -e "${GREEN}Starting Manual Recovery Round 2...${NC}"

# 1. Failed due to TLS handshake timeout
run_query "2014 Gap (Retry)" \
'datasets summary genome taxon "2" --released-after "2014-06-18" --released-before "2014-07-09" --as-json-lines | dataformat tsv genome --elide-header --fields "accession,assminfo-biosample-isolation-source" >> "$OUTPUT"'

# 2. Failed due to Taxon Suggest error
run_query "2019 Gap 1 (Retry)" \
'datasets summary genome taxon "2" --released-after "2019-05-12" --released-before "2019-05-18" --as-json-lines | dataformat tsv genome --elide-header --fields "accession,assminfo-biosample-isolation-source" >> "$OUTPUT"'

# 3. Failed due to Gateway timeout
run_query "2024 Gap (Retry)" \
'datasets summary genome taxon "2" --released-after "2024-11-25" --released-before "2024-12-16" --as-json-lines | dataformat tsv genome --elide-header --fields "accession,assminfo-biosample-isolation-source" >> "$OUTPUT"'

# 4. Failed due to Gateway timeout
run_query "2019 Cap (Retry)" \
'datasets summary genome taxon "2" --released-after "2019-07-24" --released-before "2019-07-30" --as-json-lines | dataformat tsv genome --elide-header --fields "accession,assminfo-biosample-isolation-source" >> "$OUTPUT"'

# 5. Failed due to TLS handshake timeout
run_query "2023 Cap 12k (Retry)" \
'datasets summary genome taxon "2" --released-after "2023-03-15" --released-before "2023-03-22" --as-json-lines | dataformat tsv genome --elide-header --fields "accession,assminfo-biosample-isolation-source" >> "$OUTPUT"'

# 6. Partial success (14k added but error thrown) - Retrying full range
run_query "2023 Cap 20k (Retry Full)" \
'datasets summary genome taxon "2" --released-after "2023-03-23" --released-before "2023-03-29" --as-json-lines | dataformat tsv genome --elide-header --fields "accession,assminfo-biosample-isolation-source" >> "$OUTPUT"'

# 7. Failed due to Connection Reset
run_query "2026 Cap 8k (Retry)" \
'datasets summary genome taxon "2" --released-after "2026-01-01" --released-before "2026-01-07" --as-json-lines | dataformat tsv genome --elide-header --fields "accession,assminfo-biosample-isolation-source" >> "$OUTPUT"'

echo -e "${GREEN}Manual Recovery Round 2 Finished.${NC}"