file(READ "${CMAKE_CURRENT_LIST_DIR}/vcpkg.json" _vcpkg_json)
string(JSON version GET "${_vcpkg_json}" "version")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO luceneplusplus/LucenePlusPlus
    REF rel_${version}
    SHA512 fdc4ce5d55b05d8a1fa62bf749e2e428b8beec66847524f632b806d10ec7c969ca7d3c556804d2ce4b7cdf05db4f3c5613bde41aae53df9fe574d3046d448bf1
    HEAD_REF master
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(LUCENE_BUILD_SHARED OFF)
    set(LUCENE_USE_STATIC_BOOST_LIBS ON)
else()
    set(LUCENE_BUILD_SHARED ON)
    set(LUCENE_USE_STATIC_BOOST_LIBS OFF)
endif()

configure_file("${CMAKE_CURRENT_LIST_DIR}/install.cmake" "${SOURCE_PATH}/install.cmake" @ONLY)
configure_file("${CMAKE_CURRENT_LIST_DIR}/Config.cmake.in" "${SOURCE_PATH}/Config.cmake.in" COPYONLY)
file(APPEND "${SOURCE_PATH}/CMakeLists.txt" "\ninclude(install.cmake)\n")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DLUCENE_BUILD_SHARED=${LUCENE_BUILD_SHARED}
        -DLUCENE_USE_STATIC_BOOST_LIBS=${LUCENE_USE_STATIC_BOOST_LIBS}
        -DENABLE_TEST=OFF
        -DENABLE_DEMO=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake)
file(RENAME "${CURRENT_PACKAGES_DIR}/share/${PORT}/lucene++" "${CURRENT_PACKAGES_DIR}/share/lucene++")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/pkgconfig")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig")

vcpkg_fixup_pkgconfig()

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/cmake")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_copy_pdbs()

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/lucene++/lucene++Targets.cmake" "\${VCPKG_IMPORT_PREFIX}/include;" "")

#file(COPY "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
