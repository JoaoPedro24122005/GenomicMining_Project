#!/usr/env/bin bash

# SCRIPT - Classifying groups based in metadata info (Thermophilic, Probably Thermophilic, Non-Thermophilic)

# DETAIL - Organisms living in the rumen of animals can be thermophiles, because even if the temperature in the rumen can be less than 40C, the thermophiles can actually live in these temperature. Remember there is a difference between the optimum temperature, the maximum temperature and minimum temperature at whic the organism can live (each organism has a range of Temperature, not a single one)

# 1 - Classification based on the Isolation Source

# 1.1 - Read the input file (from the first positional argument)
# 1.2 - Create a new column named Thermophile_Classification
# 1.3 - Read the Isolation Source column (named " Assembly BioSample Isolation source") = 10th column
# 1.4 - Insert in the column of Thermophile_Classification one of the three classes, based on the words that appear in the Isolation Source column:
# 1.4.1 - "Certainly_Thermophile": Words that characterize Thermophile:

# thermal
# thermophilic

# volcan

# black smoker

# hotspring
# hot spring
# hot water
# hot region
# hot stream
# hot underground
# hot marine
# hot pool
# hot tub
# hot aquifer
# hot river
# hot sediment
# hot lake
# hot area
# hot climate
# hot well
# freshwater hot
 
# boiling
# boiler
# boil drainage

# oilfield
# oil reservoir

# solfataric

# steam vent

# Richmond Mine

# high-temperature
# high temperature

# 1.4.2 - "Probably_Thermophile": 

acid mine drainage
feces
fecal
rumen
ruminant
mine tailings

# 1.4.3 - "Undetermined:"

soil
mud
sediment
missing
marine metagenome
seawater
groundwater
marine water sample
hypoxic seawater

"" # nothing

# O que eu quero fazer nesse SCRIPT - quero classificar cada umas das montagens encontradas, como "Termofilo" "Possivelmente_Termofilo" "Indeterminado". Isso so tem logica de ser aplicado em cima dos metadados encontrados usando fontes da Literatura, pois eu ja fiz uma etapa de filtragem de termofilos na metodologia de busca usando a fonte de isolament

# Conclusao: entende-se que "todas" as montagens obtidas usando a fonte de isolamento como filtro sao de termofilos, ja para as montagens da literatura eu nao posso dar essa mesma certeza

# Pelo que eu ja observei dos dados da literatura ha uma serie de organismos de fontes de isolamento um tanto suspeitas, como solo, intestino de ruminante, humano, etc

# Mas, se for pra aplicar esse filtro/classificacao de Termofilo/Possivelmente_Termofilo/Inderterminado nos dados da literatura, faz tbm sentido aplicar essa mesma classificacao para as montagens vindas da metologia com a fonte de isolamento

# E essas montagens sao literalmente TODAS AS MONTAGENS DO NCBI

# Nova metodologia entao:

# 1 - Baixar todos os metadados de bacteria e arqueia do NCBI (puxando as colunas de Numero de Acesso do Assembly e Fonte de Isolamento)

# 2 (OPCAO 1) - Extrair as montagens de termofilos da Literatura e Extrair as montagens de termofilos, termotolerantes, nao-termofilos e indeterminados com a Fonte de Isolamento

# Teria a adicao de 1 coluna apos a filtragem com a Literatura:
# - Referencia da Literatura (link DOI)

# Teria a adicao de 2 colunas apos a filtragem com a Fonte de Isolamento:
# - Classificacao (termofilo, termotolerante, nao-termofilo, indeterminado). Os indeterminados podem ser depois analisados e alocados para algumas das outras classes
# - Palavra-chave extraida: para destacar qual a palavra da fonte de isolamento que fez a filtragem classificar aquela montagem (se for indeterminado, esse campo fica com valor "NULL")

# UM PROBLEMA - O quao confiavel sao essas referencias da literatura, em relacao a se ela garante que o nome do organismos pertence realmente a um termofilo/hipertermofilo?
# Na minha cabeca, a fonte da literatura deveria servir como Controle Positivo da analise. Dando certeza que aqueles organismos sao termofilo/hipertermofilo

# 2 (OPCAO 2) - Extrair as montagens e classifica-las utilizando a fonte de isolamento

# Teria a adicao de 2 colunas:
# - Classificacao (termofilo, termotolerante, nao-termofilo, indeterminado). Os indeterminados podem ser depois analisados e alocados para algumas das outras classes
# - Palavra-chave extraida: para destacar qual a palavra da fonte de isolamento que fez a filtragem classificar aquela montagem (se for indeterminado, esse campo fica com valor "NULL")

# Depois, extrair e classificar utilizando a literatura

# Teria a adicao de 1 coluna apos a filtragem com a Literatura:
# - Referencia da Literatura (link DOI)

# O resultado disso sera uma tabela de montagens classificadas em que algumas delas terao uma referencia para um artigo que se refere àquela especie

# Essa referencia pode ser usada para confimar se a classificacao faz sentido ou nao. Assim, teremos os casos:
| Classificação         | Tem Referência    |
| :---                  | :---              |
| **Termófilo**         | Sim/Não           |
| **Termotolerante**    | Sim/Não           |
| **Não-Termófilo**     | Sim/Não           |
| **Indeterminado**     | Sim/Não           |

# ADICIONAR UMA COLUNA INDICANDO COMO AQUELE DADO DE TERMOFILO FOI IDENTIFICADO - LITERATURA (ADICIONAR DOI DO ARTIGO) OU FONTE DE ISOLAMENTO (ADICIONAR PALAVRA-CHAVE QUE DEU CORRESPONDENCIA)

# ADICIONAR COLUNA INDICANDO INFORMACOES SOBRE CULTIVO (CULTIVAVEL OU NAO CULTIVAVEL) - Como eu sei se é cultivavel ou nao (ha algum codigo de acesso no BacDive, BioSample?)

# MONTAR UMA NOVA PLANILHA/TABELA COM INFORMACOES FISIOLOGICAS/METABOLICAS SOBRE OS ORGANISMOS CULTIVAVEIS - Verificar se eu consigo extrair essas informacoes do BacDive ou outro banco de dados direto da linha de comando