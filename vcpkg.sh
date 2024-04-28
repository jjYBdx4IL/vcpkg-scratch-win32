#!/bin/bash
# vim:set sw=4 ts=4 et ai smartindent fileformat=unix fileencoding=utf-8 syntax=sh:

# set up your env:
# VCPKG_ROOT (required)
# VCPKG_DOWNLOADS (semi-optional, probably want to put that outside VCPKG_ROOT to retain it during VCPKG upgrades)
# VCPKG_DEFAULT_TRIPLET (optional, sources currently assume x64-windows-static-md)
# VCPKG_DEFAULT_BINARY_CACHE (optional)
# VCPKG_FEATURE_FLAGS=-binarycaching (optional, disable binary caching)
# VCPKG_DISABLE_METRICS=1 (optional, don't report usage)

if [[ -n "$DEBUG" ]]; then set -x; fi
set -eu
set -o pipefail
export LANG=C LC_ALL=C TZ=UTC
if ! scriptdir="$(cd "$(dirname "$0")" && cd "$(dirname "$(readlink "$0")")" && pwd)"; then
    scriptdir="$(cd "$(dirname "$0")" && pwd)"
fi

# TODO? move to a user config location so it's not part of the public github repo?
if [[ -z "${VCPKG_GIT_REV:-}" ]]; then
    VCPKG_GIT_REV=6c87aab05cb2ebd1c9e382167edf3b15a7718e70
fi
VCPKG_GIT_URL=https://github.com/microsoft/vcpkg.git

test -d $VCPKG_DOWNLOADS || mkdir -p $VCPKG_DOWNLOADS

export PORTS_OVERLAY_DIR="$scriptdir/ports"
export TRIPLETS_OVERLAY_DIR="$scriptdir/triplets"

TCFILE=$VCPKG_ROOT/scripts/buildsystems/vcpkg.cmake

test -n "$CMAKE_USER_BUILD_DIR"

export ROOTDIR="$scriptdir"
export SOURCEDIR="$(pwd)"

export PROJECT_NAME="$(basename "$SOURCEDIR")"
export BUILDDIR="$CMAKE_USER_BUILD_DIR/$PROJECT_NAME"
PROJECT_PARENT_DIR_NAME="$(basename "$(dirname "$SOURCEDIR")")"
if [[ "$PROJECT_PARENT_DIR_NAME" != "cpp" ]]; then
    export BUILDDIR="$CMAKE_USER_BUILD_DIR/$PROJECT_PARENT_DIR_NAME/$PROJECT_NAME"
fi

if test -z "${VCPKG_DEFAULT_BINARY_CACHE:-}"; then
    # set to default assumed by vcpkg if not set (for script purposes)
    if [[ "$(uname)" =~ CYGWIN ]]; then
        export VCPKG_DEFAULT_BINARY_CACHE="$LOCALAPPDATA/vcpkg/archives"
    else
        export VCPKG_DEFAULT_BINARY_CACHE="$HOME/.cache/vcpkg/archives"
    fi
fi

if [[ $(uname) =~ CYGWIN ]]; then
cmake_path() {
    if which cmake | grep ^/cygdrive >/dev/null; then
        cygpath -m "$1"
    else
        cygpath "$1"
    fi
}
else
cmake_path() {
    echo "$@"
}
cygpath() {
    echo "$@"
}
fi

cmd=${1:-}

#if [[ -n "${DEBUG:-}${TRACE:-}" ]]; then
    export CMAKE_BUILD_PARALLEL_LEVEL=1
#fi

if ! test -e "$VCPKG_ROOT"; then
    mkdir $VCPKG_ROOT
    pushd $VCPKG_ROOT
    compact /c /s /I /Q
    popd
    git clone $VCPKG_GIT_URL $VCPKG_ROOT
    cd $VCPKG_ROOT

    git checkout -f $VCPKG_GIT_REV
    [[ $(git status -s 2>&1 | wc -l) == 0 ]]
    #sed -i triplets/$VCPKG_DEFAULT_TRIPLET.cmake -e 's#VCPKG_CRT_LINKAGE static#VCPKG_CRT_LINKAGE dynamic#'
fi

# if ! test -e $VCPKG_DEFAULT_BINARY_CACHE; then
#     mkdir $VCPKG_DEFAULT_BINARY_CACHE
# fi

cd $VCPKG_ROOT

if ! CUR_REV=$(git log -n1 | head -n1 | grep "^commit " | awk '{print $2}'); then
    CUR_REV="none"
