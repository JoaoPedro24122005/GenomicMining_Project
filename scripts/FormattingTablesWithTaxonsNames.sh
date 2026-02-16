#!/usr/bin/env bash

# One-liner to remove the duplicates rows that have the first field being different from the forth field (if the field is 
# consider lowecase)

tail -n +2 TaxonsFromLiterature_Bac.txt | taxonkit name2taxid -i 2 -r > temp.tsv && awk -F '\t' 'FNR==NR {count[$2]++; next} 
!(count[$2] > 1 && tolower($1) !~ tolower($4))' temp.tsv temp.tsv | column -t -s $'\t' | less
