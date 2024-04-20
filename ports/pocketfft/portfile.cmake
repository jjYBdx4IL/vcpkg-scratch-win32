vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mreineck/pocketfft
    REF daa8bb18327bc5c7d22c69428c25cf5dc64167d3
    SHA512 d212cfa34ecde2f38b789d218b5ed4fb9069e41f9d35587dd058b8af89cf22e79a1c8f8ddf2d47d794fa23a7e363cb0631b25461ae3fc9fc5d58e1bdf6356600
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/pocketfftConfig.cmake DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include
                    ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")