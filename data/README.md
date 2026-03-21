## Methodology

**1) Finding the thermophilic taxa of bacteria and archaea**

Before searching for the genomes of thermophilic organisms in the database, we first needed to identify which ones are thermophilic. 

To do this, we needed to find a reference (in the database, in articles, etc.) that confirms this information. Unfortunately, platforms (such as NCBI Datasets) do not have a label indicating whether the assembly belongs to a thermophilic organism or not. 

The solution to find this info is to use Sources in the Literature or the Isolation Source, available in the metadata, which can indicate whether the organism's habitat is characterized by extreme temperatures or not

Note: Since the Bacteria and Archaea domains are the most representative in terms of thermophilic organisms, we limited our search to these two domains.

**1.1) Using Literature**

Articles [1-37] were used to find the taxa (species, genus, family, order, class and phylum) of different bacterias and archaeas that were characterized as thermophilic.

To avoid false thermophilic organisms, we tried to select only those taxa that were almost exclusively thermophilic and well characterized

After doing the search, we made a list of thermophilic organisms names *(available in "/data/SearchingForThermophiles/LiteratureNamesSearch")*.

To facilitate the search for genomes in the next stages, we use the command-line tool *Taxonkit* (version: v0.20.0) [39] to determine the rank of each name and to find the TaxID, which we used later.

#COMAND
jpcastrodarocha$ taxonkit name2taxid -r <FILE> 
- name2taxid: reads a column with the taxon name and create a new column with the taxid 
- flag -r: include another column with the taxonomic rank of the organism (species, genus, family, order, class or phylum)

After that, we had two files with the taxonomic ranks, names and taxid *(available in "data/SearchingForThermophiles/LiteratureNamesSearch")*: 

Note: NCBI Taxonomy database accessed on February 13, 2026 [40] to download the **taxdump** files used by the command-line tool *Taxonkit*.

**1.2) Using the Isolation Source**

The Isolation Source can be found in the "Sample Details" section in the Assembly Metadata on NCBI Genome Database website <https://www.ncbi.nlm.nih.gov/datasets/genome/>

To found which ones are from thermophilic bacteria or archaeas we use a list of keywords/prefix of common "thermophilic sources" and, to avoid catching false positives, a list of "non-thermophilic sources" *(available in "data/SearchingForThermophiles/IsolationSourceSearch")*

@@@@
Note: After the first search for the assembly metadata, this list was updated to avoid others false positives terms founded in the metadata (like food, medicine, soil related things)
@@@@

**2) Searching for the Assembly Metadata**

After making the list of thermophilic names and isolation source names, we had to use this terms to search for the Assembly Metadata

Since the NCBI Genome websearch doesn't offer the option to use the Isolation Source as a key to search for the Metadata, we opt to use the NCBI CLI (Command Line Interface) tools [41]:

1) *datasets* (version - 18.19.0) - to search and download the genome metadata in a JSON file
2) *dataformat* (version - 18.16.0) - used to convert the JSON file of datasets into a TSV and to filter the metadata fields

This metadata were firstly used to characterize the thermophilic organisms and later to find and install the Complete Genomes of each one.

The metadata fields searched were: 

# General
* Acession Number of the Assembly
* Organism Name
* Organism Tax-ID
* Organism Strain
* Organism Isolate
* Organism Infraspecific Strain
* Release Date of the Assembly

# Sample Location and Collection
* Isolation Source
* Geographic location of the Sample
* GPS Coordinates of the Sample
* Ecotype 
* Collection Date

# Sample Characteristics 
* Food safety classification of pathogens
* Host of the organism
* Host disease caused by organism
* Isolate name in BioSample record

# Assembly Details
* Atypical signal
* Atypical details
* Assembly type 

The complete list of metadata fields used to filter the metadata in the *dataformat* command is *available in data/SearchingForThermophiles*.

Note: The Assembly type indicate if it's a MAG (Metagenome-Assembled Genome) or not

@@@@
BUSCA SEPARADA

* Sample info - Attribute Name
* Sample info - Attribute Value
assminfo-biosample-attribute-name
assminfo-biosample-attribute-value 


The last two fields were important because they could contain information about the cultivation temperature and if this temperature is higher than 45°C, then the organism is thermophilic

@@@@

**2.1) Search using the taxa from Literature**

Using the previous mentioned files containing the TaxID from thermophilic bacterias and archaeas, we search and download all the metadata for the Assemblies related to these TaxIDs.

#COMAND
datasets summary genome taxon --as-json-lines --inputfile <TaxID File> | datasets tsv genome --elide-header <OPTIONAL> --fields Field1,Field2,Field3,... 

