if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    message(FATAL_ERROR "static builds not supported")
endif()

file(READ "${CMAKE_CURRENT_LIST_DIR}/vcpkg.json" _vcpkg_json)
string(JSON _ver_string GET "${_vcpkg_json}" "version-semver")

set(DL_URL "https://pari.math.u-bordeaux.fr/pub/pari/unix/pari-${_ver_string}.tar.gz")

vcpkg_download_distfile(ARCHIVE
    URLS "${DL_URL}"
    FILENAME "pari-${_ver_string}.tar.gz"
    SHA512 0eb8c0100d76fb8f29fd29e6a49e9534b9a4d90e1869820dbfddd57fe444f0e83909947331823157a67be31f71a5d26fa1224f72ce3f9e5197db0194c417b9b9
)
vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${_ver_string}
)

if(WIN32)
    vcpkg_acquire_msys(MSYS_ROOT
            DIRECT_PACKAGES
                "https://repo.msys2.org/msys/x86_64/binutils-2.37-5-x86_64.pkg.tar.zst"
                32129cf97b53d5f6d87b42f17643e9dfc2e41b9ab4e4dfdc10e69725a9349bb25e57e0937e7504798cae91f7a88e0f4f5814e9f6a021bb68779d023176d2f311
                "https://repo.msys2.org/msys/x86_64/diffutils-3.8-2-x86_64.pkg.tar.zst"
                ee74e457c417d6978b3185f2fb8e15c9c30ecfc316c2474d69c978e7eb2282a3bd050d68dbf43d694cb5ab6f159b0e7ca319d01f8192071d82a224dde87d69b5
                "https://repo.msys2.org/msys/x86_64/gcc-11.2.0-3-x86_64.pkg.tar.zst"
                78cc6a10dd8e695dcb76c0e3b1771286d9d3c13ce0a814fac9a97291baf0f24aae4ed6473130eb3bc94b0bb334bf7fcb3d0ac7a1b3f49ce718cc16d5ae77db80
                "https://repo.msys2.org/msys/x86_64/isl-0.22.1-1-x86_64.pkg.tar.xz"
                f4db50d00bad0fa0abc6b9ad965b0262d936d437a9faa35308fa79a7ee500a474178120e487b2db2259caf51524320f619e18d92acf4f0b970b5cbe5cc0f63a2
                "https://repo.msys2.org/msys/x86_64/make-4.3-3-x86_64.pkg.tar.zst"
                1d991bfc2f076c8288023c7dd71c65470ad852e0744870368a4ab56644f88c7f6bbeca89dbeb7ac8b2719340cfec737a8bceae49569bbe4e75b6b8ffdcfe76f1
                "https://repo.msys2.org/msys/x86_64/mpc-1.2.1-1-x86_64.pkg.tar.zst"
                31d9cd84bbd0b83ffc77ff0b0356d2c1e3dd8880e9f73f09c5140442c1ed17b93af08804038bd3cd1f90ac1e4cfe52bfeac1fe0b349ed5699088b7aa8420e550
                "https://repo.msys2.org/msys/x86_64/msys2-runtime-devel-3.3.4-2-x86_64.pkg.tar.zst"
                dd0ed9d1c4561e2ceaad5218e6d153e55c854a0cdd0b378bb604b43264a3692c9bb274c359bf62b383b520bb7f8cb12f269b825901adbff5ad22338758d3ebb7
                "https://repo.msys2.org/msys/x86_64/msys2-w32api-headers-9.0.0.6214.acc9b9d9e-1-x86_64.pkg.tar.zst"
                1f8cca80aa63f59e6b2e2e6cc723acbaf9644c0cd4d337177b55ed3979a6bd2a76e37084d6940a82d9365154ffd5012b6058a2e919245d4992447d9dc71ac892
                "https://repo.msys2.org/msys/x86_64/msys2-w32api-runtime-9.0.0.6214.acc9b9d9e-1-x86_64.pkg.tar.zst"
                753fe32b4bf3a9feac755e52525aac5d73e6173d6c7fe5cf3e00463b36e4fd788c5814fd41b91310fee143e515d40e8145595ce6f509bc82b62c032ba489a1bd
                "https://repo.msys2.org/msys/x86_64/windows-default-manifest-6.4-1-x86_64.pkg.tar.xz"
                0701ee672816dd6babc1c08370e2fe88e49936a2786d09683c7baf02f411f3dffdd63a0899d3f5a6e34ec57ef4d050626fa878bd2da08d362dc99b90201c3dcd
                "https://repo.msys2.org/msys/x86_64/zlib-1.2.11-1-x86_64.pkg.tar.xz"
                b607da40d3388b440f2a09e154f21966cd55ad77e02d47805f78a9dee5de40226225bf0b8335fdfd4b83f25ead3098e9cb974d4f202f28827f8468e30e3b790d
    )
    vcpkg_add_to_path("${MSYS_ROOT}/usr/bin")
    set(SHELL "${MSYS_ROOT}/usr/bin/bash.exe")
