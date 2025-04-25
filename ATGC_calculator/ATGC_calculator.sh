#!/bin/bash

# Input and output directories
input_dir="wgs_cds"
output_dir="outputs"

# Ensure output directory exists
mkdir -p "$output_dir"

# Process each input file in the input directory
for input_file in "$input_dir"/*.fna; do
    base_name=$(basename "$input_file" .fna)
    output_file="$output_dir/${base_name}_atgc_contents.tsv"

    # Header
    echo -e "Locus\tGene\tProtein\tLocation\tLength\tGene_Sequence\tA_Count\tT_Count\tG_Count\tC_Count\tGC_Percentage\tAT_Percentage" > "$output_file"

    # Initialize variables
    locus_tag=""
    gene=""
    protein=""
    location=""
    gene_sequence=""

    while read -r line; do
        if [[ $line == ">"* ]]; then
            if [[ -n $gene_sequence && -n $location ]]; then
                clean_location=$(echo "$location" | tr -d '<>' | sed 's/complement(//;s/)//')
                if [[ "$clean_location" =~ ([0-9]+)\.\.([0-9]+) ]]; then
                    start="${BASH_REMATCH[1]}"
                    end="${BASH_REMATCH[2]}"
                    if (( end > start )); then
                        length=$((end - start + 1))
                    else
                        length=$((start - end + 1))
                    fi

                    gene_sequence_upper=$(echo "$gene_sequence" | tr '[:lower:]' '[:upper:]')
                    A_COUNT=$(echo "$gene_sequence_upper" | grep -o "A" | wc -l)
                    T_COUNT=$(echo "$gene_sequence_upper" | grep -o "T" | wc -l)
                    G_COUNT=$(echo "$gene_sequence_upper" | grep -o "G" | wc -l)
                    C_COUNT=$(echo "$gene_sequence_upper" | grep -o "C" | wc -l)

                    TOTAL_COUNT=$((A_COUNT + T_COUNT + G_COUNT + C_COUNT))
                    GC_COUNT=$((G_COUNT + C_COUNT))
                    AT_COUNT=$((A_COUNT + T_COUNT))

                    if [[ $TOTAL_COUNT -gt 0 ]]; then
                        GC_PERCENTAGE=$(awk "BEGIN {printf \"%.2f\", ($GC_COUNT / $TOTAL_COUNT) * 100}")
                        AT_PERCENTAGE=$(awk "BEGIN {printf \"%.2f\", ($AT_COUNT / $TOTAL_COUNT) * 100}")
                    else
                        GC_PERCENTAGE="0.00"
                        AT_PERCENTAGE="0.00"
                    fi

                    echo -e "${locus_tag:-none}\t${gene:-none}\t${protein:-none}\t${location:-none}\t${length:-none}\t${gene_sequence:-none}\t$A_COUNT\t$T_COUNT\t$G_COUNT\t$C_COUNT\t$GC_PERCENTAGE%\t$AT_PERCENTAGE%" >> "$output_file"
                fi
            fi

            # Reset for next entry
            gene_sequence=""
            locus_tag=$(echo "$line" | sed -n 's/.*\[locus_tag=\([^]]*\)\].*/\1/p')
            gene=$(echo "$line" | sed -n 's/.*\[gene=\([^]]*\)\].*/\1/p')
            protein=$(echo "$line" | sed -n 's/.*\[protein=\([^]]*\)\].*/\1/p')
            location=$(echo "$line" | sed -n 's/.*\[location=\([^]]*\)\].*/\1/p')
        else
            gene_sequence="${gene_sequence}$(echo "$line" | tr -d '\n')"
        fi
    done < "$input_file"

    # Final gene entry after EOF
    if [[ -n $gene_sequence && -n $location ]]; then
        clean_location=$(echo "$location" | tr -d '<>' | sed 's/complement(//;s/)//')
        if [[ "$clean_location" =~ ([0-9]+)\.\.([0-9]+) ]]; then
            start="${BASH_REMATCH[1]}"
            end="${BASH_REMATCH[2]}"
            if (( end > start )); then
                length=$((end - start + 1))
            else
                length=$((start - end + 1))
            fi

            gene_sequence_upper=$(echo "$gene_sequence" | tr '[:lower:]' '[:upper:]')
            A_COUNT=$(echo "$gene_sequence_upper" | grep -o "A" | wc -l)
            T_COUNT=$(echo "$gene_sequence_upper" | grep -o "T" | wc -l)
            G_COUNT=$(echo "$gene_sequence_upper" | grep -o "G" | wc -l)
            C_COUNT=$(echo "$gene_sequence_upper" | grep -o "C" | wc -l)

            TOTAL_COUNT=$((A_COUNT + T_COUNT + G_COUNT + C_COUNT))
            GC_COUNT=$((G_COUNT + C_COUNT))
            AT_COUNT=$((A_COUNT + T_COUNT))

            if [[ $TOTAL_COUNT -gt 0 ]]; then
                GC_PERCENTAGE=$(awk "BEGIN {printf \"%.2f\", ($GC_COUNT / $TOTAL_COUNT) * 100}")
                AT_PERCENTAGE=$(awk "BEGIN {printf \"%.2f\", ($AT_COUNT / $TOTAL_COUNT) * 100}")
            else
                GC_PERCENTAGE="0.00"
                AT_PERCENTAGE="0.00"
            fi

            echo -e "${locus_tag:-none}\t${gene:-none}\t${protein:-none}\t${location:-none}\t${length:-none}\t${gene_sequence:-none}\t$A_COUNT\t$T_COUNT\t$G_COUNT\t$C_COUNT\t$GC_PERCENTAGE%\t$AT_PERCENTAGE%" >> "$output_file"
        fi
    fi

    echo "Finished processing $input_file"
done

echo "All files processed."
