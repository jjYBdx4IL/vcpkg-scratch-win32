vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO justinfrankel/reaper-sdk
    REF 02deb819c4ba0fc1bac001c8dfff7b9dbaf408ad
    SHA512 485764eda33bc5d1a0f96a15021b28485d2ca5531d11636b0d37caa1c564a4b6d77fbfa05ec18ce17613e83ef18c37b477bcd0d373c9c00b28bebe7d2f156360
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/${PORT}Config.cmake DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include
                    ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${SOURCE_PATH}/sdk/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
