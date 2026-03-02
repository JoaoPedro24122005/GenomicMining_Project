#!/usr/bin/env bash

# Created by Joao Pedro
# 25/02/2026

check_current_dir() {
    # 1. Validate that two arguments were passed
    local current="${1?Error: Current directory not provided to function}"
    local expected="${2?Error: Expected directory not provided to function}"

    # 2. Compare the two strings
    if [[ "$current" != "$expected" ]]; then
        echo "ERROR: Location Mismatch!" >&2
        echo "Currently in: $current" >&2
        echo "Expected:    $expected" >&2
        return 1  # Return failure
    else
        echo "Directory check passed: $current"
        return 0  # Return success
    }
}
# 1 - Filter the accession according to the list of thermophilic keywords

keywords_ThermophilicIS= "$(tail -n +3 ../data/SearchingForThermophiles/ThermophilesIsolationSource.txt  | cut -d ' ' -f 2)"
keywords_NonThermophilicIS= "$(tail -n +3 ../data/SearchingForThermophiles/Non-ThermophilesIsolationSource.txt  | cut -d ' ' -f 2-3)"

declare -A OUTPUT_temp # creating a hashmap

OUTPUT_temp[${raw_files[0]}]="ThermophilesAcession_Bac.tsv"
OUTPUT_temp[${raw_files[1]}]="ThermophilesAcession_Arc.tsv"

for output_file in "${OUTPUT_temp[@]}"; do
	> "$output_file" # Truncate the file (or clean output from other runs)
done

for file in "${raw_files[@]}"; do
	for keyword in "$keywords_ThermophilicIS"; do
		grep -i "$keyword" "$file" >> "${OUTPUT_temp[$file]}" # hashmaps need curly braces {} to force bash to treat as a hashmap and not literal text
	done
	sort "${OUTPUT_temp[$file]}" | uniq > temp.tsv && mv -v temp.tsv "${OUTPUT_temp[$file]}"
done

# 4 - Using the list of accession to recover all the metadata fields required

temp_files=( "${OUTPUT_temp[${raw_files[0]}]}" "${OUTPUT_temp[${raw_files[1]}]}" )

declare -A OUTPUT

OUTPUT[${temp_files[0]}]="MetadataFromIS_Bac.tsv"
OUTPUT[${temp_files[1]}]="MetadataFromIS_Arc.tsv"
	
for output_file in "${OUTPUT[@]}"; do
	> "$output_file"
done

FIELDS="$(cat ../data/SearchingForThermophiles/ListMetadataFields.txt)"

echo "Start - NCBI Request: All metadata fields for thermophilic organisms"
start=$(date +%s)
for file in "${temp_files[@]}"; do
	tail -n +2 $file | cut -f1 | \
	datasets summary genome accession --inputfile - --as-json-lines | \
	dataformat tsv genome --fields "$FIELDS" > "${OUTPUT[$file]}" \
	|| { echo "NCBI Request Failed! Stopping script."; exit 1; }
done
end=$(date +%s)
echo "End - NCBI Request: All metadata fields for thermophilic organisms"
calc_duration $start $end

# 5 - Moving the final files to a more organized folder

NEW_DIR="../../../data/DataTables/"

for file in "${temp_files[@]}"; do
	mv -v $file $NEW_DIR
done



# set -o pipefail # Forces the entire pipeline to fail if any of the commands inside it fail

# calc_duration() {
	# local start=$1
	# local end=$2
	# local diff=$(( end - start ))
	# echo "Duration of command: $(( diff/60 ))m : $(( diff%60 ))s"
	# echo " "
# }

# # 0 - Preparing the directorys where the data will be save

# WORK_DIR="TempFiles/$(basename $0)" # Defining the working directory
# mkdir -p "$WORK_DIR" # Create it if it doesn't exist
# cd "$WORK_DIR" || exit # Move the script's execution context there
# # current path of the script' process: /mnt/c/Users/jpcas/Downloads/Bioinformatics/GenomicMining_Project/scripts/TempFiles/$(basename $0)

# TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S") # Get the current date and time
# LOG_DIR="LogFiles"
# mkdir -p "$LOG_DIR"
# LOG_ERROR="LogFiles/ERROR_$TIMESTAMP.log"

# # Files created by the script
# # tempBacMetadata.tsv
# # tempArcMetadata.tsv
# # ThermophilesAcession_Bac.tsv
# # ThermophilesAcession_Arc.tsv
# # MetadataFromIS_Bac.tsv
# # MetadataFromIS_Arc.tsv

 
# # 1 - Download the metadata from all Bacteria and Archaea members

# # "Total number of Bacteria Assemblys in NCBI (manually checked at 26/02/2025 - 09:51):" 
# # "2.938.712 assemblies"
# # "Link to check: https://www.ncbi.nlm.nih.gov/datasets/genome/?taxon=2"
# TOTAL_ASSEMBLY_BAC="2.938.712"

# Bacteria_TaxID=2
# Archaea_TaxID=2157

# # BACTERIA - Dividing the request by date (to avoid timeout due to big request - more than 2 million assemblies)

# years=( $(seq 2010 2026) ) # Before 2011 (start-2011), ... , After 2025 (2026-now)

