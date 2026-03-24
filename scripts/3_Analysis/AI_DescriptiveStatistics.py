import pandas as pd

# Load the metadata
file_path = 'ThermophileMetadata_Arc.tsv'
# Using sep='\t' for TSV; strip whitespace from column names automatically
df = pd.read_csv(file_path, sep='\t')
df.columns = df.columns.str.strip()

print("--- THERMOPHILIC ARCHAEA METADATA ANALYSIS REPORT ---\n")

### 1. TAXONOMIC DIVERSITY
# Unique species count
unique_species = df['Organism Name'].nunique()
# Extract Genus (first word of Organism Name)
df['Genus'] = df['Organism Name'].str.split().str[0]
genus_counts = df['Genus'].value_counts()

print(f"Total Unique Species: {unique_species}")
print(f"Top 5 Genera:\n{genus_counts.head(5)}\n")

### 2. ECOLOGICAL & ENVIRONMENTAL CONTEXT
# Handle missing isolation sources
iso_source = df['Assembly BioSample Isolation source'].fillna('Not Reported')

# Basic keyword categorization for Marine vs Terrestrial
marine_keywords = ['vent', 'ocean', 'sea', 'marine', 'ridge', 'abyssal']
is_marine = iso_source.str.contains('|'.join(marine_keywords), case=False)
marine_count = is_marine.sum()
terrestrial_count = len(df) - marine_count

print(f"Environment Stats:")
print(f" - Marine/Deep Sea related: {marine_count}")
print(f" - Terrestrial/Other: {terrestrial_count}")
print(f"Host Associations Found: {df['Assembly BioSample Host'].dropna().unique()}\n")

### 3. GEOGRAPHIC DISTRIBUTION
# Extract country (usually before the colon in 'Country: Region')
df['Country'] = df['Assembly BioSample Geographic location'].str.split(':').str[0]
country_counts = df['Country'].value_counts()

print(f"Top Geographic Locations:\n{country_counts.head(5)}\n")

### 4. TEMPORAL TRENDS & QUALITY
# Convert date to year
df['Year'] = pd.to_datetime(df['Assembly Release Date']).dt.year
yearly_growth = df['Year'].value_counts().sort_index()

# Quality Checks
atypical_perc = (df['Assembly Atypical Is Atypical'] == True).mean() * 100
completeness = df[['Assembly BioSample Isolation source', 
                  'Assembly BioSample Geographic location', 
                  'Assembly BioSample Collection date']].notnull().mean() * 100

print(f"Cumulative Growth (Genomes per Year):")
print(yearly_growth.tail(5)) # Shows most recent 5 years
print(f"\nPercentage of Atypical Genomes: {atypical_perc:.2f}%")
print("\nMetadata Completeness (% of non-null values):")
print(completeness)

print("\n--- ANALYSIS COMPLETE ---")