endif()

# config script doesn't know msys, fake cygwin:
vcpkg_execute_required_process(
    COMMAND "${SHELL}" -c "sed -i config/arch-osname -e 's:cygwin\\*):cygwin*|msys*):'"
    WORKING_DIRECTORY ${SOURCE_PATH}
    LOGNAME patch-${TARGET_TRIPLET}
)

include(ProcessorCount)
ProcessorCount(NCPUS)

set(LAST_OUTPUT_DIR "")

macro(build cfg)
    set(configure_args)
    set(CFG_INST_PREFIX "${CURRENT_PACKAGES_DIR}")
    set(LIBNAME pari)
    if("${cfg}" STREQUAL "dbg")
        #set(configure_args "-g")
        set(CFG_INST_PREFIX "${CURRENT_PACKAGES_DIR}/debug")
        set(LIBNAME parid)
    endif()

    # clean up previous build, keep last build for inspection
    if(NOT ("${LAST_OUTPUT_DIR}" STREQUAL ""))
        file(REMOVE_RECURSE "${LAST_OUTPUT_DIR}")
    endif()

    # configure
    vcpkg_execute_required_process(
        COMMAND "${SHELL}" -c "./Configure ${configure_args}"
        WORKING_DIRECTORY ${SOURCE_PATH}
        LOGNAME configure-${TARGET_TRIPLET}-${cfg}
    )

    # get output dir
    file(GLOB_RECURSE OUTPUT_DIR "${SOURCE_PATH}/paricfg.h")
    if (NOT OUTPUT_DIR)
        message(FATAL_ERROR "failed to determine output directory")
    endif()
    get_filename_component(OUTPUT_DIR ${OUTPUT_DIR} DIRECTORY)
    set(LAST_OUTPUT_DIR "${OUTPUT_DIR}")

    vcpkg_execute_required_process(
        COMMAND "${SHELL}" -c "sed -i Makefile -e 's#-Wl,--out-implib#-Wl,--output-def,libpari.def -Wl,--out-implib#'"
        WORKING_DIRECTORY ${OUTPUT_DIR}
        LOGNAME patchmakefiledef-${TARGET_TRIPLET}-${cfg}
    )

    if("${cfg}" STREQUAL "dbg")
        vcpkg_execute_required_process(
            COMMAND "${SHELL}" -c "sed -i Makefile -e 's#-O3 -Wall -fno-strict-aliasing -fomit-frame-pointer#-O2 -g#'"
            WORKING_DIRECTORY ${OUTPUT_DIR}
            LOGNAME patchdbgmakefile-${TARGET_TRIPLET}-${cfg}
        )
    endif()

    # build
    vcpkg_execute_required_process(
        COMMAND "${SHELL}" -c "make gp -j${NCPUS}"
        WORKING_DIRECTORY ${OUTPUT_DIR}
        LOGNAME build-${TARGET_TRIPLET}-${cfg}
    )

    # create library
    # vcpkg_execute_required_process(
    #     COMMAND "${SHELL}" -c "gcc -shared -o ${LIBNAME}.dll -Wl,--output-def,${LIBNAME}.def *.o"
    #     WORKING_DIRECTORY ${OUTPUT_DIR}
    #     LOGNAME build-${TARGET_TRIPLET}-${cfg}
    # )
    vcpkg_execute_required_process(
        COMMAND "${SHELL}" -c "lib /def:libpari.def /out:${LIBNAME}.lib /machine:x64"
        WORKING_DIRECTORY ${OUTPUT_DIR}
        LOGNAME build-${TARGET_TRIPLET}-${cfg}
    )
    
    # copy library
    file(MAKE_DIRECTORY ${CFG_INST_PREFIX}/bin)
    file(RENAME ${OUTPUT_DIR}/libpari.dll ${CFG_INST_PREFIX}/bin/${LIBNAME}.dll)
    file(MAKE_DIRECTORY ${CFG_INST_PREFIX}/lib)
    file(RENAME ${OUTPUT_DIR}/${LIBNAME}.lib ${CFG_INST_PREFIX}/lib/${LIBNAME}.lib)

    # copy generated headers
    if("${cfg}" STREQUAL "rel")
        file(GLOB GEN_HEADERS "${OUTPUT_DIR}/*.h")
        foreach(GEN_HEADER ${GEN_HEADERS})
            file(INSTALL "${GEN_HEADER}" DESTINATION "${CFG_INST_PREFIX}/include/${PORT}")
        endforeach()
    endif()
endmacro(build)

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/include/${PORT}")
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/${PORT}")
build(dbg)
build(rel)

# copy static headers
file(COPY "${SOURCE_PATH}/src/headers/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/${PORT}Config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
