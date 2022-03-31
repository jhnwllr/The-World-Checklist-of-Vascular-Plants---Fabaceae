#!/bin/bash
echo "running spark script"
scp -r scala/legume_higher_rank_table.scala jwaller@c5gateway-vh.gbif.org:/home/jwaller/
ssh jwaller@c5gateway-vh.gbif.org 'spark2-shell -i legume_higher_rank_table.scala'
echo "downloading legume_unmatched.tsv"
rm data/legume_unmatched.tsv
echo "download file"
wget -O /mnt/c/Users/ftw712/desktop/Legume/legume_higher_rank/data/legume_unmatched.tsv http://download.gbif.org/custom_download/jwaller/legume_unmatched.tsv
echo "running post_processing.R"
Rscript.exe R/post_processing.R
echo "running html_table.R"
Rscript.exe R/html_table.R
echo "table for legume group"
Rscript.exe R/legume_group_table.R



