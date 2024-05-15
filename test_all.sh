#!/bin/bash
# vim:set sw=4 ts=4 et ai smartindent fileformat=unix fileencoding=utf-8 syntax=sh:
if [[ -n "$DEBUG" ]]; then set -x; fi
set -eu
set -o pipefail
export LANG=C LC_ALL=C TZ=UTC
if ! scriptdir="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"; then
    scriptdir="$(cd "$(dirname "$0")" && pwd)"
fi

VCPKG_SH=$scriptdir/vcpkg.sh

# decrease exeuction priority
renice 19 $$ || :

# keep in background (don't run tests stealing focus)
export CI_NOFOCUS=1

echo "VCPKG_DEFAULT_TRIPLET=${VCPKG_DEFAULT_TRIPLET:-undefined}"

# run tests in separate directory to not infere with user
if [[ -n "${TEST_ALL_VCPKG_ROOT:-}" ]]; then
    # if test -d $VCPKG_DEFAULT_BINARY_CACHE; then
    #     rsync -a --del "$(cygpath "$VCPKG_DEFAULT_BINARY_CACHE/")" "$(cygpath "$TEST_ALL_VCPKG_ROOT/archives")"
    # fi
    export VCPKG_DEFAULT_BINARY_CACHE=$TEST_ALL_VCPKG_ROOT/archives
    export CMAKE_USER_BUILD_DIR=$TEST_ALL_VCPKG_ROOT/cmbd
    export VCPKG_ROOT=$TEST_ALL_VCPKG_ROOT
    $VCPKG_SH init
    install -d $TEST_ALL_VCPKG_ROOT/cmbd
    install -d $TEST_ALL_VCPKG_ROOT/archives
    # work on a copy of my to-be-tested sources
    rsync -a --del "$(pwd)/" "$(cygpath "$TEST_ALL_VCPKG_ROOT/my_srcs")"
    cd "$TEST_ALL_VCPKG_ROOT/my_srcs"
fi

if test -f $scriptdir/../test_all_precmd.sh; then
    # if working on own ports, force rebuild from source (ie $VCPKG_SH rm-archive <portname:alt_triplet>)
    . $scriptdir/../test_all_precmd.sh
fi

if [[ -z "${FAST:-}" ]]; then
    $VCPKG_SH rmpkgs # force reinstall of deps (implies random dependency checks, but faster than a complete one)
fi

if [[ -n "${FAST:-}" ]]; then
    export SKIP_TESTS=1 # don't run tests
fi

if [[ -n "${REBUILD_PKGS:-}" ]] || [[ -n "${BUILD_PKGS:-}" ]]; then
    $VCPKG_SH rm-archives # force rebuild of packages from source
fi


let freeMb="$(stat -f -c %a*%S/1048576 "${CMAKE_USER_BUILD_DIR}")"
lowspace=0
if (( freeMb < 20480 )); then
    lowspace=1
fi

cdir=$(pwd)
echo "Running tests in: $cdir"

# randomize order of execution to detect incomplete pkglist.txt files
# without having to emptying the installation dir completely every time
for PKGLIST in `shopt -s globstar; grep '^#\s*@TESTALL:.*@' **/CMakeLists.txt | cut -d ':' -f1 | shuf`; do
    pkgdir="$(dirname "$PKGLIST")"
    cd $cdir/$pkgdir
    pwd
    $VCPKG_SH clean
    if [[ -n "${DEP_CHECK:-}" ]]; then
        $VCPKG_SH rmpkgs # remove installed pkgs to check for missing deps
    fi
    if [[ -z "${FAST:-}" ]]; then
        $VCPKG_SH # dbg+rel builds
    else
        $VCPKG_SH dbg # just dbg build
    fi
    if (( lowspace )); then
        $VCPKG_SH clean # clean up after to save space
    fi
done

echo "*********************"
echo "***               ***"
echo "***   All Good.   ***"
echo "***               ***"
echo "*********************"
