# Project Methodology

## 1_DownloadingMetadataFromNCBI

Use datasets CLI (v18.22.1) [1] from NCBI to download all the assembly metadata from Archaea domain (taxid: 2157) and Bacteria domain (taxid: 2)

## 2_FilteringMetadataFromNCBI

- Remove entries that contain GCF in the Assembly Acession Number
- Remove repeted assemblys (with the same Acession Number)
- Replace empty cells or non-valid names (ex. missing, unknown, not founded) with "NULL" for standardization

## 3_CategorizingIsolationSource

Use a list of isolation source keywords to classify the assemblies in:
1) 				Indetermined
2) (Putative) 	Thermophile or Hyperthermofile 	(ex. hot spring, thermal)
3) (Putative) 	Thermotolerant					(ex. rumen, gut)
4) (Putative) 	Non-Thermophile					(ex. cold, permfrost)

# 4_ConfirmingTheClassification

## 4-1_AddingLiteratureReference

- Map DOI links from the literature list (**<file_path>**) to their corresponding organisms.

## 4-2_AddingCultivationInfo

- Map BacDive Database entrys to correspondent organinsm in the metadata file
- Add a column to indicate if the organism is cultivable

## 5_CreatingTaxonomyTable

- Use taxonkit command (v0.20.0) [2] to provide the complete lineage of each organism
- Lineage: Domain, Phylum, Class, Order, Family, Genus, Species 

## 6_CreatingTaxonomyDirectory

Generate a hierarchical directory structure based on the retrieved taxonomy, creating nested folders for each taxonomic rank

## 7_DescriptiveStatistics

- Build a table containing the total number of each taxonomic rank for each Temperature Category and each Domain (Archaea and Bacteria)

## REFERENCES

[1] O’Leary NA, Cox E, Holmes JB, Anderson WR, Falk R, Hem V, Tsuchiya MTN, Schuler GD, Zhang X, Torcivia J, Ketter A, Breen L, Cothran J, Bajwa H, Tinne J, Meric PA, Hlavina W, Schneider VA. Exploring and retrieving sequence and metadata for species across the tree of life with NCBI Datasets. Sci Data. 2024 Jul 5;11(1):732. doi: 10.1038/s41597-024-03571-y. PMID: 38969627; PMCID: PMC11226681.

[2] Shen, W., & Ren, H. (2021). TaxonKit: A practical and efficient NCBI taxonomy toolkit. Journal of Genetics and Genomics, 48(9), 844–850. doi:10.1016/j.jgg.2021.03.006 