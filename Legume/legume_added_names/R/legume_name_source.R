# compare name source

setwd("C:/Users/ftw712/Desktop/Legume/legume_added_names")

library(dplyr)
library(ggplot2)
library(ggtext)

current_df = readr::read_tsv("data/Fabaceae-current.tsv") %>% 
glimpse()

wcvp_names = 
current_df %>% 
filter(datasetID == "f7053f73-74fb-4c9f-ab63-de28c61140c2") %>% 
pull(scientificName)

old_df = readr::read_tsv("data/Fabaceae-2019-09-06.tsv") %>% 
mutate(is_in_wcvp = scientificName %in% wcvp_names) %>% 
mutate(is_old_name = !is_in_wcvp) 

old_names = old_df %>%
pull(scientificName)

# current_df %>%
# group_by(taxonomicStatus) %>%
# count()
# filter(!taxonomicStatus == "doubtful") %>%

name_df = current_df %>%
mutate(is_wcvp_name = datasetID == "f7053f73-74fb-4c9f-ab63-de28c61140c2") %>% 
mutate(is_old_name = scientificName %in% old_names) %>%
mutate(name_source =
case_when(
is_old_name & !is_wcvp_name ~ "old in other source",
is_wcvp_name & !is_old_name ~ "new in WCVP",
is_wcvp_name ~ "old in WCVP",
TRUE ~ "new in other source"
)) 

name_df %>%
group_by(datasetID,name_source) %>% 
count() %>% 
arrange(-n) %>%
select(datasetID, name_source, names_count = n) %>%
glimpse() %>% 
openxlsx::write.xlsx("C:/Users/ftw712/Desktop/legume_name_sources.xlsx")


fct_lev = c("new in other source","old in other source","new in WCVP","old in WCVP")

# if(FALSE) { # single bar 
pd = name_df %>%
group_by(name_source) %>% 
count() %>% 
mutate(x="") %>%
mutate(name_source = as.factor(name_source)) %>%
mutate(name_source = forcats::fct_relevel(name_source,fct_lev)) %>%
glimpse() 

breaks = scales::pretty_breaks(n = 7)(c(0,100e3))
labels = gbifapi::plot_label_maker(breaks,unit_MK = "K",unit_scale = 1e-3)

readr::write_tsv(pd,"C:/Users/ftw712/Desktop/data_legume_name_source.tsv")

p = ggplot(pd,aes(x,n)) +
geom_bar(position="stack",stat="identity",aes(fill=name_source)) +
coord_flip() +
theme_bw() +
scale_y_continuous(expand=c(0.01,0.1)) +
xlab("") +
ylab("") +
theme(axis.title.x = element_text(margin = margin(t = 8, r = 0, b = 5, l = 0), size = 11, face="plain")) +
theme(axis.text.y=element_text(face="plain",size=10,color="#535362")) +
theme(plot.margin = unit(c(0.2,0.5,0.1,0.1), "cm")) +
theme(plot.title = element_text(family = "sans", size = 12, margin=unit(c(0.2,0.5,0.3,0.1), "cm"))) + 
theme(legend.title = element_blank()) +
theme(
legend.position="top", 
legend.justification="left",
legend.direction="horizontal") +
labs(
title = "Legume (Fabaceae) names in backbone",
caption = 
"The World Checklist of Vascular Plants (<b>WCVP</b>): Fabaceae<br><b>Old names</b> come from the 2021-09-14 backbone<br> <b>New names</b> come from the 2021-12-03 backbone") +
theme(
plot.caption.position = "plot",
plot.caption = element_textbox_simple(
size = 8,
lineheight = 1,
padding = margin(1, 1, 1, 1),
margin = margin(5, 5, 5.5, 230),
fill = "#ffffff",
hjust = 1
)) + 
guides(fill = guide_legend(reverse = TRUE)) + 
scale_fill_manual(
values = c("#6885C0","#BCC7DE","#E37C72","#EC9F9A")
) + 
scale_y_continuous(breaks = breaks,label = labels,limits=c(0,100e3),expand=c(0.01,0.1)) 

save_dir = "C:/Users/ftw712/Desktop/Legume/plots/"
gbifapi::save_ggplot_formats(p,save_dir,"legume_name_source",height=3.5,width=6.5,formats=c("pdf","jpg","svg"))

# }

# by genus 

pd = name_df %>%
group_by(name_source,genus) %>% 
count() %>% 
group_by(genus) %>% 
mutate(total_count=sum(n)) %>%
ungroup() %>% 
filter(total_count > 250) %>% 
mutate(genus = forcats::fct_reorder(genus, total_count)) %>%
mutate(name_source = as.factor(name_source)) %>%
mutate(name_source = forcats::fct_relevel(name_source,fct_lev)) %>%
glimpse() 

breaks = scales::pretty_breaks(n = 7)(c(0,12e3))
labels = gbifapi::plot_label_maker(breaks,unit_MK = "K",unit_scale = 1e-3)

readr::write_tsv(pd,"C:/Users/ftw712/Desktop/data_legume_name_source_genus.tsv")

p = ggplot(pd,aes(genus,n)) +
geom_bar(position="stack",stat="identity",aes(fill=name_source)) +
coord_flip() +
theme_bw() +
scale_y_continuous(expand=c(0.01,0.1)) +
xlab("") +
ylab("") +
theme(axis.title.x = element_text(margin = margin(t = 8, r = 0, b = 5, l = 0), size = 11, face="plain")) +
theme(axis.text.y=element_text(face="plain",size=10,color="#535362")) +
theme(plot.margin = unit(c(0.2,0.5,0.1,0.1), "cm")) +
theme(plot.title = element_text(family = "sans", size = 12, margin=unit(c(0.2,0.5,0.3,0.1), "cm"))) + 
theme(legend.title = element_blank()) +
theme(
legend.position="top", 
legend.justification="left",
legend.direction="horizontal") +
labs(
title = "Legume (Fabaceae) names in <b>GBIF Backbone<b>",
caption = 
"The World Checklist of Vascular Plants (<b>WCVP</b>): Fabaceae<br><b>Old names</b> come from the 2021-09-14 backbone<br> <b>New names</b> come from the 2021-12-03 backbone<br>Only Genera with greater than 250 total names shown<br>") +
theme(
plot.title = element_textbox_simple(
size = 16,
lineheight = 1,
padding = margin(1, 1, 5, 1),
margin = margin(1, 1, 2, -5),
fill = "#ffffff",
hjust = 1
),
plot.caption.position = "plot",
plot.caption = element_textbox_simple(
size = 8,
lineheight = 1,
padding = margin(1, 1, 1, 1),
margin = margin(0, 4, 6, 230),
fill = "#ffffff",
hjust = 1
)) + 
guides(fill = guide_legend(reverse = TRUE)) + 
scale_fill_manual(
values = c("#6885C0","#BCC7DE","#E37C72","#EC9F9A")
) + 
scale_y_continuous(breaks = breaks,label = labels,limits=c(0,12e3),expand=c(0.01,0.1)) 

save_dir = "C:/Users/ftw712/Desktop/Legume/plots/"
gbifapi::save_ggplot_formats(p,save_dir,"legume_name_source_genus",height=10.5,width=6.5,formats=c("pdf","jpg","svg"))

