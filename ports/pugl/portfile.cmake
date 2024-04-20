vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lv2/pugl
    REF e33b2f6b0cea6d6263990aa9abe6a69fdfba5973
    SHA512 5565cd06c67483ff5b2120ace400e0c2ba7fab5b246b8e1d7a22fa3269d1aa6086fa210d92ca8efa5d70b6b18a314db5d47669126e2f4d8e6db690a04b0a2fe6
    HEAD_REF main
# allow sw renderer fallback on Mac:
#    REPO jjYBdx4IL/pugl
#    REF 92ab3d5663175fd4c2e275b7e8986d26b3395ef3
#    SHA512 884b88f8b6e19ba990c80860a04d8e16a33795e8922521175c5e21a2d3f112b58c5352e584c067e53e2d3341271acb303f9fa959f6326987266a2e769e3ccb8f
#    HEAD_REF swglfallback
)

if(VCPKG_TARGET_IS_OSX)
    vcpkg_replace_string("${SOURCE_PATH}/test/meson.build" "c_warnings +" "")
endif()

if(DEFINED ENV{VULKAN_SDK})
    vcpkg_add_to_path($ENV{VULKAN_SDK}/bin)
endif()

set(LIBRARY_TYPE ${VCPKG_LIBRARY_LINKAGE})
if (LIBRARY_TYPE STREQUAL "dynamic")
    set(LIBRARY_TYPE "shared")
endif(LIBRARY_TYPE STREQUAL "dynamic")

vcpkg_configure_meson(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        --default-library=${LIBRARY_TYPE}
        -Ddocs=disabled
    OPTIONS_DEBUG
        -Doptimization=g
        -Dbuildtype=debug
)

vcpkg_install_meson()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(RENAME ${CURRENT_PACKAGES_DIR}/include/pugl-0/pugl ${CURRENT_PACKAGES_DIR}/include/pugl)
file(COPY ${CURRENT_PACKAGES_DIR}/include/puglpp-0/pugl/ DESTINATION ${CURRENT_PACKAGES_DIR}/include/pugl)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/pugl-0)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/puglpp-0)

configure_file("${SOURCE_PATH}/COPYING" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
file(COPY "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
