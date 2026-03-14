
# --- EXAMPLE OF USE ---

source "\UtilityFunctions\AI_RequestMetadataNCBI.sh"

# 1. Define your settings
MY_FIELDS="accession,assminfo-biosample-isolation-source,organism-name"
MY_SAVE_FILE="Bacteria_Research_2026.tsv"
MY_LOG="Research_Errors.log"

echo "Starting the metadata harvest..."

# 2. Insert the header first (so the TSV is readable in Excel/R)
insert_ncbi_header "$MY_SAVE_FILE" "$MY_FIELDS"

# 3. Request by Taxon Name (Example: Geobacillus)
request_taxon_ncbi "Geobacillus" "$MY_SAVE_FILE" "$MY_LOG" "$MY_FIELDS" "2024-01-01" "2024-12-31"

# 4. Request by TaxID (Example: 2 for all Bacteria)
# Note: We use a small range here to avoid those timeouts we fought earlier!
request_taxon_ncbi "2" "$MY_SAVE_FILE" "$MY_LOG" "$MY_FIELDS" "2026-01-01" "2026-01-05"

# 5. Request using an Input File of Accessions
# Assuming you have a file named 'targets.txt' with GCA numbers
if [[ -f "targets.txt" ]]; then
    request_file_acession_ncbi "targets.txt" "$MY_SAVE_FILE" "$MY_LOG" "$MY_FIELDS"
fi

echo "Process complete. Check $MY_SAVE_FILE for data and $MY_LOG for any failures."