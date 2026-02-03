# Genomic Mining for the Prediction of Laccases from Thermophilic Organisms

## Introduction
This project aims to identify novel laccase enzymes within thermophilic genomic data, specifically from 
thermophilic bacteria and archaea. Laccases (EC 1.10.3.2) are multicopper oxidases with significant industrial 
potential due to their ability to oxidize a wide range of substrates. The multicopper oxidases are known for 
their versatile industrial applications in textile bleaching, paper pulping, bioremediation, and food processing 
[1,2]. While these enzymes are essential for eco-friendly catalysis, standard mesophilic enzymes often lack the 
stability required for harsh industrial conditions. 

Furthermore, the direct production of these enzymes from thermophilic organisms can be difficult, because most 
of them live in extreme conditions (temperature, pH, pressure and salinity) and often in a well-structured 
community, which makes isolation and cultivation in the laboratory difficult [4]. Thus, an in silico prospecting 
approach utilizing genome mining provides a robust alternative to traditional culture-dependent methods.

---
## Methodology

1. **Database Mining:** Identify thermophilic organisms with sequenced genomes on databases like NCBI or GTDB. 
To identify what organisms were thermophilic in the genomes database 2 approaches were used:

1.1 Isolation Source In GTDB is possible to use the isolation source to find the genomes, the idea used here was 
to put places (or just keywords) that are known for being the habitat of thermophilic organisms. Words: 
"therm-", "hydrothermal", "vulcanic", "hot"

1.2 Litetature We search in a lot of papers (referenced below) the taxons of thermophilic bacteria and archaea 
and them search this names in both NCBI and GTDB database.

2. **Dataset Construction:** Construct a dataset of all thermophilic organisms founded, including the taxonomy 
of each one

2.1 Retrieving Data from Databases To retrieve the data, we open the NCBI and GTDB webpage 
(https://www.ncbi.nlm.nih.gov/datasets/genome/ and https://gtdb.ecogenomic.org/advanced) and download the 
genome/assembly as TSV format in NCBI and as CSV format in GTDB, using the built-in option of both sites

2.2.1 Structure of the assembly table - GTDB The assembly from GTDB contains information about: . Assembly 
Accession . Organism Name . NCBI Taxonomy . GTDB Taxonomy . GTDB Representative of Species . GTDB Type Material 
. Isolation Source

2.2.2 Structure of the assembly table - NCBI The assembly from NCBI contains informaation about: . Assembly 
Accession . Assembly Name . Organism Name . Organism Infraspecific Names Breed . Organism Infraspecific Names 
Strain . Organism Infraspecific Names Cultivar . Organism Infraspecific Names Ecotype . Organism Infraspecific 
Names Isolate . Organism Infraspecific Names Sex . Annotation Name . Assembly Level . Assembly Release Date . 
WGS project accession . Assembly Stats Number of Scaffolds

2.3 Formatting the columns The Assembly Acession column refers to the identifier assigned to a specific version 
of a genome assembly and this "barcode" for the genome can be from either GCA (GenBank Contex Assembly) or GCF 
(GenBank Contex FrefSeq), but all genomes that are in GCF, the curated database, are in GCA too. In this 
context, to facilitate the identification of the genomes we change the identifiers to be all with "GCA" as a 
prefix

#####################
Comentar das diferentes formas que os dados foram adquiridos - por Fonte de Isolamento e Genero Comentar que o 
genero foi pesquisado um a um e depois junto em uma grande tabela (tanto no NCBI quanto no GTDB) Comentar que 
depois dessa primeira junção a tabela de Fonte de Isolamento foi junta com o de Genero (para os dois banco de 
dados) Comentar que, ao final, a tabela do NCBI e do GTDB foram juntas para criar uma grande tabela ---- 
LEMBRANDO QUE EU DEIXEI UMA SECAO SEPARADA PARA BACTERIAS E PARA ARQUEIAS
########################

2.3 Merging Data from NCBI and GTDB We use Orange Data Mining software to merge the

2.4 Deleting replicate genomes (same Assembly Acession)

3. **Taxonomic Analysis:** Calculate the representativity of each taxon to identify diversity gaps.

3.1 Retrieving the taxonomy of the genomes from NCBI

3.2 Creating a file with a summary of all taxon

4. **Genome Acquisition and Curation:**   * **5.1.** Assess genome replicates (strains of the same species).   * 
**5.2.** Delete replicates using ANI (Average Nucleotide Identity) thresholds.   * **5.3.** Assess genome 
quality (completeness and contamination) using **CheckM**.   * **5.4.** Standardize annotation using **Prokka** 
or **Bakta**.

5. **Functional Mining:** Use **HMMER** to search for specific Cu-oxidase domains (Pfam: PF00394, PF07731, 
PF07732).

6. **In silico Characterization:** Verify conserved copper-binding ligands and predict subcellular localization 
(SignalP).

7. **Phylogenetic Reconstruction:** Build a tree to visualize the relationship between predicted and 
characterized laccases.

---

## Reference List

[1] Sutaoney, P., Sinha, S., & Rai, S. N. (2024). An Overview on Laccases: Production & Industrial Applications. 
*Scope*, 13(3), 1678-1691. https://doi.org/10.5281/zenodo.10424561 (Accessed: 27 Jan. 2026).

[2] Akram, F., & Ashraf, S. (2023). Eminent Industrial and Biotechnological Applications of Laccases from 
Bacterial Source: a Current Overview. *Appl. Microbiol. Biotechnol.*, 107(1), 1-15. 
https://doi.org/10.1007/s00253-022-12304-y (Accessed: 27 Jan. 2026).

[3] Nnolim, N. E., & Okoh, A. I. (2025). Bacillus sp. GLN Laccase Characterization: Industry and Biotechnology 
Implications. *Appl. Sci.*, 15(9), 5144. https://doi.org/10.3390/app15095144 (Accessed: 27 Jan. 2026).

[4] Rafiq M, Hassan N, Rehman M, Hayat M, Nadeem G, Hassan F, Iqbal N, Ali H, Zada S, Kang Y, Sajjad W, Jamal M. 
Challenges and Approaches of Culturing the Unculturable Archaea. *Biology (Basel)*. 2023 Dec 7;12(12):1499. doi: 
10.3390/biology12121499. PMID: 38132325; PMCID: PMC10740628.
