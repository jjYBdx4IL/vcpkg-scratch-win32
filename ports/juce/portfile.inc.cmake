file(READ "${CMAKE_CURRENT_LIST_DIR}/../${PORT}/vcpkg.json" _vcpkg_json)
string(JSON _ver_string GET "${_vcpkg_json}" "version-semver")

vcpkg_replace_string("${SOURCE_PATH}/CMakeLists.txt" "JUCE VERSION 6.1.6" "JUCE VERSION ${_ver_string}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DJUCE_BUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/JUCE-${_ver_string})

vcpkg_fixup_pkgconfig()

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools")
file(RENAME "${CURRENT_PACKAGES_DIR}/bin/JUCE-${_ver_string}" "${CURRENT_PACKAGES_DIR}/tools/${PORT}")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
else()
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin")
endif()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_copy_pdbs()

file(GLOB FILES "${CURRENT_PACKAGES_DIR}/share/${PORT}/*.cmake")
foreach(FILE ${FILES})
    vcpkg_replace_string("${FILE}" "lib/cmake/JUCE-${_ver_string}" "share/${PORT}")
    vcpkg_replace_string("${FILE}" "bin/JUCE-${_ver_string}" "tools/${PORT}")
    vcpkg_replace_string("${FILE}" "tools/${PORT}/JUCE-${_ver_string}/" "tools/${PORT}/")
endforeach()

