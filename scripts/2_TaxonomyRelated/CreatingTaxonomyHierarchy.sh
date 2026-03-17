#!/usr/bin/env bash

# Created by Joao Pedro (15/03/2026)
# Script to automate taxonomic hierarchy creation

# --- DIRECTORY STRUCTURE ---
# GenomicMining_Project/
# └── data/
    # └── TaxonomyHieararchy/
        # └── [Domain]/
            # └── [Phylum]/
                # └── [Class]/
                    # └── [Order]/
                        # └── [Family]/
                            # └── [Genus]/
                                # └── [Species]/
                                    # └── [Subspecies]/

# 0 - Check for input argument
if [ "$#" -ne 1 ]; then
    echo "ERROR - Usage: $0 <taxonomy_metadata.tsv>"
    exit 1
fi
INPUT_FILE=$(readlink -f "$1")


# 1 - Read the TSV file line by line, skipping the header
tail -n +2 "$INPUT_FILE" | while IFS=$'\t' read -r Accession Organism_Name TaxID Domain Phylum Class Order Family Genus Species Subspecies; do

    # 1.1 - Formatting Taxon names (Replacing spaces with underscores)
    D="d_${Domain// /_}"
    P="p_${Phylum// /_}"
    C="c_${Class// /_}"
    O="o_${Order// /_}"
    F="f_${Family// /_}"
    G="g_${Genus// /_}"
    S="s_${Species// /_}"
    
    # 1.2 - Handle Empty Subspecies with a default value
    if [[ -z "$Subspecies" || "$Subspecies" == " " ]]; then
        U="u_NoSubspecies"
    else
        U="u_${Subspecies// /_}"
    fi

    # 1.3 - Clean the Accession number
    ACC="${Accession// /_}"

    # 1.4 - Construct and create the directory structure
    TARGET_PATH="$D/$P/$C/$O/$F/$G/$S/$U/$ACC"
    
    if mkdir -p "$TARGET_PATH"; then
        echo "SUCESS: Create or access a path for $ACC"
    else
        echo "ERROR: Failed to create or access $TARGET_PATH" >&2
    fi

done

echo "---"
echo "Hierarchy creation with default subspecies values completed!"