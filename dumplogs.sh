#!/usr/bin/env nix-shell
#!nix-shell -i bash -p tree -p nix -p utillinux

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

if true; then
    starting_drv() {
        echo -e "\e[0;49;95m💞: $1 \e[0m"
    }

    drv_produces() {
        echo "➡️️ $out"
    }

    build_passed() {
        echo -e "    \e[7;49;92m😍  We did it! 🍻 \e[0m";
    }

    build_failed() {
        echo -e "    \e[7;49;91m💔  Bummer :( \e[0m";
    }
else
:
fi

drvs() {
    nix-store -qR $(nix-instantiate ./default.nix)
}

outputs() {
    nix-store -q --outputs "$1"
}

drvs | (while read -r drvpath; do
            if nix-store --read-log "$drvpath" 2>/dev/null 1>&2; then
                worked=0

                starting_drv "$drvpath"

                nix-store --read-log --log-type pretty "$drvpath" | cat

                for out in $(outputs "$drvpath"); do
                    drv_produces "$out"

                    if test -e "$out"; then
                        worked=1
                    fi
                done



                if [ "$worked" -eq 0 ]; then
                    build_failed
                else
                    build_passed
                fi
            fi
        done)
