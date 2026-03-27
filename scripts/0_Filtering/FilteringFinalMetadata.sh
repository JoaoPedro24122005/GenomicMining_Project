#!/usr/env/bin bash

# SCRIPT - Filtering the metadata files

# 1 - Reading input file
# 2 - Removing Bacteria from Archaea data
# 3 - Removing Archaea from Bacteria data
# 4 - Removing Eucaryotes from Archaea and Bacteria data

# 5 *Removing Non-Thermophilic data (need to find some criteria):
# 5.1 - Check isolation source:
- soil, clay, mud
- cold
- rumen, ruminant, ruminal
- feces, fecal
- mud
- permafrost
- gut
- stool
- freshwater, drinking
- colostrum

# Discussion: Existe um furo na minha metodologia de busca por organismos extremofilos, isso é um fato, muitos desses organismos que eu defini como termofilos tem fontes de isolamento que nao caracterizam uma vida em ambiente quentes

# A questao é o que eu faço com isso? Eu refaco toda a metodologia de busca, mantendo so a fonte de isolamento e retirando as fontes da Literatura? Ou eu mantenho as referencias de organismos da literatura, so que filtro aqueles em que nao ha certeza em que toda os representantes da linhagem, como Bacillus subtilus, sao realmente termofilos

# Exemplo: https://cdn.ncbi.nlm.nih.gov/pmc/blobs/9f0e/10284858/c2f7e34f1d06/41396_2023_1409_Fig1_HTML.jpg
# Existem generos como o Nitrospira que tem apenas 20% das linhagens caracterizadas são encontradas em ambientes quentes (como hot spring e hydrothermal subsurface water), o resto são organismos do solo, de agua doce, de aquiferos, etc. Qual seria a solução nesse caso? Aumentar o grau de curadoria da busca e especificar apenas as linhagens que sao realmente termofilas? 

# OPCAO 1 - Refazer a lista de nomes de taxons de termofilos

# OPCAO 2 - Se a busca por nomes nao esta la muito confiavel (ex. Aneurinibacillus) tem muitos dos genomas montados vindos de amostra de solo (dificil ser termofilico nessas condicoes), talvez uma opcao seria encontrar qual a relacao filogenetica entre esses grupos e excluir os mais distantes ou algo do tipo

# Ferramenta para construir arvore - PhyloT, iTOL (visualize the tree), NCBI Taxonomy Browser (create the tree)

# Removing GCF_ entries from the data
# Find all words that identify lack of some data:
