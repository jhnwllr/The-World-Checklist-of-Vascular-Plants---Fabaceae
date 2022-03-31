library(dplyr)
library(purrr)
library(xtable)

print(getwd())

d = readr::read_tsv("data/legume_unmatched.tsv",quote="")  %>% 
arrange(-count) %>% 
glimpse() %>% 
mutate(n_suggestions =  map_int(v_scientificname,~nrow(rgbif::name_suggest(.x)$data))) %>% 
mutate(n_suggestions = format(n_suggestions, nsmall = 0)) %>%
mutate(n_occ = format(count, nsmall = 0)) %>%
mutate(link = paste0('<a href=https://www.gbif.org/species/search?q=',gsub(" ","%20",v_scientificname),'>search</a>')) %>%
select(v_scientificname,taxonrank,n_occ,n_suggestions,link) %>% 
glimpse()

d %>% 
select(v_scientificname,taxonrank,n_occ,n_suggestions) %>% 
readr::write_tsv("data/legume_unmatched_aggregate.tsv")

quit(save="no")


d %>% 
select(v_scientificname,taxonrank,n_occ,n_suggestions) %>% 
readr::write_tsv("data/legume_unmatched_aggregate.tsv")

# things legume group might be able to fix
html_table = d %>%
filter(n_suggestions == 0) %>% 
filter(!taxonrank == "SPECIES") %>% 
head(30)

print(xtable(html_table), type = "html", file = "data/html_table.html",sanitize.text.function = force,include.rownames=FALSE)
