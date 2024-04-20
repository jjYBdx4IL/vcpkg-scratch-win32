vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO glfw/glfw
    REF 955fbd9d265fa95adf9cb94896eb9a516aa50420
    SHA512 7c17a11cec3d7ea566086e433e67843b628db4355e37fc3f2de6511f95107c7f8a31d244a1dfa92d99d5934ccc81a13bb7aabcca8099d140080dbbfea473daef
    HEAD_REF master
)

if(VCPKG_TARGET_IS_LINUX)
    message(
"GLFW3 currently requires the following libraries from the system package manager:
    xinerama
    xcursor
    xorg
    libglu1-mesa
These can be installed on Ubuntu systems via sudo apt install libxinerama-dev libxcursor-dev xorg-dev libglu1-mesa-dev")
endif()

message(WARNING "disabling opengl hardware acceleration for MacOS")
vcpkg_replace_string("${SOURCE_PATH}/src/nsgl_context.m" "ADD_ATTRIB(NSOpenGLPFAAccelerated);"  "ADD_ATTRIB(NSOpenGLPFARendererID);ADD_ATTRIB(kCGLRendererGenericFloatID);")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DGLFW_BUILD_EXAMPLES=OFF
        -DGLFW_BUILD_TESTS=OFF
        -DGLFW_BUILD_DOCS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/glfw3)

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_copy_pdbs()