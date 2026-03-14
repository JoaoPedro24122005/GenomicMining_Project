#!/bin/bash

# Configuration
TAXON="2"
FIELDS="accession,assminfo-biosample-isolation-source"
OUTPUT_FILE="temp_bac.tsv"

# Colors for better visibility
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Define the problematic ranges (Start Date | End Date)
RANGES=(
    "2014-05-27 2014-08-07"
    "2019-03-15 2019-05-26"
    "2019-05-27 2019-08-07"
    "2023-03-15 2023-05-26"
    "2023-08-08 2023-10-19"
    "2024-10-19 2024-12-31"
    "2026-01-01 2026-03-05"
)

# Initialize output file
> "$OUTPUT_FILE"

echo -e "${BLUE}Starting NCBI Partitioned Retrieval...${NC}"

for range in "${RANGES[@]}"; do
    START_STR=$(echo $range | cut -d' ' -f1)
    END_STR=$(echo $range | cut -d' ' -f2)

    START_SEC=$(date -d "$START_STR" +%s)
    END_SEC=$(date -d "$END_STR" +%s)
    
    DIFF=$(( END_SEC - START_SEC ))
    STEP=$(( DIFF / 10 ))

    echo -e "\n${YELLOW}-------------------------------------------------------${NC}"
    echo -e "${YELLOW}PROCESSING RANGE: $START_STR to $END_STR${NC}"
    echo -e "${YELLOW}-------------------------------------------------------${NC}"

    for i in {0..9}; do
        PART_START_SEC=$(( START_SEC + (i * STEP) ))
        PART_END_SEC=$(( START_SEC + ((i + 1) * STEP) ))
        
        if [ $i -ne 0 ]; then
            PART_START_SEC=$(( PART_START_SEC + 86400 ))
        fi
        
        if [ $i -eq 9 ]; then
            PART_END_SEC=$END_SEC
        fi

        P_START=$(date -d "@$PART_START_SEC" +%F)
        P_END=$(date -d "@$PART_END_SEC" +%F)

        # PRE-REQUEST MESSAGE
        echo -n -e "  [Part $((i+1))/10] Querying $P_START to $P_END... "

        # Capture initial line count to calculate progress
        BEFORE_COUNT=$(wc -l < "$OUTPUT_FILE")

        # The actual NCBI Command
        datasets summary genome taxon "$TAXON" \
            --released-after "$P_START" \
            --released-before "$P_END" \
            --as-json-lines 2>/dev/null | \
        dataformat tsv genome --elide-header --fields "$FIELDS" >> "$OUTPUT_FILE"
        
        # POST-REQUEST MESSAGE
        AFTER_COUNT=$(wc -l < "$OUTPUT_FILE")
        NEW_ENTRIES=$(( AFTER_COUNT - BEFORE_COUNT ))
        
        echo -e "${GREEN}Done!${NC} (Added: $NEW_ENTRIES | Total so far: $AFTER_COUNT)"
        
        sleep 1
    done
done

echo -e "\n${BLUE}=======================================================${NC}"
echo -e "${GREEN}SUCCESS:${NC} All truncated requests completed."
echo -e "Final file: ${YELLOW}$OUTPUT_FILE${NC}"
echo -e "Final entry count: ${GREEN}$(wc -l < "$OUTPUT_FILE")${NC}"
echo -e "${BLUE}=======================================================${NC}"