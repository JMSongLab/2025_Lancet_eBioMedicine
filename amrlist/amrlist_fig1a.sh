#!/bin/bash

# Input files and folder
AMR_LIST="amrlist_used_in_fig1a.txt"
AMR_DIR="amrfinder_results"
OUTPUT="amr_matrix.tsv"

echo "AMRFinder results should be in '$AMR_DIR' folder"
echo "Which database are the AMRFinder result files from? (NCBI or PathogenWatch)"
read -r DB_SOURCE

DB_SOURCE=$(echo "$DB_SOURCE" | tr '[:upper:]' '[:lower:]')

if [[ "$DB_SOURCE" != "ncbi" && "$DB_SOURCE" != "pathogenwatch" ]]; then
    echo "Error: Please enter either 'NCBI' or 'PathogenWatch'."
    exit 1
fi

# Read AMR classes into array, remove blanks and trim whitespace
mapfile -t AMR_CLASSES < <(sed 's/^[[:space:]]*//; s/[[:space:]]*$//' "$AMR_LIST" | grep -v '^$')

# Write header to output
{
    echo -ne "Accession"
    for amr in "${AMR_CLASSES[@]}"; do
        echo -ne "\t$amr"
    done
    echo
} > "$OUTPUT"

# Process each AMRFinder result file
for file in "$AMR_DIR"/*.txt; do
    filename=$(basename "$file")

    if [[ "$DB_SOURCE" == "ncbi" ]]; then
        accession=$(echo "$filename" | cut -d'_' -f1-2)
    else
        accession=$(echo "$filename" | sed 's/.fasta_results.txt$//')
    fi

    echo -ne "$accession" >> "$OUTPUT"

    for amr in "${AMR_CLASSES[@]}"; do
        if awk -v drug="$(echo "$amr" | tr '[:upper:]' '[:lower:]')" '
            NR > 1 {
                if (index(tolower($0), drug)) {
                    found = 1
                    exit
                }
            }
            END { exit !found }
        ' "$file"; then
            echo -ne "\tR" >> "$OUTPUT"
        else
            echo -ne "\tS" >> "$OUTPUT"
        fi
    done
    echo >> "$OUTPUT"
done
