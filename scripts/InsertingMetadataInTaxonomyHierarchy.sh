#!/usr/bin/env bash

# Created by Joao Pedro (15/03/2026)
# Script to insert metadata into the organized taxonomic hierarchy

# 0 - Check if both arguments are provided
if [ "$#" -ne 2 ]; then
    echo "ERROR - Usage: $0 <metadata_input.tsv> <taxonomy_map.tsv>"
    exit 1
fi

# 1 - Store paths (Can read files as normal files or named pipes (when using <())
INPUT_FILE=$(readlink -f "$1")
MAP_FILE=$(readlink -f "$2")

# Validation (check if the entry exists)
if [[ ! -f "$INPUT_FILE" ]]; then
    echo "ERROR: Input file not found at $INPUT_FILE"
    exit 1
fi
if [[ ! -f "$MAP_FILE" ]]; then
    echo "ERROR: Map file not found at $MAP_FILE"
    exit 1
fi

# 2 - Read the Header of the input file to reuse it in individual Metadata.tsv files
HEADER=$(head -n 1 "$INPUT_FILE")

# 3 - Read the input metadata file line by line (skipping header)
tail -n +2 "$INPUT_FILE" | while IFS=$'\t' read -r Accession Organism_Name RestOfLine; do
	
    # Store the entire content of the line (Accession + Organism + Rest)
    FULL_LINE_CONTENT="$Accession"$'\t'"$Organism_Name"$'\t'"$RestOfLine"

    # 4 - Use the Accession to find the taxonomy in the map file
    # We use 'grep' to find the line and 'awk' or 'read' to parse it
    MAP_LINE=$(grep "^$Accession" "$MAP_FILE")

    if [[ -z "$MAP_LINE" ]]; then
        echo "WARNING: Accession $Accession not found in map file. Skipping..."
        continue
    fi

    # Parse taxonomy from the map file
    # Mapping columns: 1:Acc, 2:Org, 3:TaxID, 4:Dom, 5:Phy, 6:Cla, 7:Ord, 8:Fam, 9:Gen, 10:Spe, 11:Sub
    DOMAIN=$(echo "$MAP_LINE" | cut -f4)
    PHYLUM=$(echo "$MAP_LINE" | cut -f5)
    CLASS=$(echo "$MAP_LINE" | cut -f6)
    ORDER=$(echo "$MAP_LINE" | cut -f7)
    FAMILY=$(echo "$MAP_LINE" | cut -f8)
    GENUS=$(echo "$MAP_LINE" | cut -f9)
    SPECIES=$(echo "$MAP_LINE" | cut -f10)
    SUBSPECIES=$(echo "$MAP_LINE" | cut -f11)

    # 5 - Format Names (Prefixes and Underscores)
    D="d_${DOMAIN// /_}"
    P="p_${PHYLUM// /_}"
    C="c_${CLASS// /_}"
    O="o_${ORDER// /_}"
    F="f_${FAMILY// /_}"
    G="g_${GENUS// /_}"
    S="s_${SPECIES// /_}"
    
    if [[ -z "$SUBSPECIES" || "$SUBSPECIES" == " " ]]; then
        U="u_NoSubspecies"
    else
        U="u_${SUBSPECIES// /_}"
    fi

    ACC_DIR="${Accession// /_}"

    # 6 - Define the Path
    TARGET_PATH="$D/$P/$C/$O/$F/$G/$S/$U/$ACC_DIR"

    # 7 - Check if path exists
    if [[ -d "$TARGET_PATH" ]]; then
        # Create Metadata.tsv and insert header + line content
        echo -e "$HEADER" > "$TARGET_PATH/Metadata.tsv"
        echo -e "$FULL_LINE_CONTENT" >> "$TARGET_PATH/Metadata.tsv"
        echo "SUCCESS: Metadata inserted for $Accession"
    else
        echo "ERROR: Path does not exist for $Accession ($TARGET_PATH). Please create hierarchy first."
    fi

done

echo "---"
echo "Metadata insertion process finished."