fi
# if [[ "$CUR_REV" != "none" ]]; then
#     echo "Current vcpkg revision:"
#     git log -n1
# fi
if [[ "$CUR_REV" != "$VCPKG_GIT_REV" ]]; then
    echo "New VCPKG revision selected: $VCPKG_GIT_REV"
    # echo "Deleting stale vcpkg installation..."
    # rm -rf "$VCPKG_ROOT"
    git pull ||:
    git checkout -f $VCPKG_GIT_REV
    [[ $(git status -s 2>&1 | wc -l) == 0 ]]
    git clean -dxf
fi

if [[ $(uname) =~ CYGWIN ]]; then
    if ! test -e "$VCPKG_ROOT/vcpkg.exe"; then
        cmd /C bootstrap-vcpkg.bat
    fi
else
    if ! test -e "$VCPKG_ROOT/vcpkg"; then
        bash ./bootstrap-vcpkg.sh
    fi
fi


if [[ "$cmd" == "init" ]]; then
    exit 0
fi


if [[ "$cmd" == "help" ]]; then
    echo "Commands:"
    echo "    rmpkgs - remove all built vcpkg packages"
    echo "    rm-archives - remove all binary archives"
    echo "    install <pkg> - re-install vcpkg package"
    echo "    deps - read pkglist.txt in current dir and install listed packages"
    echo "    reconf - remove CMakeCache.txt first"
    echo "    clean - clean out build dir (except .vs/ sub dir)"
    echo "    dbg|rel - build Release or Debug target only"
    echo "    * - run vcpkg in VCPKG_ROOT with given arguments"
    echo "    <EMPTY> - rebuild project in current directory"
    echo "Env vars:"
    echo "    SKIP_TESTS - skip running tests (ctest)"
    echo "Using overlay in: $PORTS_OVERLAY_DIR"
    echo "----------------------------------------------------------------------------"
    echo "vcpkg commands:"
    ./vcpkg help
    exit 1
fi

RMPKG_TSTAMP="$CMAKE_USER_BUILD_DIR/.tstamp.__RMPKG__"
if [[ "$cmd" == "rmpkgs" ]]; then
    echo "Removing $VCPKG_ROOT/{buildtrees,packages,installed} ..."
    rm -rf "$VCPKG_ROOT/"{buildtrees,packages,installed}
    touch $RMPKG_TSTAMP
    echo "Done."
    exit 0
fi
if [[ "$cmd" == "rm-archives" ]]; then
    if test -n "${VCPKG_DEFAULT_BINARY_CACHE:-}"; then
        if test -e "${VCPKG_DEFAULT_BINARY_CACHE:-}"; then
            echo "Removing archives in $VCPKG_DEFAULT_BINARY_CACHE ..."
            find "$VCPKG_DEFAULT_BINARY_CACHE" -mindepth 1 -delete
        fi
    fi
    echo "Done."
    exit 0
fi

rm_bincache() {
    local pkgname=$1
    local triplet=$2
    if [[ $pkgname =~ (.*):(.*) ]]; then
        pkgname=${BASH_REMATCH[1]}
        triplet=${BASH_REMATCH[2]}
    fi
    local abifn="$(cygpath "$VCPKG_ROOT/buildtrees/$pkgname/$triplet.vcpkg_abi_info.txt")"
    if test -e $abifn; then
        local sum="$(set -o pipefail; sha256sum "$abifn" | cut -b 1-64;echo)"
        local sum2="$(echo "$sum" | cut -b 1-2)"
        rm -fv "$VCPKG_DEFAULT_BINARY_CACHE/$sum2/$sum.zip"
    fi
}

if [[ "$cmd" == "logs" ]] || [[ "$cmd" == "log" ]]; then
    latest=$(ls -t "$VCPKG_ROOT/buildtrees" | head -n1)
    cd "$VCPKG_ROOT/buildtrees/$latest"
    exec mc
fi

if [[ "$cmd" == "mci" ]]; then
    cd "$VCPKG_ROOT/installed/${VCPKG_DEFAULT_TRIPLET}"
    exec mc
fi

