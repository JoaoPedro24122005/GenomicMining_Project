#!/usr/bin/env bash

# Script - quote unquote variables
# By Joao Pedro
# 27-02-2026

# Necessary quote:  Var=$.. OR func $..

# Non-quote cases
COMMENTS='^#'				# dont match comments
QUOTED_EXP='"[^"]*"'		# dont match already "..."
MATH_EXP='\(\(' 			# dont match ((...))
COMMAND_SUB_EXP='\$[({]'	# dont match $(...) or ${...} (used for arrays)

# Quote cases
TARGET='\$[a-zA-Z0-9_]+' 	# match $ plus one char at least

# SED expression (Double quotes between the commmand so the variables are expanded)

INPUT=$1
BASENAME="$(basename $INPUT)"
OUTPUT="QUOTED_$BASENAME"

sed -E "/($COMMENTS|$QUOTED_EXP|$MATH_EXP|$COMMAND_SUB_EXP)/!s/$TARGET/\"&\"/g" $INPUT > $OUTPUT

echo "Quoted file saved at $OUTPUT"