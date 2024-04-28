#!/bin/bash
# vim:set sw=4 ts=4 et ai smartindent fileformat=unix fileencoding=utf-8 syntax=sh:
if [[ -n "$DEBUG" ]]; then set -x; fi
set -eu
set -o pipefail
export LANG=C LC_ALL=C TZ=UTC
if ! scriptdir="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"; then
    scriptdir="$(cd "$(dirname "$0")" && pwd)"
fi

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
    vcpkg init
    install -d $TEST_ALL_VCPKG_ROOT/cmbd
    install -d $TEST_ALL_VCPKG_ROOT/archives
    # work on a copy of my to-be-tested sources
    rsync -a --del "$(pwd)/" "$(cygpath "$TEST_ALL_VCPKG_ROOT/my_srcs")"
    cd "$TEST_ALL_VCPKG_ROOT/my_srcs"
fi

# FASTEST=1 :
#   * skip tests
#   * skip release builds
#   * use binary cache
#   * don't purge installed packages (+sources)

# FAST=1 :
#   * purge installed packages and sources
#   * use binary cache

# none of FAST or FASTEST:
#   * don't use binary cache
#   * purge installed packages and sources

# for rebuilding all archives do:
#   * vcpkg rm-archives
#   * FAST=1 ./test_all.sh
# That's essentially equivalent to running test_all.sh
# without FAST/EST options, but rebuilds the package
# archive, which it wouldn't otherwise touch.

if [[ -z "${FASTEST:-}" ]]; then
    $scriptdir/vcpkg.sh rmpkgs
    if [[ -z "${FAST:-}" ]]; then
        if [[ -n "${TEST_ALL_VCPKG_ROOT:-}" ]]; then
            vcpkg rm-archives
        else # don't delete user's archives
            export VCPKG_FEATURE_FLAGS=-binarycaching
        fi
    fi
else # FASTEST=1 : skip tests and release builds, use binary cache
    export SKIP_TESTS=1
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
    $scriptdir/vcpkg.sh clean
    if [[ -z "${FASTEST:-}" ]]; then
        $scriptdir/vcpkg.sh
    else
        $scriptdir/vcpkg.sh dbg
    fi
    if (( lowspace )); then
        $scriptdir/vcpkg.sh clean
    fi
done

echo "*********************"
echo "***               ***"
echo "***   All Good.   ***"
echo "***               ***"
echo "*********************"
