## Methodology

**1) Finding the thermophilic taxons of bacteria and archaea**

Before searching for the genomes of thermophilic organisms in the database, we first needed to identify which ones are thermophilic. To do this, we needed to find a reference (in the database, in articles, etc.) that confirms this information. Unfortunately, databases (such as GenBank) do not have a label indicating whether the assembly belongs to a thermophilic organism or not. The solution to find this info is to use sources in the Literature or the Isolation Source, available in the metadata, which can indicate whether the organism's habitat is characterized by extreme temperatures or not

Note: Since the Bacteria and Archaea domains are the most representative in terms of thermophilic organisms, we limited our search to these two domains.

**1.1) Using Literature**

Articles [1-7] were used to find the taxons (species, genus, family, order, class and phylum) of different bacteria and archaeas thTt were thermophilic.

After doing the search, we made a list of thermophilic organisms names. To facilitate the search for genomes in the next stages, we use the command-line tool *Taxonkit* (version: v0.20.0) [9] to determine the rank of each name and to find the TaxID, which we used later.

#COMAND
taxonkit name2taxid -r RawListArchaeas.txt | sed '1i Name\tTaxID\tTaxon' > 
ThermophilesFromLiterature_Arc.txt
taxonkit name2taxid -r RawListBacterias.txt | sed '1i Name\tTaxID\tTaxon' > ThermophilesFromLiterature_Bac.txt

After that, we had two files with the taxonomic ranks, names and taxid (available in data/SearchingForThermophiles):
- ThermophileFromLiterature_Arc.txt
- ThermophileFromLiterature_Bac.txt 

Note: NCBI Taxonomy database accessed on February 13, 2026 [8] to download the **taxdump** [10] files used by *Taxonkit*.

**1.2) Using the Isolation Source**

The Isolation Source can be found in the "Sample Details" section in the Assembly Metadata, but to found which ones are from thermophilic bacteria and archaeas we use a list of keywords/prefix of common "thermophilic sources" and, to avoid catching false positives, a list of "non-thermophilic sources"

Files (in SearchingForThermophiles directory):
- ThermophilesIsolationSource.txt
- Non-ThermophilesIsolationSource.txt

**2) Searching for the Assembly Metadata**

Before retrieving all FASTA files from the genomes, we collected assembly metadata to organize which assemblies were from thermophilic organisms. The metadata fields searched were: 

# General
* Acession Number of the Assembly
* Organism Name
* Organism Tax-ID
* Organism Strain
* Release Date of the Assembly

# Sample Location
* Isolation Source
* Geographic location of the Sample
* GPS Coordinates of the Sample
* Ecotype 

# Sample Characteristics
* Food safety classification of pathogens
* Host of the organism
* Host disease caused by organism
* Isolate name in BioSample record

# Assembly Details
* Atypical signal
* Atypical details
* Assembly type (indicate if it's a MAG)


@@@
List of all fields that i gonna use:

accession
organism-name
organism-tax-id
organism-infraspecific-isolate
organism-infraspecific-strain
assminfo-release-date

--Biosample info
assminfo-biosample-accession
assminfo-biosample-isolate
assminfo-biosample-strain
assminfo-biosample-isolation-source
assminfo-biosample-geo-loc-name 
assminfo-biosample-lat-lon 
assminfo-biosample-collection-date
assminfo-biosample-host
assminfo-biosample-host-disease
assminfo-biosample-ecotype

--Outros
assminfo-atypicalis-atypical 
assminfo-atypicalwarnings 
assminfo-level 
assminfo-type 
@@@

@@@@
BUSCA SEPARADA

* Sample info - Attribute Name
* Sample info - Attribute Value
assminfo-biosample-attribute-name
assminfo-biosample-attribute-value 
@@@@

The last two fields were important because they could contain information about the cultivation temperature and if this temperature is higher than 45°C, then the organism is thermophilic

To search and download the metadata, we use the NCBI CLI (Command Line Interface) *datasets* (version - 18.16.0) [11] and to filter the metadata we use another NCBLI CLI *dataformat* (version - 18.16.0) [11].

**2.1) Search using the taxons from Literature**

Using the two previous mentioned files containing the TaxID of each Bacteria and Archaea founded, we search and download all the metadata of the correspondent Assemblys using the following command:

#COMAND


Then, the following script was executed: ScriptWithNoName1.sh (on February 16, 2026) to download the metadata, filter according to the metadata fields mentioned and converted to a TSV Table

#COMAND (executed on February 16, 2026)
$ ./ScriptWithNoName1.sh ThermophileFromLiterature_Arc.txt
$ ./ScriptWithNoName1.sh ThermophileFromLiterature_Bac.txt

As the result, we get two new files with the genome metadata of the Bacteria and Archaea Domain:
- GenomeMetadataFromLit_Arc.tsv
- GenomeMetadataFromLit_Bac.tsv

**2.2) Search using the Isolation Source**

To download metadata using the Isolation Source, we first need to retrieve all Bacteria and Archaea metadata from NCBI, as the *datasets* tool does not allow filtered searches using the Isolation Source as a key.

Another problem is that both domains are too large to be downloaded directly, even if they are just the genome metadata. Therefore, the solution was to download one phylum at a time, concatenate all the phyla into one file, and then search for the genomes that have the Isolation Source of interest.

**2.2.1) Download all the metadata**

We first use the tool *Takonkit* to find all the phyla in each Domain and save the list of phyla in the files: 
- "Phyla_Arc.txt" 
- "Phyla_Bac.txt" 

#Comand (executed on February 16, 2026)
takonkit **** ***** ****** 2 # TaxID for Bacteria
takonkit **** ***** ****** 2157 # TaxID for Archaea

Then the following script was executed: ScriptWithNoName2.sh to read the files with the phyla, search for the genome metadata and concatenated all in a single file for each Domain:
- AllGenomeMetadata_Arc.txt
- AllGenomeMetadata_Bac.txt

@@@ It doesnt make more sense to first download all the metadata and then do both searchs?
@@@ Or I maintain the first method using Literature?

**2.2.2) Filter the metadata according to the Isolation Source**

After downloading all the Prokaryotes Genome Metadata we used the list of keywords/prefix of common "thermophilic sources" to seach for genomes of thermophilic organisms. To do that we executed the script: ScriptWithNoName3.sh, that use the keywords to filter the genome metadata and transfer this into new files:
- GenomeMetadataFromIS_Arc.tsv
- GenomeMetadataFromIS_Bac.tsv
Note: "IS" stands for "Isolation Source"

**3) Concatenating all the genome metadata founded

After downloanding the metadata use both methods (Literature and Isolation Source) we needed to concatenate all the diferent genomes and remove and the duplicates using the Acession Number as the filter. To do that we ran, for each Domain, the script: ScriptWithNoName4.sh that unite both tables (from the 2 methods) into one, sorted the entries and remove duplicates

#Comand (executed on February 16, 2026)
$ ./ScriptWithNoName4.sh GenomeMetadataFromLit_Arc.tsv GenomeMetadataFromIS_Arc.tsv
$ ./ScriptWithNoName4.sh GenomeMetadataFromLit_Bac.tsv GenomeMetadataFromIS_Bac.tsv

The resulting files were:
- GenomeMetadataMerged_Arc.tsv
- GenomeMetadataMerged_Bac.tsv

**4) Creating a Directory Structure for Taxonomy**


---------------------

# Reference list

[1] Merino N, et al. Crit. Rev. Microbiol. 2026. https://doi.org/10.1080/1040841X.2026.2614431

[2] Adam PS, et al. Nat. Commun. 2024. https://doi.org/10.1038/s41467-024-48498-5

[3] Sahoo RK, et al. J. Basic Microbiol. 2021. https://doi.org/10.1002/jobm.202100529

[4] Thomas C, et al. mSystems. 2022. https://doi.org/10.1128/msystems.00317-22

[5] Gidtiyanuek C, et al. Arch. Microbiol. 2024. https://doi.org/10.1007/s00203-024-03981-x

[6] Liu Y, et al. Food Sci. Nutr. 2024. https://doi.org/10.1002/fsn3.4540

[7] Singh A, et al. J. Egypt. Soc. Parasitol. 2024. https://doi.org/10.1007/s43393-024-00275-7

[8] Schoch CL, et al. NCBI Taxonomy: a comprehensive update on curation, resources and tools. Database (Oxford). 2020: baaa062. PubMed: 32761142 PMC: PMC7408187.

taxonkit
[9] Shen W, Ren H. TaxonKit: a practical and efficient NCBI taxonomy toolkit. J. Genet. Genomics. 2021;48(9):844-850. doi:10.1016/j.jgg.2021.03.006.

taxdump files
[10] NCBI Taxonomy Database. https://ftp.ncbi.nih.gov/pub/taxonomy/. Accessed Feb 13, 2026

datasets and dataformat
[11] O'Leary, N.A., Cox, E., Holmes, J.B., et al. Exploring and retrieving sequence and metadata for species across the tree of life with NCBI Datasets. Sci Data 11, 732 (2024). doi: 10.1038/s41597-024-03571-y

Data Source

| Tool / Resource | Version | Access/Download Date |
| :--- | :--- | :--- |
| **TaxonKit** | v0.20.0 | 2026-02-13 |
| **NCBI taxdump** | N/A | 2026-02-13 |
| **datasets** | 18.16.0 | 2026-02-16 |
| **dataformat** | 18.16.0 | 2026-02-16 |


