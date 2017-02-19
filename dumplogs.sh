#!/usr/bin/env nix-shell
#!nix-shell -i bash -p tree -p nix -p utillinux --pure

set -eu

if false; then
    set -x
    debug() {
        echo "$@" >&2
    }
else
    debug()  {}
fi

drvs() {
    find /nix/var/log/nix/drvs/ -type f -name '*.drv.bz2' -print0 \
        | (while read -d "" drv; do
               combined_path=$(echo "$drv" | rev | sed -e "s#/##" | rev)
               drvname=$(basename -s ".bz2" "$combined_path")
               drvpath="/nix/store/$drvname"
               if ! test -f "$drvpath"; then
                   debug "doesn't exist?"
                   continue
               fi
               printf "$drvpath\0"
           done)
}

outputs() {
    nix-store -q --outputs "$1"
}

drvs | (while read -d "" drv; do
              worked=0
              echo "$drvpath =>"
              for out in $(outputs "$drvpath"); do
                  echo " -> $out"
                  if test -e "$out"; then
                      worked=1
                  fi
              done
              echo "log:"
              nix-store --read-log "$drvpath" | sed -e "s/^/ --> /"
              if [ "$worked" -eq 0 ]; then
                  echo "Build failed :("
              else
                  echo "Build passed!"
              fi
          done)
