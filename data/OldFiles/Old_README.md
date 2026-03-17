

All the data collected consisted, initially, only of genome metadata (accession number, organism name, taxonomy, etc.); the genome itself was not retrieved at this stage. *To facilitate analysis, the tables with the genome metadata were separated into Bacteria and Archaea.*

To search for thermophilic belonging to this two supracited Domains two plaforms were used: NCBI (National Center for Biotechnology Information) and GTDB (Genome Taxonomy Database).

Links to the website
- NCBI: <https://www.ncbi.nlm.nih.gov/datasets/genome/> 
- GTDB: <https://gtdb.ecogenomic.org/>

On NCBI, we searched for thermophiles from the Bacteria and Archaea domains using first method (Literature) and on GTDB we search the genomes using the second method "Isolation Source", since only GTDB allow to search for genomes using the Isolation Source as a keyword

2.1) Retrieving data using Literature

For each taxon in the archives, we searched for the names of the organisms (using the NCBI search bars) and downloaded all **Assembled Genomes** that matched the search.

To download the Assembly, we use the option available of "Downloading all Assemblies" and then download the tables in TSV format

After that we got a table for every single bacteria and archaea taxon, this resulting tables were merged by category (Source and Domain), yielding two consolidated datasets:

1) "NCBI-Lit-Bacteria.tsv"
2) "NCBI-Lit-Archaea.tsv"

**This search was done it on: Month day, year**

2.2) Retrieving data using Isolation Source

To find the thermophilic organisms using the Isolation Source we used the following keywords in GTDB's Advanced Search option:

(Isolation Source" CONTAINS "volcano") OR ("Isolation Source" CONTAINS "hot") OR ("Isolation Source" CONTAINS "thermal") OR ("Isolation Source"
CONTAINS "hydrothermal") OR ("Isolation Source" CONTAINS "thermo")).

After the data was downloaded, the resulting tables were merged, yielding two more TSV tables: 

3) "GTDB-Iso-Bacteria.tsv"
4) "GTDB-Iso-Archaea.tsv"

**This search was done it on: Month day, year**

**3) Merging the GTDB's tables and NCBI's tables**

NCBI is the most up-to-date platform in terms of the number and version of its assemblies, and GTDB, the other platform, updates its genomes using information from NCBI. However, only GTDB allows the user to search for genomes using the Isolation Source and not just the Organism Name or the Accession Number of the Assembly, thus expanding the search possibilities.

For this reason, we use the NCBI tables as a "base" and supplement them with genomes from the GTDB table, using the Accession Number of the Assembly as a key to ensure uniqueness in the table. 


USING THE DATASET command-line tool from NBCI
######
1) To download genomes or genomes metadata
Command to download the isolation-source from NCBI using the Assembly Acession as the search key:

"datasets summary genome accession GCF_001610955.1 --as-json-lines | dataformat tsv genome --fields accession,assminfo-biosample-isolation-source | table"
######
2) To search for genomes using the taxonomic name or ID (Acession number of the Assembly)

Note: datasets only recognized valid taxonomic name or ID, if you try to write the prefix of a name, the program will simply doesnt work and there will be no error message
######

Since GTDB is updated using data from NCBI genomes and the last update was done it in September 2024, this means that NCBI is more up-to-date hence is a more reliable and complete in terms of number genomes and hence we choose it as the base-table

Howeveralthough GTDB is more robust in terms of taxonomy

With the table complete, the next step was to merge the tables from NCBI and GTDB into just two, one for Bacteria and another for Archaea. To do that we need to guarentee that the columns names were the same, so that would allow us to concatenate the records correctly.



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