# # Truncate the file (or clean output from other runs) and put the HEADER
# datasets summary genome taxon "Geobacillus" \
			# --as-json-lines | dataformat tsv genome --fields accession,assminfo-biosample-isolation-source | head -n1 > tempBacMetadata.tsv 

# # Five different dates to split the request
# # 50 split start dates (MM-DD)
# starts=(
  # "01-01" "01-08" "01-15" "01-23" "01-30" "02-06" "02-14" "02-21" "02-28" "03-07"
  # "03-15" "03-22" "03-29" "04-06" "04-13" "04-20" "04-28" "05-05" "05-12" "05-20"
  # "05-27" "06-03" "06-11" "06-18" "06-25" "07-03" "07-10" "07-17" "07-25" "08-01"
  # "08-08" "08-16" "08-23" "08-30" "09-07" "09-14" "09-21" "09-29" "10-06" "10-13"
  # "10-21" "10-28" "11-04" "11-12" "11-19" "11-26" "12-04" "12-11" "12-18" "12-26"
# )

# # 50 split end dates (MM-DD)
# ends=(
  # "01-07" "01-14" "01-22" "01-29" "02-05" "02-13" "02-20" "02-27" "03-06" "03-14"
  # "03-21" "03-28" "04-05" "04-12" "04-19" "04-27" "05-04" "05-11" "05-19" "05-26"
  # "06-02" "06-10" "06-17" "06-24" "07-02" "07-09" "07-16" "07-24" "07-31" "08-07"
  # "08-15" "08-22" "08-29" "09-06" "09-13" "09-20" "09-28" "10-05" "10-12" "10-20"
  # "10-27" "11-03" "11-11" "11-18" "11-25" "12-03" "12-10" "12-17" "12-25" "12-31"
# )
# number_of_splits=50
# sleep_time=2

# echo "Starting - NCBI Request: Downloading all Bacteria Metadata:"
# start=$(date +%s)
# for year in ${years[@]}; do

	# # ISO 8601 standard YYYY-MM-DD is recommended
	# after="${year}-01-01" # include the "after date" (>=)
	# before="${year}-12-31" # include the "before date" (<=)
	
	# # All the assemblies from before 2011 (start-2010)
	# if [[ $year == "2010" ]]; then
		# echo "Downloading all Bacteria Metadata from year: start of NCBI - $year:"
		# datasets summary genome taxon "$Bacteria_TaxID" \
			# --released-before $before \
			# --as-json-lines | dataformat tsv genome --elide-header --fields accession,assminfo-biosample-isolation-source >> tempBacMetadata.tsv \
			# || { echo "NCBI Request Failed! Truncate Request: Before: $before" >> $LOG_ERROR; sleep 60; }
		
	# # All the assemblies from after 2025 (2026-now)
	# elif [[ $year == "2026" ]]; then
		# echo "Downloading all Bacteria Metadata from year: $year - present:"
		# datasets summary genome taxon "$Bacteria_TaxID" \
			# --released-after $after \
			# --as-json-lines | dataformat tsv genome --elide-header --fields accession,assminfo-biosample-isolation-source >> tempBacMetadata.tsv \
			# || { echo "NCBI Request Failed! Truncate Request: After: $after" >> $LOG_ERROR; sleep 60; }
			
	# else # 2011 - 2025
		# for split in $(seq $number_of_splits); do
		
			# after="${year}-${starts[split-1]}" # include the "after date" (>=)
			# before="${year}-${ends[split-1]}" # include the "before date" (<=)
		
			# echo "Downloading all Bacteria Metadata from year: $year ($split/$number_of_splits):"
			# datasets summary genome taxon "$Bacteria_TaxID" \
				# --released-after $after \
				# --released-before $before \
				# --as-json-lines | dataformat tsv genome --elide-header --fields accession,assminfo-biosample-isolation-source >> tempBacMetadata.tsv \
			# || { echo "NCBI Request Failed! Truncate Request: Before: $before / After: $after" >> $LOG_ERROR; sleep 60; }
				
			# sleep $sleep_time # sleep for 1 seconds to avoid timeout from the server
				
		# done
	# fi
	
	# echo Total of Assemblies founded: $(wc -l < tempBacMetadata.tsv) / Total of Assemblies expected: $TOTAL_ASSEMBLY_BAC
	
# done
	
# end=$(date +%s)
# calc_duration $start $end

# # ARCHAEA - Direct requesting for all assemblies (request is much shorter - about 34K assemblies)
# TOTAL_ASSEMBLY_ARC="34.827"

# echo "Start - NCBI Request: Downloading all Archaea Metadata in the background:"
# lines=0
# start=$(date +%s)
# datasets summary genome taxon "$Archaea_TaxID" --as-json-lines \
	# | dataformat tsv genome --fields accession,assminfo-biosample-isolation-source > tempArcMetadata.tsv \
	# || { echo "NCBI Request Failed! Stopping script."; exit 1; }
# (( lines += $(wc -l < tempArcMetadata.tsv) ))
# echo Total of Assemblies founded: $lines / Total of Assemblies expected: $TOTAL_ASSEMBLY_ARC
# end=$(date +%s)
# calc_duration $start $end 

# raw_files=( "tempBacMetadata.tsv" "tempArcMetadata.tsv" )