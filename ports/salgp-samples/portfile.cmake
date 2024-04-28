
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sfzinstruments/SalamanderGrandPiano
    REF 3382bf9496bba2486f5ab0de55a264d1dfc38404 # 2022-01-03
    SHA512 06423e7bf78b6ac97abde5414084f16f55c8d2999cd3215111181a89200b4fc1488246b402830eea62f97923b5bb6f61d34f2a353b0ac5e35d8edddd7d148b11
    HEAD_REF master
)

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(COPY "${SOURCE_PATH}/" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/${PORT}Config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

# fake lib installation to suppress warning
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/include/${PORT}")
file(TOUCH "${CURRENT_PACKAGES_DIR}/include/${PORT}/.empty")

file(INSTALL "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

# remove samples from source directory - there is no need for them to stay there
file(REMOVE_RECURSE "${SOURCE_PATH}/Samples")
