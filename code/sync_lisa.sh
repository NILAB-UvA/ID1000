rsync lukass@lisa.surfsara.nl:/nfs/lukass/derivatives/* \
    ../bids/derivatives/ \
    --ignore-existing \
    -h -v -r -P -t -l
