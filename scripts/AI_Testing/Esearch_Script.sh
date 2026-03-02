#!/bin/bash

# Define the output file
OUTPUT_FILE="bacteria_isolation_sources.tsv"
echo -e "Accession\tIsolationSource" > $OUTPUT_FILE

echo "Starting search for Bacteria Assemblies..."

# 1. Get the total count of bacterial assemblies (GCA_ only)
# We search for "Bacteria"[Organism] AND "latest"[filter]
# We use GCA* to prioritize GenBank (excluding GCF_ RefSeq later)
TOTAL=$(esearch -db genome -query "Bacteria[Organism] AND GCA*" | xtract -version | grep -oP '(?<=<Count>)\d+')

echo "Found approximately $TOTAL records. Processing in batches..."

# 2. Loop through in batches of 500
STEP=500
for (( i=0; i<=$TOTAL; i+=$STEP ))
do
    echo "Processing records $i to $((i+STEP))..."
    
    # Fetch Assembly Accessions and BioSample IDs
    # Then immediately link to BioSample to get the Isolation Source
    esearch -db assembly -query "Bacteria[Organism] AND \"latest genbank\"[filter]" \
        -restart $i -max $STEP | \
    efetch -format docsum | \
    xtract -pattern DocumentSummary -element AssemblyAccession,BioSampleAccn | \
    while read -r ACC BSM; do
        
        # Filter: Only keep GCA_ accessions (Skip GCF_)
        if [[ $ACC == GCA_* ]]; then
            
            # Fetch the Isolation Source for this specific BioSample
            ISO_SOURCE=$(esearch -db biosample -query "$BSM" | efetch -format xml | \
                xtract -pattern BioSample -block Attributes \
                -if Attribute@attribute_name -equals "isolation_source" -element Attribute)
            
            # If isolation source is empty, mark as Unknown
            if [ -z "$ISO_SOURCE" ]; then ISO_SOURCE="Not_Provided"; fi
            
            # Append to file
            echo -e "$ACC\t$ISO_SOURCE" >> $OUTPUT_FILE
        fi
    done
    
    # 3. Slow down: Sleep for 1 second between batches to respect NCBI API limits
    sleep 1
done

echo "Done! Data saved to $OUTPUT_FILE"