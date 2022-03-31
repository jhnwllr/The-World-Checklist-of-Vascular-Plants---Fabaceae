#!/bin/bash
# echo "downloading backbones"
# base_dir="/mnt/c/Users/ftw712/desktop/Legume/legume_added_names/"
# LINK="https://hosted-datasets.gbif.org/datasets/backbone/backbone-current.zip"
# DIR="/mnt/c/Users/ftw712/desktop/Legume/legume_added_names/data/backbone-current.zip"
# wget -O $DIR $LINK
# LINK="https://hosted-datasets.gbif.org/datasets/backbone/2019-09-06/backbone.zip"
# DIR="/mnt/c/Users/ftw712/desktop/Legume/legume_added_names/data/backbone-2019-09-06.zip"
# wget -O $DIR $LINK
# unzip -p data/backbone-current.zip backbone/Taxon.tsv > data/Taxon-current.tsv
# unzip -p data/backbone-2019-09-06.zip Taxon.tsv > data/Taxon-2019-09-06.tsv
# echo "filter large taxon tables"
# Rscript.exe R/filter_taxon_table.R
# echo "clean up"
# rm data/*.zip
# rm data/Taxon-*.tsv



# https://hosted-datasets.gbif.org/datasets/backbone/2019-09-06/backbone.zip
# 

# echo "running spark script"
# scp -r scala/legume_higher_rank_table.scala jwaller@c5gateway-vh.gbif.org:/home/jwaller/
# ssh jwaller@c5gateway-vh.gbif.org 'spark2-shell -i legume_higher_rank_table.scala'
# echo "downloading legume_unmatched.tsv"
# rm data/legume_unmatched.tsv
# echo "download file"
# wget -O /mnt/c/Users/ftw712/desktop/Legume/legume_higher_rank/data/legume_unmatched.tsv http://download.gbif.org/custom_download/jwaller/legume_unmatched.tsv
# echo "running post_processing.R"
# Rscript.exe R/post_processing.R
# echo "running html_table.R"
# Rscript.exe R/html_table.R
