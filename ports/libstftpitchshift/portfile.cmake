vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jjYBdx4IL/stftPitchShift
    REF 3983ac343cd9aa9c2380a887128ab5975c37a7da
    SHA512 64c62ebb7d8406e6830cfe0d96c5f80d3b50f5db3d9e9f059c8e7eb3b21d27288fcdafd2afb67ccb61f29b9a9c3959ab1efd83d7fa6fa196410ae8632bb33510
    HEAD_REF main
)
get_filename_component(SOURCE_PATH "D:/git/stftPitchShift" ABSOLUTE)
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS -DBUILD_EXAMPLES=OFF -DENABLE_BUILTIN=OFF -DBUILD_EXECUTABLE=OFF
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/LibStftPitchShift)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
vcpkg_copy_pdbs()
file(COPY_FILE "${SOURCE_PATH}/LICENSE" ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright)
file(COPY_FILE "${SOURCE_PATH}/cpp/StftPitchShift/pocketfft/LICENSE" ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright.pocketfft)
