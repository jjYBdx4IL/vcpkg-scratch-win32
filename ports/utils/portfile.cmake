get_filename_component(SOURCE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../../utils" ABSOLUTE)
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
vcpkg_copy_pdbs()
file(TOUCH ${CURRENT_PACKAGES_DIR}/share/utils/copyright)


