vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lv2/lv2
    REF 0bcde338db1c63bbc503b4d1f6d7b55ed43154af #v1.18.10
    SHA512 6662f2b3d1dd488c145771b6338d91c67754463f6b3fb26ee5032a522f43a3412bdd87facdb5cd660280dab90689e08a8ee8d894138c945bae66af420e0f7010
    HEAD_REF master
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_install_meson()
vcpkg_fixup_pkgconfig()

set(FN "${CURRENT_PACKAGES_DIR}/bin/lv2_validate")
file(READ ${FN} content)
string(REGEX REPLACE "^#!/bin/sh" "#!/bin/bash" content "${content}")
string(REGEX REPLACE "\nLV2DIR=\"[^\"]*\"\n" "\nPREFIX=\"\$(dirname \$0)/../..\"\nLV2DIR=\"\$PREFIX/lib/lv2\"\n" content "${content}")
string(REGEX REPLACE "\nsord_validate " "\n\$PREFIX/tools/sord/sord_validate " content "${content}")
file(CONFIGURE OUTPUT ${FN} CONTENT "${content}" @ONLY NEWLINE_STYLE UNIX)

file(
    INSTALL "${CURRENT_PACKAGES_DIR}/bin/lv2_validate"
    DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}"
)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()
configure_file("${SOURCE_PATH}/COPYING" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
