###Methodology

**1) Finding the thermophilic taxons of bacteria and archaea**

Before searching for the genomes of thermophilic organisms in the database, we first needed to identify which ones are thermophilic. To do 
this, we needed to find a reference (in the database, in articles, etc.) that confirms this information. Unfortunately, databases (such as GenBank) do not have a label indicating whether the genome belongs to a thermophilic organism or not. The solution to find this info is to use sources in the literature or the Isolation source in the metadatas, which can indicate whether the organism's habitat is characterized by extreme temperatures or not

1.1) Using Literature

Articles [1-7] were used to find the taxons (species, genus, family, order, class and phylum) of different bacteria and archaeas that were thermophilic.

After doing the search, we made a list of thermophilic organisms names and put this names into the files "AnalyzedTaxonsArq_Sorted.txt" and "AnalyzedTaxonsBac_Sorted.txt" (available in this same directory).

Note: For genus that have most of the members being thermophilic, the whole genus was considered for the search, not just the species cited. This guarentee that all possible thermophilic members are included, even if it means that some of them will be false positive

1.2) Using the Isolation Source

The Isolation Source is the place where the sample used for sequencing was collected, if its a extreme place, like hot springs and hydrothermal vent, there is a high probability that the organisms living there are thermophilic.

**2) Searching for the genomes (metadata)**

All the data collected consisted, initially, only of genome metadata (accession number, organism name, taxonomy, etc.); the genome itself was not retrieved at this stage. *To facilitate analysis, the tables with the genome metadata were separated into Bacteria and Archaea.*

To search for thermophilic belonging to this two supracited Domains two plaforms were used: NCBI (National Center for Biotechnology Information) and GTDB (Genome Taxonomy Database).

Links to the website
- NCBI: <https://www.ncbi.nlm.nih.gov/datasets/genome/> 
- GTDB: <https://gtdb.ecogenomic.org/>

On both platforms, we searched for thermophiles from the Bacteria and Archaea domains using the 2 methods mentioned: Literature and Isolation Source

2.1) Retrieving data using Literature

For each taxon in the archives, we searched for the names of the organisms (using the NCBI and GTDB search bars) and downloaded all **Assembled Genomes** that matched the search.

To download the Assembly, we use the option available on both platforms (NCBI and GTDB) of "Downloading all Assemblies" and tables download the tabes in TSV format

After that we got a table for every single bacteria and archaea taxon, this resulting tables were merged by category (Source and Domain), yielding four consolidated datasets:

1) NCBI - Bacteria 
2) NCBI - Archaea
3) GTDB - Bacteria
4) GTDB - Archaea

# This search was done it on: Month day, year

2.2) Retrieving data using Isolation Source

To find the thermophilic organisms using the Isolation Source we used the following keywords in GTDB's Advanced Search option:

(Isolation Source" CONTAINS "volcano") OR ("Isolation Source" CONTAINS "hot") OR ("Isolation Source" CONTAINS "thermal") OR ("Isolation Source"
CONTAINS "hydrothermal") OR ("Isolation Source" CONTAINS "thermo")).

Note: Only GTDB contained metadata about the Isolation Source. 

After the data was downloaded, the resulting tables were merged, yielding two more TSV tables: 

5) GTDB (using I.S.) - Bacteria
6) GTDB (using I.S.) - Archaea

This 2 tables were then concatenated with the corresponding GTDB tables, resulting in 4 tables in the end

#This search was done it on: September 29, 2025

**3) Formatting the data and merging the tables**

With the table complete, the next step was to merge the tables from NCBI and GTDB into just two, one for Bacteria and another for Archaea. To do that we need to guarentee that the columns names were the same, so that would allow us to concatenate the records correctly.

Since GTDB is updated using data from NCBI genomes and the last update was done it in September 2024, this means that NCBI is more up-to-date hence is a more reliable and complete repository in terms of number genomes, although GTDB is more robust in terms of taxonomy

In that regard, we use NCBI's genomes to build the "base table" and then complete this table with the Taxonomy and Isolation Source provided by GTDB

**3.1) Formating the columns to merge

To merge the tables, we first need to find a way to match the rows. The solution to that is to use the **Assembly Acession** code that identify each genome submitted, using this is possible to find the corresponding genome of GTDB in NCBI and then add the GTDB metadata to the NCBI table

However, some of genomes have the Assembly Acession beginning with GCA and other ones with GCF. All genomes have a GCA (GenBank Assembly) code, because all of them were deposited in the repository GenBank, but the high-quality ones (lower contamination and high completeness) have **also** been deposited in the repository RefSeq and get a "GCF" (RefSeq Assembly) code at the start. Because of that, we change all "GCF" in the Assembly Acession (of both tables - NCBI and GTDB) to "GCA"

After that, we execute the shell script (available in "scripts/SubstituteGCFtoGCA.sh") in all 6 tables and other shell script () to add, to the NCBI table, 3 new columns (NCBI Taxonomy, GTDB Taxonomy and Isolation Source) and add the content in GTDB table to the NCBI table, resulting in two tables:

1) NCBI_MergedTable - Bacteria
2) NCBI_MergedTable - Archaea

**3.2) Deleting duplicates**

The next step was to delete any duplicate genomes, to do that we again use the Assembly Acession as the identifier and use the shell script () to sort the colunms using the Assembly Acession as the key and then delete any replicates

**4) Checking the taxonomy**

After collecting the **Acession Number** for the genome, the names of the thermophilic organisms and organizing the data in tables, the 
taxonomy of each organism needed to be checked.

To do that we use NCBI's Taxonomy Browser [8] to check the different taxonomy levels. The taxonomy was standardized to only have 7 ranks 
(species - domain), non-standard ranks were removed

Link to the website 
- NCBI Taxonomy Browser: <https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi>

# This search was done it on: Month day, year

Note: Although the genome metadata available in GTDB already contains the taxonomy, we prefer to check the NCBI, which contains more 
up-to-date data, since GTDB updates its information based on NCBI data.

---------------------

Reference list

[1] Merino N, et al. Crit. Rev. Microbiol. 2026. https://doi.org/10.1080/1040841X.2026.2614431

[2] Adam PS, et al. Nat. Commun. 2024. https://doi.org/10.1038/s41467-024-48498-5

[3] Sahoo RK, et al. J. Basic Microbiol. 2021. https://doi.org/10.1002/jobm.202100529

[4] Thomas C, et al. mSystems. 2022. https://doi.org/10.1128/msystems.00317-22

[5] Gidtiyanuek C, et al. Arch. Microbiol. 2024. https://doi.org/10.1007/s00203-024-03981-x

[6] Liu Y, et al. Food Sci. Nutr. 2024. https://doi.org/10.1002/fsn3.4540

[7] Singh A, et al. J. Egypt. Soc. Parasitol. 2024. https://doi.org/10.1007/s43393-024-00275-7

[8] Schoch CL, et al. NCBI Taxonomy: a comprehensive update on curation, resources and tools. Database (Oxford). 2020: baaa062. PubMed: 
32761142 PMC: PMC7408187.
