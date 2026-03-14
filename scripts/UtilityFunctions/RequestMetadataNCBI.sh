#!/usr/bin/env bash

# Created by Joao Pedro
# 25/02/2026

set -o pipefail # Forces the entire pipeline to fail if any of the commands inside it fail
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S") # timestamp to diferenciate the name of the files (so they doesnt get overwriten)

insert_ncbi_header() {
	local SAVE_FILE="$1"
	local FIELDS="$2"
	
	if [[ -z $SAVE_FILE ]]; then
		log_error "Save file not informed (SAVE_FILE=$SAVE_FILE)"
		return 1
	fi
	
	# Inserting the header (random taxon name)
	datasets summary genome taxon "Geobacillus" --as-json-lines \
	| dataformat tsv genome --fields $FIELDS | head -n1 >> "$SAVE_FILE" 
}


request_taxon_ncbi() { # request the assemblies from NCBI using the Taxon Name or Tax ID
	local TAX="$1" 											# REQUIRED - TaxID or Taxon name
	local SAVE_FILE="${2:-NCBI_Metadata_${TIMESTAMP}.tsv}"	# OPTIONAL - default: output go to a file named 'NCBI_Metadata_${TIMESTAMP}.tsv' - Name of file (.tsv)
	local LOG_FILE="${3:-Log_Metadata_${TIMESTAMP}.log}" 	# OPTIONAL - default: errors go to a file named 'Log_Metadata_${TIMESTAMP}.log' - Name of file (.log)
	local FIELDS="$4" 										# OPTIONAL - default: empty value - String with fields of metadata separated by ","
	local RELEASE_AFTER="$5" 								# OPTIONAL- default: emnpty value - date in format YYYY-MM-DD
	local RELEASE_BEFORE="$6" 								# OPTIONAL- default: empty value - date in format YYYY-MM-DD
	
	# Check if Tax variable is empty
	if [[ -z $TAX ]]; then 
		log_error "Taxon name or Tax ID not informed (Tax=$TAX)"
		return 1
	fi
	
	# Starting request message
	cat<<-EOF >&1 
	---- Starting Request ----
	Taxon Name or TaxID: $TAX
	Released before: ${RELEASE_BEFORE:-Not specified}
	Released after: ${RELEASE_AFTER:-Not specified}
	Fields: ${FIELDS:-All}
	-------------------------
	EOF
	
	# Request all the data from NCBI server and insert in the save_file
	datasets summary genome taxon "$TAX" \
		--released-after "$RELEASE_AFTER" \
		--released-before "$RELEASE_BEFORE" \
		--as-json-lines \
		| dataformat tsv genome --elide-header --fields "$FIELDS" >> "$SAVE_FILE" || { 
		# Error message - if datasets or dataformat fail (timeout from server)
		cat <<-EOF >> "$LOG_FILE"
		-------------------------
		NCBI Request Failed! Truncate Request:
		Tax: $TAX
		Released before: $RELEASE_BEFORE
		Released after: $RELEASE_AFTER
		Fields: $FIELDS
		-------------------------
		EOF
		sleep 60; # sleep command so you dont receive timeout in sequence
	}
}

request_file_taxon_ncbi() {
	local INPUT_FILE="$1" 									# REQUIRED - default: no default - File with a colunm of Taxons or TaxID
	local SAVE_FILE="${2:-NCBI_Metadata_${TIMESTAMP}.tsv}"	# OPTIONAL - default: output go to a file named 'NCBI_Metadata_${TIMESTAMP}.tsv' - Name of file (.tsv)
	local LOG_FILE="${3:-Log_Metadata_${TIMESTAMP}.log}" 	# OPTIONAL - default: errors go to a file named 'Log_Metadata_${TIMESTAMP}.log' - Name of file (.log)
	local FIELDS="$4" 										# OPTIONAL - default: all fields - String with fields of metadata separated by ","
	local RELEASE_AFTER="$5" 								# OPTIONAL- default: all dates - date in format YYYY-MM-DD
	local RELEASE_BEFORE="$6" 								# OPTIONAL- default: all dates - date in format YYYY-MM-DD 
	
	# Check if input file is in the current directory
	if [[ ! -f "$INPUT_FILE" ]]; then
		log_error "Input file $INPUT_FILE not founded"
		return 1
	fi
	
	# Starting request message
	cat<<-EOF >&1 
	---- Starting Request ----
	Taxon Name or TaxID: $TAX
	Released before: ${RELEASE_BEFORE:-Not specified}
	Released after: ${RELEASE_AFTER:-Not specified}
	Fields: ${FIELDS:-All}
	-------------------------
	EOF
	
	# Request all the data from NCBI server and insert in the save_file
	datasets summary genome taxon --inputfile "$FILE" \
		--released-after "$RELEASE_AFTER" \
		--released-before "$RELEASE_BEFORE" \
		--as-json-lines \
		| dataformat tsv genome --elide-header --fields "$FIELDS" >> "$SAVE_FILE" || { 
		# Error message - if datasets or dataformat fail (timeout from server)
		cat <<-EOF >> "$LOG_FILE"
		-------------------------
		NCBI Request Failed! Truncate Request:
		Tax: $TAX
		Released before: $RELEASE_BEFORE
		Released after: $RELEASE_AFTER
		Fields: $FIELDS
		-------------------------
		EOF
		sleep 60; # sleep command so you dont receive timeout in sequence
	}

}

request_file_acession_ncbi() {
	local INPUT_FILE="$1" 									# REQUIRED - default: no default - File with a colunm of Acession Number (GCA_...)
	local SAVE_FILE="${2:-NCBI_Metadata_${TIMESTAMP}.tsv}"	# OPTIONAL - default: output go to a file named 'NCBI_Metadata_${TIMESTAMP}.tsv' - Name of file (.tsv)
	local LOG_FILE="${3:-Log_Metadata_${TIMESTAMP}.log}" 	# OPTIONAL - default: errors go to a file named 'Log_Metadata_${TIMESTAMP}.log' - Name of file (.log)
	local FIELDS="$4" 										# OPTIONAL - default: all fields - String with fields of metadata separated by ","
	local RELEASE_AFTER="$5" 								# OPTIONAL- default: all dates - date in format YYYY-MM-DD
	local RELEASE_BEFORE="$6" 								# OPTIONAL- default: all dates - date in format YYYY-MM-DD 
	
	# Check if input file is in the current directory
	if [[ ! -f "$INPUT_FILE" ]]; then
		log_error "Input file $INPUT_FILE not founded"
		return 1
	fi
	
	# Starting request message
	cat<<-EOF >&1 
	---- Starting Request ----
	Taxon Name or TaxID: $TAX
	Released before: ${RELEASE_BEFORE:-Not specified}
	Released after: ${RELEASE_AFTER:-Not specified}
	Fields: ${FIELDS:-All}
	-------------------------
	EOF
	
	# Request all the data from NCBI server and insert in the save_file
	datasets summary genome taxon --inputfile "$FILE" \
		--released-after "$RELEASE_AFTER" \
		--released-before "$RELEASE_BEFORE" \
		--as-json-lines \
		| dataformat tsv genome --elide-header --fields "$FIELDS" >> "$SAVE_FILE" || { 
		# Error message - if datasets or dataformat fail (timeout from server)
		cat <<-EOF >> "$LOG_FILE"
		-------------------------
		NCBI Request Failed! Truncate Request:
		Tax: $TAX
		Released before: $RELEASE_BEFORE
		Released after: $RELEASE_AFTER
		Fields: $FIELDS
		-------------------------
		EOF
		sleep 60; # sleep command so you dont receive timeout in sequence
	}


}
