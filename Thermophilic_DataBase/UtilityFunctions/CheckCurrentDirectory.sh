#!/usr/bin/env bash

# Created by Joao Pedro
# 02/03/2026

check_current_dir() {
    # 1. Validate that two arguments were not empty
    local current="${1?Error: Current directory not provided}" # exit if empty
    local expected="${2?Error: Expected directory not provided}" # exit if empty

    # 2. Compare the two strings
    if [[ "$current" != "$expected" ]]; then
        echo "ERROR: Location Mismatch!" >&2
        echo "Currently in: $current" >&2
        echo "Expected:     $expected" >&2
        return 1  # Return failure
    else
        echo "Directory check passed: $current"
        return 0  # Return success
    fi
}