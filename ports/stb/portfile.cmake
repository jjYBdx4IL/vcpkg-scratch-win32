vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nothings/stb
    REF ae721c50eaf761660b4f90cc590453cdb0c2acd0 # committed on 2024-02-13
    SHA512 2eaba0dfaaa0386fa0994c38724ccaf19ac2d634ee7220bd22ebf98065518df4bfa2b3ec4cd16eee7fb4b4d733633e38ffebda670d0f41d3f1cb8fbecaa34f7e
    HEAD_REF master
)

file(GLOB HEADER_FILES "${SOURCE_PATH}/*.h" "${SOURCE_PATH}/stb_vorbis.c")
file(COPY ${HEADER_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/include")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/FindStb.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
