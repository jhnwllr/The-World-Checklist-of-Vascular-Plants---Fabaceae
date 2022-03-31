setwd("C:/Users/ftw712/Desktop/Legume/legume_higher_rank/")

library(dplyr)
library(purrr)
library(stringr)
library(openxlsx)

df = readr::read_tsv("data/legume_unmatched_aggregate.tsv") %>% 
filter(n_suggestions == 0) %>% 
filter(!taxonrank == "SPECIES") %>% 
mutate(v_scientificname_2 = word(v_scientificname, 1,2, sep=" ")) %>%
mutate(n_suggestions_2 =  map_int(v_scientificname_2,~nrow(rgbif::name_suggest(.x)$data))) %>% 
filter(n_suggestions_2 == 0) %>%
select(binomial_name = v_scientificname_2,v_scientificname) %>% 
arrange(binomial_name) %>% 
glimpse()

write.xlsx(df, "data/legume-potentially-missing-names.xlsx")






