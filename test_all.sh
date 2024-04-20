#!/bin/bash
# vim:set sw=4 ts=4 et ai smartindent fileformat=unix fileencoding=utf-8 syntax=sh:
if [[ -n "$DEBUG" ]]; then set -x; fi
set -eu
set -o pipefail
export LANG=C LC_ALL=C TZ=UTC
if ! scriptdir="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"; then
    scriptdir="$(cd "$(dirname "$0")" && pwd)"
fi

# keep in background (don't run tests stealing focus)
export CI_NOFOCUS=1

echo "VCPKG_DEFAULT_TRIPLET=${VCPKG_DEFAULT_TRIPLET:-undefined}"

if [[ -z "${FASTEST:-}" ]]; then
    $scriptdir/vcpkg.sh rmpkgs
    if [[ -z "${FAST:-}" ]]; then
        #vcpkg rm-archives
        export VCPKG_FEATURE_FLAGS=-binarycaching
    fi
fi

cd $scriptdir

# randomize order of execution to detect incomplete pkglist.txt files
# without having to emptying the installation dir completely every time
for PKGLIST in `shopt -s globstar; grep '^#\s*@TESTALL:.*@' **/CMakeLists.txt | cut -d ':' -f1 | shuf`; do
    pkgdir="$(dirname "$PKGLIST")"
    cd $scriptdir/$pkgdir
    pwd
    $scriptdir/vcpkg.sh clean
    if [[ -z "${FASTEST:-}" ]]; then
        $scriptdir/vcpkg.sh
    else
        $scriptdir/vcpkg.sh dbg
    fi
done

echo "*********************"
echo "***               ***"
echo "***   All Good.   ***"
echo "***               ***"
echo "*********************"
