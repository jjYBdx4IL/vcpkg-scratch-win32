file(READ "${CMAKE_CURRENT_LIST_DIR}/vcpkg.json" _vcpkg_json)
string(JSON PANDOC_VER GET "${_vcpkg_json}" "version")

if("${TARGET_TRIPLET}" MATCHES x64-windows.*)
    set(DL_URL "https://github.com/jgm/pandoc/releases/download/${PANDOC_VER}/pandoc-${PANDOC_VER}-windows-x86_64.zip")
    set(HASH 070ac55e655e84a91a873019cd5eb571e4bf0dc2474f65fff1f5ff26ee514de60fc2bea5b64489d9b26f3393b8d4e659966c1f1c5196df8c96fd8af40a5d2e81)
else()
    message(FATAL_ERROR "${VCPKG_TARGET_TRIPLET} not supported")
endif()

vcpkg_download_distfile(ARCHIVE
    URLS "${DL_URL}"
    FILENAME "pandoc-${PANDOC_VER}-windows-x86_64.zip"
    SHA512 ${HASH}
)
vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${PANDOC_VER}
)

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/COPYRIGHT.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/pandocConfig.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/include/${PORT}")
file(TOUCH "${CURRENT_PACKAGES_DIR}/include/${PORT}/.empty")


file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
file(INSTALL "${SOURCE_PATH}/pandoc.exe" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")

