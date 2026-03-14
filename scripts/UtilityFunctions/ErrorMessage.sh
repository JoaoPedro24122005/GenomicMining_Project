#!/usr/bin/env bash

# Created by Joao Pedro
# 02/03/2026

log_error() { # CALL: log_error "Message"
    local MESSAGE="${1:-No Message}"
    
    local CALLER="${FUNCNAME[1]:-main}" # FUNCNAME[1] is the function that CALLED log_error (if the call happens in main = main)
    local LINE_NUM="${BASH_LINENO[0]}" # BASH_LINENO[0] is the line number where the call happened
    
    cat <<-EOF >&2
    ------------------------------------------
        ERROR in function: $CALLER
        At line: $LINE_NUM
        Message: $MESSAGE
        Current path: $(pwd)
    ------------------------------------------
		EOF
}