\# Genomic Mining for the Prediction of Laccases from Thermophilic Organisms



\## Introduction

This project aims to identify novel laccase enzymes within thermophilic genomic data. Laccases (EC 1.10.3.2) are multicopper oxidases with significant industrial potential due to their ability to oxidize a wide range of substrates. The multicopper oxidases are known for their versatile industrial applications in textile bleaching, paper pulping, bioremediation, and food processing \[1,2]. While these enzymes are essential for eco-friendly catalysis, standard mesophilic variants often lack the stability required for harsh industrial conditions.

---



\## Methodology



\##############

Elaborate on the fact that you just used Bacteria and Archaea genomes

\###########



1\. \*\*Database Mining:\*\* Identify thermophilic organisms with sequenced genomes on databases like NCBI or GTDB.



To identify what organisms were thermophilic in the genomes database 2 approaches were used: 



1.1 Isolation Source

In GTDB is possible to use the isolation source to find the genomes, the idea used here was to put places (or just keywords) that are known for being the habit of thermophilic organisms.

Words: "therm-", "hydrothermal", "vulcanic", "hot"



1.2 Litetature

We search in a lot of papers (referenced below) the names of thermophilic taxons (species, genus, family, order, class, phylum) and them search this names in both NCBI and GTDB database.


2\. \*\*Dataset Construction:\*\* Construct a dataset of all thermophilic organisms founded, including the taxonomy of each one



2.1 Retrieving Data from Databases



2.2 Formatting the columns



2.3 Merging Data from NCBI and GTDB



2.4 Deleting replicate genomes (same Assembly Acession)





3\. \*\*Taxonomic Analysis:\*\* Calculate the representativity of each taxon to identify diversity gaps.



3.1 Retrieving the taxonomy of the genomes from NCBI



3.2 Creating a file with a summary of all taxon



4\. \*\*Genome Acquisition and Curation:\*\*

&nbsp;   \* \*\*5.1.\*\* Assess genome replicates (strains of the same species).

&nbsp;   \* \*\*5.2.\*\* Delete replicates using ANI (Average Nucleotide Identity) thresholds.

&nbsp;   \* \*\*5.3.\*\* Assess genome quality (completeness and contamination) using \*\*CheckM\*\*.

&nbsp;   \* \*\*5.4.\*\* Standardize annotation using \*\*Prokka\*\* or \*\*Bakta\*\*.

5\. \*\*Functional Mining:\*\* Use \*\*HMMER\*\* to search for specific Cu-oxidase domains (Pfam: PF00394, PF07731, PF07732).

6\. \*\*In silico Characterization:\*\* Verify conserved copper-binding ligands and predict subcellular localization (SignalP).

7\. \*\*Phylogenetic Reconstruction:\*\* Build a tree to visualize the relationship between predicted and characterized laccases.



---



\## Reference List



\[1] Sutaoney, P., Sinha, S., \& Rai, S. N. (2024). An Overview on Laccases: Production \& Industrial Applications. \*Scope\*, 13(3), 1678-1691. https://doi.org/10.5281/zenodo.10424561 (Accessed: 27 Jan. 2026).



\[2] Akram, F., \& Ashraf, S. (2023). Eminent Industrial and Biotechnological Applications of Laccases from Bacterial Source: a Current Overview. \*Appl. Microbiol. Biotechnol.\*, 107(1), 1-15. https://doi.org/10.1007/s00253-022-12304-y (Accessed: 27 Jan. 2026).



\[3] Nnolim, N. E., \& Okoh, A. I. (2025). Bacillus sp. GLN Laccase Characterization: Industry and Biotechnology Implications. \*Appl. Sci.\*, 15(9), 5144. https://doi.org/10.3390/app15095144 (Accessed: 27 Jan. 2026).

