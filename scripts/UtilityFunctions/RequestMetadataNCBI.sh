#!/usr/bin/env bash

# Created by Joao Pedro
# 25/02/2026

request_taxon_ncbi() { # request the assemblies from NCBI using the Taxon Name or Tax ID
	local TAX=$1 # REQUIRED
	local SAVE_FILE=$2 # REQUIRED
	local LOG_FILE=$3 # REQUIRED
	local FIELDS=$4 # OPTIONAL - default: all fields
	local RELEASE_AFTER=$5 # OPTIONAL- default: all dates 
	local RELEASE_BEFORE=$6 # OPTIONAL- default: all dates
	

	if [[ -z $TAX ]]; then
		echo "ERROR on line ${BASH_LINENO[0]}: Taxon name or Tax ID not informed for request_taxon_ncbi()"
		return 1
	elif [[ -z $SAVE_FILE ]]; then
		echo "ERROR on line ${BASH_LINENO[0]}: Save file not informed for request_taxon_ncbi()"
		return 1
	elif [[ -z $LOG_FILE ]]; then
		echo "ERROR on line ${BASH_LINENO[0]}: Log File not informed for request_taxon_ncbi()" 
		return 1
	else
		:

	> "$SAVE_FILE" # Truncating the save file
	
	# Inserting the header
	datasets summary genome taxon "Geobacillus" --as-json-lines \
	| dataformat tsv genome --fields $FIELDS | head -n1 >> $SAVE_FILE
	
	
	# Request all the data from NCBI server and inserting in the save file
	datasets summary genome taxon "$TAX" \
		--released-after "$RELEASE_AFTER" \
		--released-before "$RELEASE_BEFORE" \
		--as-json-lines \
		| dataformat tsv genome --elide-header "$FIELDS" >> "$SAVE_FILE" \
		|| { 
		cat <<-EOF >> "$LOG_FILE"
		NCBI Request Failed! Truncate Request:
		Tax: $TAX
		Released before: $RELEASE_BEFORE
		Released after: $RELEASE_AFTER
		Fields: $FIELDS
		EOF
		sleep 60;
	}
	
	# Trim entries with GCF_ (there is always a correspondent GCA Assembly
	sed -i '/^GCF_/d' $SAVE_FILE
	
}
