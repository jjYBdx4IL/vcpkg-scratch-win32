if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    message(FATAL_ERROR "static builds not supported")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ImageMagick/ImageMagick
    REF 4c0b7d25daf11131af48820b2aa6cc0b1cf11a9e
    SHA512 f97f6fe514b06bd9b9fed38b5b29c4ff939fea6a71c38006201bbf08cdffb073279e488fe32466446e0ae1e7f51029aa21011f97c6936a0bd550529653739776
    HEAD_REF main
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

include(ProcessorCount)
ProcessorCount(NCPUS)

macro(to_cyg_path _path_in _path_out)
    execute_process(
        COMMAND "${MSYS_ROOT}/usr/bin/cygpath.exe" "${_path_in}"
        OUTPUT_VARIABLE ${_path_out}
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
endmacro(to_cyg_path)


macro(build cfg)
    set(configure_args "--disable-docs --disable-openmp")
    set(make_args "-j${NCPUS}")
    set(CFG_INST_PREFIX "${CURRENT_PACKAGES_DIR}")
    set(LIBNAME imagick)
    if("${cfg}" STREQUAL "dbg")
        set(CFG_INST_PREFIX "${CURRENT_PACKAGES_DIR}/debug")
        set(make_args "CFLAGS=-g CXXFLAGS=-g ${make_args}")
        set(LIBNAME imagickd)
    endif()

    to_cyg_path("${CFG_INST_PREFIX}" CYG_INST_PREFIX)

    # configure
    vcpkg_execute_required_process(
        COMMAND "${SHELL}" -c "./configure --prefix=\"${CYG_INST_PREFIX}\" ${configure_args}"
        WORKING_DIRECTORY ${SOURCE_PATH}
        LOGNAME configure-${TARGET_TRIPLET}-${cfg}
    )

    set(OUTPUT_DIR ${SOURCE_PATH})

    # build
    vcpkg_execute_required_process(
        COMMAND "${SHELL}" -c "make ${make_args} && make install"
        WORKING_DIRECTORY ${OUTPUT_DIR}
        LOGNAME build-${TARGET_TRIPLET}-${cfg}
    )

    # create library
    vcpkg_execute_required_process(
        COMMAND "${SHELL}" -c "shopt -s globstar && gcc -shared -o ${LIBNAME}.dll -Wl,--output-def,${LIBNAME}.def **/*.o -lstdc++ -lgdi32"
        WORKING_DIRECTORY ${OUTPUT_DIR}
        LOGNAME builddef-${TARGET_TRIPLET}-${cfg}
    )
    vcpkg_execute_required_process(
        COMMAND "${SHELL}" -c "lib /def:${LIBNAME}.def /out:${LIBNAME}.lib /machine:x64"
        WORKING_DIRECTORY ${OUTPUT_DIR}
        LOGNAME buildimplib-${TARGET_TRIPLET}-${cfg}
    )
    
    # copy library
    file(INSTALL ${OUTPUT_DIR}/${LIBNAME}.dll DESTINATION ${CFG_INST_PREFIX}/bin)
    file(INSTALL ${OUTPUT_DIR}/${LIBNAME}.lib DESTINATION ${CFG_INST_PREFIX}/lib)

    # clean up
    vcpkg_execute_required_process(
        COMMAND "${SHELL}" -c "make clean"
        WORKING_DIRECTORY ${OUTPUT_DIR}
        LOGNAME clean-${TARGET_TRIPLET}-${cfg}
    )
endmacro(build)

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
build(dbg)
build(rel)

file(GLOB INCDIR "${CURRENT_PACKAGES_DIR}/include/ImageMagick*")
if("${INCDIR}" STREQUAL "")
    message(FATAL_ERROR "include dir not found (${INCDIR})")
endif()
file(RENAME "${INCDIR}" "${CURRENT_PACKAGES_DIR}/include/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/doc")

# move exes
file(GLOB EXES "${CURRENT_PACKAGES_DIR}/bin/*.exe")
foreach(EXE ${EXES})
    file(INSTALL "${EXE}" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
    file(REMOVE "${EXE}")
endforeach()

file(GLOB FILES "${CURRENT_PACKAGES_DIR}/debug/bin/*.exe")
foreach(FILE ${FILES})
    file(REMOVE "${FILE}")
endforeach()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/${PORT}Config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
