# filter large backbone table

library(dplyr)

readr::read_tsv("data/Taxon-current.tsv") %>%
filter(family == "Fabaceae") %>% 
glimpse() %>% 
readr::write_tsv("data/Fabaceae-current.tsv")

readr::read_tsv("data/Taxon-2019-09-06.tsv") %>%
filter(family == "Fabaceae") %>% 
glimpse() %>%
readr::write_tsv("data/Fabaceae-2019-09-06.tsv")
