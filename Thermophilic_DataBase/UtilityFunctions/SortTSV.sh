#!/usr/bin/env bash

# Created in 07/03/2026

sort_tsv() {
    local file=$1
    local col=$2
    head -n 1 "$file"
    tail -n +2 "$file" | sort -t$'\t' -k"$col","$col"
}