if [[ "$cmd" == "install" ]] || [[ "$cmd" == "reinstall" ]]; then
    pkg=$2
    [[ -n "$pkg" ]]
    ./vcpkg remove --recurse $pkg || :
    rm_bincache $pkg $VCPKG_DEFAULT_TRIPLET

    tmpf=$(mktemp)
    trap "rm \"$tmpf\"" EXIT

    if ! ./vcpkg install ${DEBUG:+--debug} --overlay-ports="$(cmake_path "$PORTS_OVERLAY_DIR")" --overlay-triplets="$(cmake_path "$TRIPLETS_OVERLAY_DIR")" $pkg 2>&1 | tee -a "$tmpf"; then
        if linenum=$(grep -n "See logs for more information:" "$tmpf"); then
            linenum=${linenum%%:*}
            lines=$(cat "$tmpf" | wc -l)
            nrem=$(( lines - linenum ))
            rest=$(tail -n$nrem "$tmpf")
            echo "$rest" | while read -r l; do
                if [[ "x$l" == "x" ]]; then break; fi
                echo "**"
                echo "** $l :"
                echo "**"
                tail -n20 "$l"
            done
            
        fi
        exit 37
    fi

    if [[ -n "${DEBUG:-}" ]]; then
        grep -n "" installed/vcpkg/info/${pkg}_*_${VCPKG_DEFAULT_TRIPLET}.list || :
    fi
    exit 0
fi

if [[ "$cmd" == "clean" ]]; then
    if test -e "$BUILDDIR"; then
        ( cd "$BUILDDIR" && find . -not -wholename './.vs**' -delete )
    fi
    if test -e "$BUILDDIR-dbg"; then
        ( cd "$BUILDDIR-dbg" && find . -not -wholename './.vs**' -delete )
    fi
    rm -rf${DEBUG:+v} "$BUILDDIR-vscode"
    if [[ "$SOURCEDIR" =~ /cpp/vst/ ]] || [[ "$SOURCEDIR" =~ /cpp/juce/ ]]; then
        rm -rf${DEBUG:+v} "$CMAKE_USER_BUILD_DIR/VST3/$PROJECT_NAME.vst3"
    fi
    echo "Done."
    exit 0
fi

if [[ -n "$cmd" ]] && [[ "$cmd" != "vs" ]] && [[ "$cmd" != "reconf" ]] && [[ "$cmd" != "deps" ]] \
    && [[ "$cmd" != "dbg" ]] && [[ "$cmd" != "rel" ]] && [[ "$cmd" != "auto" ]] \
    && [[ "$cmd" != "code" ]]; then
    ./vcpkg "$@"
    exit 0
fi



INC_SH="$SOURCEDIR/vcpkg.inc"
if test -e "$INC_SH"; then
    INC_SUPPORTED=1
    . "$INC_SH"
    if ! (( INC_SUPPORTED )); then 
        echo "Configuration not supported." >&2
        exit 0
    fi
fi



UPDATE_VCPKG=0
PKGLIST="$SOURCEDIR/CMakeLists.txt"
PKGLIST_TSTAMP="$BUILDDIR/.pkglist.tstamp"
if test -e $PKGLIST; then
    if ! test -e $PKGLIST_TSTAMP || test $PKGLIST -nt $PKGLIST_TSTAMP; then
        UPDATE_VCPKG=1
    fi
    if test -e $RMPKG_TSTAMP; then
        if test $PKGLIST_TSTAMP -ot $RMPKG_TSTAMP; then
            UPDATE_VCPKG=1
        fi
    fi

    VCPKGL="$(cat "$PKGLIST" | perl -ne '/^\s*#\s*\@VCPKGL:(.*)\@/ && print lc($1)')"
    if [[ "$VCPKGL" == "dynamic" ]]; then
        VCPKG_DEFAULT_TRIPLET=${VCPKG_DEFAULT_TRIPLET%%-static*}
    elif [[ "$VCPKGL" == "static" ]]; then
        echo "static arg not supported yet" >&2
        exit 3
    fi
fi
if (( UPDATE_VCPKG )) || [[ "$cmd" == "deps" ]]; then
    pkgs="$(cat "$PKGLIST" | perl -ne 'if(/^\s*#\s*\@VCPKGS:(.*)\@/){$_=$1;s/,/ /g;print " $_"}')"
    if [[ -n "$pkgs" ]]; then
        ./vcpkg install --overlay-ports="$(cmake_path "$PORTS_OVERLAY_DIR")" --overlay-triplets="$(cmake_path "$TRIPLETS_OVERLAY_DIR")" ${INSTALL_ARGS:-} $pkgs
    fi
    mkdir -p "$(dirname "$PKGLIST_TSTAMP")"
    touch $PKGLIST_TSTAMP
fi




cd $SOURCEDIR

if ! test -f CMakeLists.txt; then
    echo "no CMakeLists.txt in current directory" >&2
    exit 1
