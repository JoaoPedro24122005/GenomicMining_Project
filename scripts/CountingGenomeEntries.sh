#!/usr/bin/env bash

number_of_entries=0
timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
script_name=$(basename $0 .sh)
log_file="LogFiles/$script_name~$timestamp"

sed -e 's/.__//g' -e '/#.*$/d' "$1" > "clean-tax-names.txt"

cat "clean-tax-names.txt" | xargs -d '\n' -L 2 | while read chunk ; do
	echo "Processing batch: $chunk"
	current_count=$(datasets summary genome taxon $chunk --as-json-lines 2>>$log_file | wc -l)
	number_of_entries=$(( $number_of_entries + $current_count ))
 	sleep 1 #Wait 1 sec between requests (to not overcharge the server)
	echo "Number of entries founded: $number_of_entries"
done

rm clean-tax-names.txt
