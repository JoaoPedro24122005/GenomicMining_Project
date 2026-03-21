#!/usr/bin/env bash

# Created by Joao Pedro
# 03/03/2026

# Getting the current directory 
SCRIPT_PATH="${BASH_SOURCE[0]}"
SCRIPT_DIR=$(dirname "$SCRIPT_PATH")
CUR_DIR=$(cd "$SCRIPT_DIR" && pwd)

source "$CUR_DIR/ErrorMessage.sh"

read_file_path() {
    local TARGET_PATH=$1
     if [[ -z "$TARGET_PATH" ]]; then 
        log_error "Path not informed for function read_dir_path   "
    fi
    
    # Reject if the path doesn't contain a slash
    if [[ "$TARGET_PATH" != */* ]]; then
        log_error "Please provide a full or relative path (e.g., $CUR_DIR/$TARGET_PATH)"
        return 1
    fi
    
    # Check if the file exists in the . (current dir)
    if [[ -f "$TARGET_PATH" ]]; then
        echo "$TARGET_PATH"
        return 0
    else
        log_error "File not founded at: $TARGET_PATH"
        return 1 # Exit with 1 to indicate an error occurred
    fi
}

read_dir_path() {
    local TARGET_PATH=$1
    if [[ -z "$TARGET_PATH" ]]; then 
        log_error "Path not informed for function read_dir_path"
        return 1
    fi
    
    # Reject if the path doesn't contain a slash
    if [[ "$TARGET_PATH" != */* ]]; then
        log_error "Please provide a full or relative path (e.g., $CUR_DIR/$TARGET_PATH)"
        return 1
    fi

    # Check if the directory exists in the . (current dir)
    if [[ -d "$TARGET_PATH" ]]; then
        echo $TARGET_PATH
        return 0
    else
        log_error "Directory not found at: $TARGET_PATH"
        return 1
    
    fi
    
}