fi

if [[ "$cmd" == "auto" ]]; then
    remote=${2:-}
    if [[ -z "$remote" ]]; then
        echo "no remote given" >&2
        exit 87
    fi
    relpath=${SOURCEDIR}/
    relpath=${relpath/*\/cpp\//cpp\/}
    [[ "$relpath" =~ ^cpp/ ]]
    rsync -ai --del ./ $remote:$relpath
    ssh $remote ". /etc/profile; . .profile;export DEBUG=${DEBUG:-};cd \"$relpath\" && vcpkg clean && vcpkg debug" ||:
    while inotifywait -r .; do
        rsync -ai --del ./ $remote:$relpath
        ssh $remote ". /etc/profile; . .profile;export DEBUG=${DEBUG:-};cd \"$relpath\" && vcpkg debug" ||:
    done
    exit 3
fi


if [[ "$cmd" == "code" ]]; then
    test -e .vscode && rm -rf .vscode
    if ! test -e .vscode; then
        mkdir .vscode
        cat > .vscode/settings.json <<EOF
{
    "cmake.buildDirectory": "$(cmake_path "$BUILDDIR-vscode")",
    "C_Cpp.default.configurationProvider": "ms-vscode.cmake-tools",
    "cmake.configureSettings": {
        "CMAKE_TOOLCHAIN_FILE": "$VCPKG_ROOT/scripts/buildsystems/vcpkg.cmake",
        "VCPKG_TARGET_TRIPLET": "$VCPKG_DEFAULT_TRIPLET"
    }
}
EOF
        cat > .vscode/c_cpp_properties.json <<EOF
{
  "env": {
  },
  "configurations": [
    {
      "name": "Windows",
      "includePath": ["$(cmake_path "$BUILDDIR-vscode/${PROJECT_NAME}_artefacts/JuceLibraryCode")"]
    }
  ],
  "version": 4
}
EOF
        if [[ "$SOURCEDIR" =~ /cpp/vst/ ]] || [[ "$SOURCEDIR" =~ /cpp/juce/ ]]; then
            REAPER_LOC=$HOME/reaper/reaper
            DBGTYPE="cppdbg"
            if [[ "$(uname)" =~ CYGWIN ]]; then
                REAPER_LOC=$(cmake_path "$USERPROFILE/Documents/reaper-dev")
            elif [[ "$(uname)" =~ Darwin ]]; then
                REAPER_LOC=/Applications/REAPER.App/Contents/MacOS/REAPER
                DBGTYPE="lldb"
            fi
            cat > .vscode/launch.json <<EOF
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "(gdb/REAPER) Launch",
            "type": "$DBGTYPE",
            "request": "launch",
            "program": "$REAPER_LOC",
            "args": [],
            "stopAtEntry": false,
            "cwd": "\${workspaceFolder}",
            "externalConsole": false,
            "MIMode": "gdb",
            "setupCommands": [
                {
                    "description": "Enable pretty-printing for gdb",
                    "text": "-enable-pretty-printing",
                    "ignoreFailures": true
                }
            ]
        }
    ]
}
EOF
        else
            # requires CodeLLDB (works on MacOS):
            cat > .vscode/launch.json <<EOF
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "(gdb) Launch",
            "type": "lldb",
            "request": "launch",
            // Resolved by CMake Tools:
            "program": "\${command:cmake.launchTargetPath}",
            "args": [],
            "stopAtEntry": false,
            "cwd": "\${workspaceFolder}",
            "environment": [
                {
                    // add the directory where our target was built to the PATHs
                    // it gets resolved by CMake Tools:
                    "name": "PATH",
                    "value": "\$PATH:\${command:cmake.launchTargetDirectory}"
                },
                {
                    "name": "OTHER_VALUE",
                    "value": "Something something"
                }
            ],
            "externalConsole": true,
            "MIMode": "gdb",
            "stopAtConnect": false,
            "setupCommands": [
                {
                    "description": "Enable pretty-printing for gdb",
                    "text": "-enable-pretty-printing",
                    "ignoreFailures": true
                }
            ]
        }
    ]
}
EOF
        fi
    fi
    if [[ $(uname) =~ CYGWIN ]]; then
        exec vscode .
    else
        # bug: include paths don't get resolved properly when opening a project via symbolic links
        cd "$(readlink -f ".")"
        exec code .
    fi
fi





if test -e preconf.sh; then . preconf.sh; fi

if [[ "$cmd" == "reconf" ]]; then
    rm -fv "$BUILDDIR/CMakeCache.txt" "$BUILDDIR-dbg/CMakeCache.txt" "$BUILDDIR-vscode/CMakeCache.txt"
fi

JARG="-j"
if [[ -n "${DEBUG:-}" ]]; then
    JARG=""
fi
JARG=""

# Windows: assume running under Cygwin
if [[ $(uname) =~ CYGWIN ]]; then
    # configure CMake project
    cmake -S . -B "$(cmake_path "$BUILDDIR")" "-DCMAKE_TOOLCHAIN_FILE=$TCFILE" -DVCPKG_TARGET_TRIPLET=$VCPKG_DEFAULT_TRIPLET \
        ${TRACE:+--trace} ${CONF_ARGS:-}

    # just start Visual Studio?
    if [[ "$cmd" == "vs" ]]; then
        if test -e "$BUILDDIR/$PROJECT_NAME.sln"; then
            exec cygstart "$BUILDDIR/$PROJECT_NAME.sln"
        else
            exec cygstart "$BUILDDIR/"*".sln"
        fi
    fi

    cd "$BUILDDIR"

    # read project-specific vcpkg.sh config
    if test -e "$SOURCEDIR/postconf.sh"; then . "$SOURCEDIR/postconf.sh"; fi

    if [[ "$cmd" != "rel" ]]; then
        # Debug build
        cmake --build . --config Debug ${DEBUG:+-v} $JARG --parallel
        # Debug tests
        if [[ -z "${SKIP_TESTS:-}" ]]; then
            ! test -f CTestTestfile.cmake || ctest -C Debug $JARG || ctest -C Debug --rerun-failed --output-on-failure
        fi
    fi

    # skipt Release build and packaging if only dbg requested
    if [[ "$cmd" == "dbg" ]]; then
        exit 0
    fi

    # build Release
    cmake --build . --config Release ${DEBUG:+-v} $JARG --parallel
    # test Release
    if [[ -z "${SKIP_TESTS:-}" ]]; then
        ! test -f CTestTestfile.cmake || ctest -C Release $JARG || ctest -C Release --rerun-failed --output-on-failure
    fi
    # if [[ "$cmd" == "install" ]]; then
    #     cmake --install . --config Release
    #     cmake --install . --config Debug
    # fi

    # Release packaging
    if test -e CPackConfig.cmake; then
        cpack . -C Release # --prefix "$(cmake_path "$DEVLIBS_INST_PREFIX")"
        cp -fv $PROJECT_NAME-*.msi $USERPROFILE/Downloads/.
    fi
else
    cmake -S . -B "$(cmake_path "$BUILDDIR-dbg")" "-DCMAKE_TOOLCHAIN_FILE=$TCFILE" -DVCPKG_TARGET_TRIPLET=$VCPKG_DEFAULT_TRIPLET -DCMAKE_BUILD_TYPE=Debug
        #-DCMAKE_OBJCXX_COMPILER=clang++ -DCMAKE_CXX_COMPILER=clang++  
    cd "$BUILDDIR-dbg"
    if test -e "$SOURCEDIR/postconf.sh"; then . "$SOURCEDIR/postconf.sh"; fi
    cmake --build . ${DEBUG:+-v} $JARG
    ! test -f CTestTestfile.cmake || ctest || ctest --rerun-failed --output-on-failure

    if [[ "$cmd" == "dbg" ]]; then
#        file=$2
#        if [[ "$file" =~ /cpp/vst/([^/]+)/ ]]; then
#            exec gdb --args "$BUILDDIR-dbg/bin/Debug/validator" "$BUILDDIR-dbg/VST3/Debug/${BASH_REMATCH[1]}.vst3"
#        fi
#        echo "don't know how to launch debugger for: $file" >&2
        exit 88
    fi

    cd $SOURCEDIR
    cmake -S . -B "$(cmake_path "$BUILDDIR")" "-DCMAKE_TOOLCHAIN_FILE=$TCFILE" -DVCPKG_TARGET_TRIPLET=$VCPKG_DEFAULT_TRIPLET -DCMAKE_BUILD_TYPE=Release
    cd "$BUILDDIR"
    if test -e "$SOURCEDIR/postconf.sh"; then . "$SOURCEDIR/postconf.sh"; fi
    cmake --build . ${DEBUG:+-v} $JARG
    ! test -f CTestTestfile.cmake || ctest || ctest --rerun-failed --output-on-failure
fi

