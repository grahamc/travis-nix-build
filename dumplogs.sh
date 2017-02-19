#!/usr/bin/env nix-shell
#!nix-shell -i bash -p tree --pure

set -eux

drvs() {
    find /nix/var/log/nix/drvs/ -type f -name '*.drv.bz2' -print0
}

outputs() {
    nix-store -q --outputs "$1"
}

drvs | (while read -d "" drv; do
              drvname=$(basename -s ".bz2" "$drv")
              drvpath="/nix/store/$drvname"
              if ! test -f "$drvpath"; then
                  # continue
              fi

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
