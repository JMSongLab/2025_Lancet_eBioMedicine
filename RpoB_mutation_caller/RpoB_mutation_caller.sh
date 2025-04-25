#!/bin/bash

reference_file="reference/K3U68_16810.fasta"
input_file="protein/NCBI_RpoB_protein.fasta" #Sequence should be linearized before proceeding
output_file="output/NCBI_RpoB_protein_result.tsv"

reference=$(awk '/^>/{next}{printf "%s", $0}' "$reference_file" | tr '[:lower:]' '[:upper:]')

# Use tab-separated header
echo -e "sequence_ID\tvariant" > "$output_file"

while IFS= read -r line; do
  if [[ $line =~ ^\>(.+)_1$ ]]; then
    sequence_id="${BASH_REMATCH[1]}"
  elif [[ $line =~ ^\>(.+) ]]; then
    sequence_id="${BASH_REMATCH[1]}"
  else
    test_sequence="$line"
    variants=""

    for ((i=0; i<${#reference} && i<${#test_sequence}; i++)); do
      ref_base="${reference:$i:1}"
      test_base="${test_sequence:$i:1}"

      if [[ $ref_base != $test_base ]]; then
        variants+="${ref_base}$((i+1))${test_base},"
      fi
    done

    if [ -n "$variants" ]; then
      variants=${variants%,}  # Remove trailing comma
      echo -e "${sequence_id}\t${variants}" >> "$output_file"
    else
      echo -e "${sequence_id}\tWT" >> "$output_file"
    fi
  fi
done < "$input_file"
