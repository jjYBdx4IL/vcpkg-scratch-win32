file(READ "${CMAKE_CURRENT_LIST_DIR}/vcpkg.json" _vcpkg_json)
string(JSON WIX_VER GET "${_vcpkg_json}" "version")

if("${TARGET_TRIPLET}" MATCHES x64-windows.*)
    set(DL_URL "https://github.com/wixtoolset/wix3/releases/download/wix3141rtm/wix314-binaries.zip")
    set(HASH ff58d224e545722eb794d413c541ad483ab834f9ce92e2528fe8aeb645717ab077db833ae783e1a31ad9e50803eb80fdc9efcda72535493a3f0faea4aa3ba36d)
else()
    message(FATAL_ERROR "${VCPKG_TARGET_TRIPLET} not supported")
endif()

vcpkg_download_distfile(ARCHIVE
    URLS "${DL_URL}"
    FILENAME "wix3-${WIX_VER}-windows-x86_64.zip"
    SHA512 ${HASH}
)
vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${WIX_VER}
    NO_REMOVE_ONE_LEVEL
)

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/wix3Config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/include/${PORT}")
file(TOUCH "${CURRENT_PACKAGES_DIR}/include/${PORT}/.empty")

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin")
file(INSTALL "${SOURCE_PATH}/" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin")

