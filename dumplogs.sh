#!/usr/bin/env nix-shell
#!nix-shell -i bash -p tree -p nix -p utillinux # --pure

set -eu

if false; then
    set -x
    debug() {
        echo "$@" >&2
    }
else
    debug()  {
        :
    }
fi

drvs() {
    nix-store -qR $(nix-instantiate ./default.nix)
}

outputs() {
    nix-store -q --outputs "$1"
}

drvs | (while read -r drvpath; do
            worked=0
            echo "$drvpath =>"
            for out in $(outputs "$drvpath"); do
                echo " -> $out"
                if test -e "$out"; then
                    worked=1
                fi
            done
            echo "log:"
            nix-store --read-log "$drvpath"
            if [ "$worked" -eq 0 ]; then
                echo "Build failed :("
            else
                echo 'Build passed!'
            fi
            echo "~~~~~~~~~~~~~~~~~~~~~"
        done)