datasets:
- summary: downloading only the Assemnly Metadata
- genome: ... from the genome
- taxon: using the taxon (taxon name or taxid) as the key search
- flag --as-json-lines: force the datasets command to separate each Assembly in a different line (default: all the Assemblies in the same line)
- flag --inputfile: make the datasets command read from a file instead of reading the positional argument

dataformat:
- tsv: transform the JSON file in a TSV file
- genome: ... from the genome
- flag --elide-header: remove the HEADER from the file
- flag --fields: list of all the required metadata fields

SCRIPT used for the search and download the metadata using the TaxID:
*scripts/FetchMetadataByTaxID.sh*

#COMAND (executed on March 13, 2026)
$ ./FetchMetadataByTaxID.sh <TaxID File> <Name of Output File>

As the result, we get two new files with the genome metadata of the Bacteria and Archaea Domain, this result files were transter to:
*data/DataTables*

**2.2) Search using the Isolation Source**

To download metadata using the Isolation Source,we first need to retrieve all Bacteria and Archaea metadata from NCBI, as the *datasets* tool does not allow filtered searches using the Isolation Source as a key.

But there are more than *2 million* assemblies from Bacteria and more than *30 thousand* from Archaea available in NCBI, and to retrieve all this data a simples command like:

$ datasets summary genome taxon "Bacteria" 

Wouldn't work, because the NCBI server would time out due to the sheer size of the request. So the solution is to break the request in smaller parts to avoid this timeout error

This "break" in the request was made using the flags: --released-before and --released-after, which force the *datasets* command to retrieve metadata only from a specific time interval.

However, a simple division by years was not sufficient, because due to the arrival of next-generation sequencing (NGS), a large part of the deposited assemblies are concentrated in the last 5-6 years, thus the same timeout error occurs when trying to retrieve data from those years.

Therefore, the final solution we found was, in addition to dividing the request by year, to divide each year into even more dates, so that we could then make the request to the server without receiving the error.

SCRIPT used to request all the metadata from Bacteria and Archaea Domain:
*scripts/RequestingMetadataDomains.sh*

Note: Since we want to use this data only to find which assemblies have a isolation source related to thermophilic enviroment we filter the request so that only the Acession Number and the Isolation Source in the final TSV file

**2.2) Using the Thermoplic and Non-Thermophilic keys to filter the data**

After downloading all the data from both domains, we use the list of thermophilic and non-thermophilic keywords *(available in "data/SearchingForThermophiles/IsolationSourceSearch")* to find only the assemblies from extreme enviroment and to remove those that were false positives, respectively

SCRIPT used to filter the entries:
*scripts/FilteringMetadataUsingIS.sh*

The problem was that this first lists of keywords that we had were not so robust, because many of the Isolation Source in the entries had:

Food-related names:
- hot pepper, hot chicken (keyword: "hot")

Medical-related names:
- thermometer, vapotherm (keyword: "therm")

Non-extreme enviroment:
soil, landsoil, topsoil (keyword: "oil")

To identify all this erroneous results and correct them, we used another script that read all the Isolation Source from the complete TSV file (with all the assemblies from both domains) and find it the whole words that contains the keywords and the neighbour words. The results can be founded at *(available in "scripts/ResultFiles/SearchingMatchingKeywords_IS.sh")*

SCRIPT to find which words the keywords matched:
*scripts/SearchingMatchingKeywords_IS.sh*

After that, we update the list of thermoplic and non-thermophilic keywords, so that all this false positive were removed and the only assemblies that stays were specifically extreme enviroments, such as "hot spring, hydrothermal vent, volcano site"

With the updated list we execute the script for the second time *(date: ?)* and filter the data from the Bacteria and Archaea. 

Finally, to obtain the others metadata fields (we only had the Accession Number and Isolation Source at this point), we use the Accession Numbers to request for the Metadata.

SCRIPT used for the search and download the metadata using the Accession:
*scripts/FetchMetadataByAccession.sh*

The result file was then transfered to:
*data/DataTables*

**3) Concatenating the genome metadata and Cleaning the data

After downloanding the metadata using both methods (Literature and Isolation Source) we

1 - Concatenate both files into one (for each Domain - Bacteria and Archaea)
2 - Sort the entries according to the first column (Accession Number)
3 - Remove any duplicate sequences (same Accession Number)
4 - Remove all the sequences starting with GCF (since there is always a correspondent GCA Assembly, we only need the GCA)

Note: In all the scripts mentioned above, there is already a step to clean the data and remove duplicate assemblies. Deduplication only applies to assemblies that are repeated between the two methods (Literature and Isolation Source).

SCRIPT used for the concatenate and clean the data:
*scripts/FetchMetadataByAccession.sh*

#Comand (executed on February 16, 2026)
$ ./ScriptWithNoName4.sh GenomeMetadataFromLit_Arc.tsv GenomeMetadataFromIS_Arc.tsv
$ ./ScriptWithNoName4.sh GenomeMetadataFromLit_Bac.tsv GenomeMetadataFromIS_Bac.tsv

The resulting files were:
- GenomeMetadataMerged_Arc.tsv
- GenomeMetadataMerged_Bac.tsv

**4) Creating a Directory Structure for Taxonomy**

The next step was to create a directory hierarchy using the taxonomy of each organism to organize the genomes and metadata in a way that each taxon is separated and the child taxa of a certain phylum, for example, are inside the phylum directory

Note: We use only the classical taxonomy ranks - Domain, Kingdom, Phylum, Class, Order, Family, Genus, Species

#Directory Hierarchy

[Domain]/                      
    └── [Kingdom]/                 
        └── [Phylum]/               
            └── [Class]/            
                └── [Order]/        
                    └── [Family]/   
                        └── [Genus]/
                            └── [Species]/
								├── [GenomeFile]/ 
								│   ├── genome.fna
								│   ├── protein.faa
								│   └── annotation.gff
								└── metadata_species.json

To do that the first step was to pick all the TaxID from the Assemblies founded and create a new file with the complete taxonomy of that organism

#COMAND

taxonkit reformat2 \
    -I 3 \
    -f "{domain|superkingdom};{phylum};{class};{order};{family};{genus};{species};{subspecies|strain|no rank}" \
    -r "Unclassified" \
    -t \
    --no-ranks "clade" \
    <(tail -n +2 <Input File> | cut -f1,2,3) | \
tr ';' '\t' | \
csvtk add-header -t -n "Accession,Organism_Name,TaxID_Original,Domain,Phylum,Class,Order,Family,Genus,Species,Subspecies,TaxID_Domain,TaxID_Phylum,TaxID_Class,TaxID_Order,TaxID_Family,TaxID_Genus,TaxID_Species,TaxID_Subspecies" > <Output File>

---------------------

# Reference list

