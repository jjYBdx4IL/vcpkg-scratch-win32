vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO memononen/fontstash
    REF b5ddc9741061343740d85d636d782ed3e07cf7be
    SHA512 5a54045136946f625fca86d0399fa0a679a781ee869e74a66e0fbcaaba7debf94268baed98d85b5f94916c660b2f2d89f9c48b75d5731403321651cfc73b8aaa
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/fontstashConfig.cmake DESTINATION ${SOURCE_PATH})

file(GLOB STB_SRCS ${SOURCE_PATH}/src/stb_*)
if(STB_SRCS)
    file(REMOVE_RECURSE ${STB_SRCS})
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include
                    ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")