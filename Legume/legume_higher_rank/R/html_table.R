
library(dplyr)
library(xtable)

# things legume group might be able to fix
d = readr::read_tsv("data/legume_unmatched_aggregate.tsv") %>% 
filter(n_suggestions == 0) %>% 
filter(!taxonrank == "SPECIES") %>% 
mutate(n_suggestions = format(n_suggestions, nsmall = 0)) %>%
mutate(n_occ = format(n_occ, nsmall = 0)) 

d %>% readr::write_tsv("data/legume_group_fixes.tsv")

html_table = d %>% head(30)
print(xtable(html_table), type = "html", file = "data/html_table.html",sanitize.text.function = force,include.rownames=FALSE)

quit(save="no")