[1] Merino N, et al. Crit. Rev. Microbiol. 2026. https://doi.org/10.1080/1040841X.2026.2614431
[2] Adam PS, et al. Nat. Commun. 2024. https://doi.org/10.1038/s41467-024-48498-5
[3] Sahoo RK, et al. J. Basic Microbiol. 2021. https://doi.org/10.1002/jobm.202100529
[4] Thomas C, et al. mSystems. 2022. https://doi.org/10.1128/msystems.00317-22
[5] Gidtiyanuek C, et al. Arch. Microbiol. 2024. https://doi.org/10.1007/s00203-024-03981-x
[6] Liu Y, et al. Food Sci. Nutr. 2024. https://doi.org/10.1002/fsn3.4540
[7] Singh A, et al. J. Egypt. Soc. Parasitol. 2024. https://doi.org/10.1007/s43393-024-00275-7
[8]  Blumer-Schuette SE, et al. Front. Chem. 2014. https://doi.org/10.3389/fchem.2014.00066 
[9]  Wiegel J, et al. Genome Announc. 2017. https://doi.org/10.1128/genomea.00367-17 
[10] Lawson PA, et al. Genome Announc. 2018. https://doi.org/10.1128/genomeA.00338-18 
[11] Shao X, et al. Appl. Environ. Microbiol. 2019. https://doi.org/10.1128/AEM.00802-19 
[12] Wiegel J, et al. J. Bacteriol. 1982. https://doi.org/10.1128/jb.151.1.507-509.1982 
[13] Sleytr UB, et al. Appl. Environ. Microbiol. 1991. https://doi.org/10.1128/AEM.57.2.455-462.1991 
[14] Shao X, et al. Appl. Environ. Microbiol. 2011. https://doi.org/10.1128/AEM.00402-10 
[15] Hudson JA, et al. Int. J. Syst. Bacteriol. 1989. https://doi.org/10.1099/00207713-39-4-485 
[16] Albuquerque L, et al. Int. J. Syst. Evol. Microbiol. 2011. https://doi.org/10.1099/ijs.0.028852-0 
[17] Cheng J, et al. Int. J. Syst. Evol. Microbiol. 2015. https://doi.org/10.1099/ijsem.0.000435 
[18] Kämpfer P, et al. Int. J. Syst. Evol. Microbiol. 2012. https://doi.org/10.1099/ijs.0.042481-0 
[19] Denger K, et al. Int. J. Syst. Bacteriol. 2002. https://doi.org/10.1099/00207713-52-1-173 
[20] Jean WD, et al. Int. J. Syst. Evol. Microbiol. 2009. https://doi.org/10.1099/ijs.0.009407-0 
[21] Albuquerque L, et al. Int. J. Syst. Evol. Microbiol. 2018. https://doi.org/10.1099/ijsem.0.002573 
[22] Ward NL, et al. Appl. Environ. Microbiol. 2023. https://doi.org/10.1128/aem.01756-23 
[23] Jung J, et al. Microb. Ecol. 2024. https://doi.org/10.1007/s00248-024-02482-0 
[24] Martinez-Garcia M, et al. Nat. Commun. 2024. https://doi.org/10.1038/s41467-024-53784-3 
[25] Karube I, et al. Int. J. Syst. Evol. Microbiol. 2003. https://doi.org/10.1099/ijs.0.050369-0 
[26] Ohno M, et al. Int. J. Syst. Bacteriol. 2000. https://doi.org/10.1099/00207713-50-5-1829 
[27] Sokolova TG, et al. Extremophiles. 2007. https://doi.org/10.1007/s00792-006-0022-5 
[28] Khalil A, et al. Microbiol. Resour. Announc. 2020. https://doi.org/10.1128/mra.00224-20 
[29] Miñana-Galbis D, et al. Syst. Appl. Microbiol. 2017. https://doi.org/10.1016/j.syapm.2017.03.004 
[30] Arshad A, et al. Syst. Appl. Microbiol. 2024. https://doi.org/10.1016/j.syapm.2024.126561 
[31] Slobodkina GB, et al. Int. J. Syst. Evol. Microbiol. 2016. https://doi.org/10.1099/ijsem.0.000767 
[32] Slobodkina GB, et al. bioRxiv. 2017. https://doi.org/10.1101/179903 
[33] Kovaleva OL, et al. Int. J. Syst. Evol. Microbiol. 2015. https://doi.org/10.1099/ijs.0.070151-0 
[34] Baldrian P, et al. Syst. Appl. Microbiol. 2021. https://doi.org/10.1016/j.syapm.2020.126157 
[35] Dahle H, et al. ISME J. 2018. https://doi.org/10.1038/s41396-018-0187-9 
[36] Hols P, et al. Appl. Microbiol. 2025. https://doi.org/10.3390/applmicrobiol5040101 
[37] Dahle H, et al. J. Clin. Microbiol. 2006. https://doi.org/10.1128/JCM.00568-06

[38] Schoch CL, et al. NCBI Taxonomy: a comprehensive update on curation, resources and tools. Database (Oxford). 2020: baaa062. PubMed: 32761142 PMC: PMC7408187.

taxonkit
[39] Shen W, Ren H. TaxonKit: a practical and efficient NCBI taxonomy toolkit. J. Genet. Genomics. 2021;48(9):844-850. doi:10.1016/j.jgg.2021.03.006.

taxdump files
[40] NCBI Taxonomy Database. https://ftp.ncbi.nih.gov/pub/taxonomy/. Accessed Feb 13, 2026

datasets and dataformat
[41] O'Leary, N.A., Cox, E., Holmes, J.B., et al. Exploring and retrieving sequence and metadata for species across the tree of life with NCBI Datasets. Sci Data 11, 732 (2024). doi: 10.1038/s41597-024-03571-y

Data Source

| Tool / Resource | Version | Access/Download Date |
| :--- | :--- | :--- |
| **TaxonKit** | v0.20.0 | 2026-02-13 |
| **NCBI taxdump** | N/A | 2026-03-14 |
| **datasets** | 18.16.0 | 2026-02-16 |
| **dataformat** | 18.16.0 | 2026-02-16 |


@@@@ 
Why you did not use this complete list in the others steps of the search? You have all the data you need locally, why not use that to search using the literature and others things?

Because what do I have locally is a simple plain text file and to fing the entire records/entrys in this type of file, the search algorithms have to read the entire file, and this search becomes to much computational demand

Comparing to the search done in the database on the server, since this type of DB normally use Database Management Systems, the search becomes much faster, since there are "links" between each column, so the search and retrieving process of the value requested in the query becomes much faster and efficient
@@@@


@@@@
O objetivo aqui é ter uma hierarquia de diretorios (comecando de Filo e indo ate Especie) para facilitar o acesso as genomas, como tbm para facilitar o estudo do genoma de um taxon especifico, como uma classe ou um filo
@@@@