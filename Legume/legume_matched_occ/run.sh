#!/bin/bash
echo "running spark script"
scp -r scala/higher_rank_match.scala jwaller@c5gateway-vh.gbif.org:/home/jwaller/
ssh jwaller@c5gateway-vh.gbif.org 'spark2-shell -i higher_rank_match.scala'
echo "downloading legume_genus_occ.tsv"
rm /mnt/c/Users/ftw712/desktop/Legume/data/legume_genus_occ.tsv
echo "download file"
wget -O /mnt/c/Users/ftw712/desktop/Legume/data/legume_genus_occ.tsv http://download.gbif.org/custom_download/jwaller/legume_genus_occ.tsv



