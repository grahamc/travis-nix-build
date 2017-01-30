#!/usr/bin/env nix-shell
#!nix-shell -p lsof -i bash

set -o pipefail
set -eu

WORKING=$(mktemp -d)
touch $WORKING/remotepid
mkfifo "$WORKING/pipe"


cleanup() {

    if [ $(cat "$WORKING/pass" | wc -l) -gt 0 ]; then
        echo "Success on:"
        green_fg=$(tput setaf 2)
        resetc=$(tput sgr0)
        cat "$WORKING/pass" | sed -e "s/^/   $green_fg😍  $resetc/";
    fi

    if [ $(cat "$WORKING/fail" | wc -l) -gt 0 ]; then
        echo "No good:"
        red_fg=$(tput setaf 1)
        resetc=$(tput sgr0)
        cat "$WORKING/fail" | sed -e "s/^/   $red_fg😞  $resetc/";
    fi

    rm -rf "$WORKING"
}
trap cleanup EXIT

touch $WORKING/seen
touch $WORKING/pass
touch $WORKING/fail
mkdir $WORKING/roots

i=0

(while read -r drv; do
    if grep -q "$drv" "$WORKING/seen"; then
        touch "$WORKING/killsub"
        kill $(cat  "${WORKING}/buildmaster")
        break
    fi

    echo -en "\e[0;49;95m💞: $drv \e[0m"
    echo ""

    echo "$drv" >> "$WORKING/seen"

    if nix-store --realize "$drv" --indirect --add-root "$WORKING/roots/$i" 2>&1 | sed -e "s/^/    /"; then
        echo -en "    \e[7;49;92m😍  We did it! 🍻 \e[0m";
        echo ""
        ret=$(readlink "$WORKING/roots/$i")
        echo "$drv ➡️️ $ret" >> "$WORKING/pass"
    else
        echo -en "    \e[7;49;91m💔  Bummer :( \e[0m";
        echo ""
        echo "$drv" >> "$WORKING/fail"
    fi

    i=$((i + 1))
 done) < "${WORKING}/pipe" &

ui=$!
DIEON="${WORKING}/killsub" SUB="${WORKING}/pipe" NIX_BUILD_HOOK=$(pwd)/remote.sh nix-build "$@" > /dev/null 2>&1 &
buildmaster=$!
echo $buildmaster > "${WORKING}/buildmaster"

wait $buildmaster
wait $ui
