
setwd("C:/Users/ftw712/Desktop/Legume/legume_added_names")

library(dplyr)


readr::read_tsv("data/Fabaceae-2019-09-06.tsv") %>% 
filter(genus == "Ulex") %>% 
filter(taxonRank == "genus") %>% 
glimpse()

