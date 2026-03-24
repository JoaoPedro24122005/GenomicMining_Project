import pandas as pd

# Load the metadata
file_path = 'ThermophileMetadata_Arc.tsv'
df = pd.read_csv(file_path, sep='\t')
df.columns = df.columns.str.strip()

print("--- REFINING DIVERSITY ANALYSIS ---")

# 1. Improved Taxonomy: Grouping beyond 'Candidatus'
# We extract the second word if the first is 'Candidatus' or 'uncultured'
def get_clean_name(name):
    parts = str(name).split()
    if len(parts) > 1 and parts[0] in ['Candidatus', 'uncultured']:
        return f"{parts[0]} {parts[1]}"
    return parts[0]

df['Refined_Group'] = df['Organism Name'].apply(get_clean_name)
refined_counts = df['Refined_Group'].value_counts().head(15)

# 2. Year-over-Year Growth (Cumulative)
df['Year'] = pd.to_datetime(df['Assembly Release Date']).dt.year
temporal_stats = df.groupby('Year').size().cumsum()

# 3. Exporting the "Summary Report" to CSV
# This creates a file you can open in Excel
summary_data = {
    'Metric': ['Total Genomes', 'Unique Species', 'Atypical %', 'Marine Count', 'Terrestrial Count'],
    'Value': [
        len(df), 
        df['Organism Name'].nunique(), 
        (df['Assembly Atypical Is Atypical'] == True).mean() * 100,
        df['Assembly BioSample Isolation source'].str.contains('vent|ocean|sea|marine', case=False, na=False).sum(),
        len(df) - df['Assembly BioSample Isolation source'].str.contains('vent|ocean|sea|marine', case=False, na=False).sum()
    ]
}

summary_df = pd.DataFrame(summary_data)
summary_df.to_csv('Thermophile_Statistics_Summary.csv', index=False)
refined_counts.to_csv('Top_Taxa_Groups.csv')

print("\nTop 15 Refined Groups (Resolving 'uncultured' labels):")
print(refined_counts)
print("\n[SUCCESS] Summary files saved: 'Thermophile_Statistics_Summary.csv' and 'Top_Taxa_Groups.csv'")