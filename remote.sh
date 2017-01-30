#!/bin/sh


set -eu

#while [ $(lsof "$SUB" | wc -l) -eq 0 ]; do
#    sleep .1
#done


(while read -r q; do
    drv=$(echo "$q" | cut -d' ' -f3)
    echo "$drv"
    echo "# postpone" >&2

    if [ -f "$DIEON" ]; then
        exit 0
    fi
    #
    #read -r inputs
    #read -r outputs

    #echo "$outputs"
    #nix-store --realize "$drv"
    #echo ":)"


done) > $SUB
