This repository contains three Bash scripts for an upcoming study (citation pending):

1.	amrlist.sh (used for Fig. 1a)
	-	Reads a list of antibiotics from amrlist_used_in_fig1a.txt.
	-	Prerequisite: Run AMRFinder (v4.0.3 was used in this study) on each whole-genome sequence and place the resulting .txt files in the amrfinder_results/ directory.
	-	Prompts you to specify the data source (NCBI or PathogenWatch), extracts each isolate’s accession from its filename, checks for resistance to each antibiotic in amrlist_used_in_fig1a.txt, and outputs a tab-delimited matrix (amr_matrix.tsv) of R (resistant) or S (susceptible) calls for every isolate–antibiotic pair.

2.	RpoB_mutation_caller.sh (used for Fig. 1b)
	-	Compares each query sequence in protein/NCBI_RpoB_protein.fasta against the reference in reference/K3U68_16810.fasta (S. Typhi RpoB WT protein sequence).
	-	Reports all amino acid differences (e.g., L511P) in a two-column TSV file, labeling sequences with no changes as “WT.”

3.	ATGC_calculator.sh (used for Fig. 4d)
	-	Processes every CDS FASTA file in the wgs_cds/ directory to count A, T, G, and C and calculate AT and GC percentages.
	-	Parses locus tags, gene names, functional annotations, sequence length, and coordinates from each header line.

Examples are included; Please adjust the input/output directory variables at the top of each script for your data.

If you use these tools in your work, please cite:
[Citation pending]
