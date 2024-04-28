set(VSTSDK_VER "3.7.11_build-10_2024-04-22")

string(REGEX REPLACE "^([0-9.]*)_.*\$" "\\1" version "${VSTSDK_VER}")

if(VCPKG_TARGET_IS_LINUX)
    message(
"

${PORT} requires quite a few packages from the package manager:

apt install libxcb-util-dev libxcb-cursor-dev libxcb-keysyms1-dev libxkbcommon-dev libxkbcommon-x11-dev libcairo2-dev libpango1.0-dev libgtkmm-3.0-dev libsqlite3-dev

")
endif()

vcpkg_download_distfile(
    ARCHIVE
    URLS "https://download.steinberg.net/sdk_downloads/vst-sdk_${VSTSDK_VER}.zip"
    FILENAME "vst-sdk_${VSTSDK_VER}.zip"
    SHA512 e19ff4ac0c5005b97402eddfce39e94dacd2e55f6ac8a288d5520cb48fb41dfff05188ff8ea1a4a1b1b0d6a89f558c798e8356cf9fcb68bd4e8b3431aee02932
)
vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${VSTSDK_VER}
)
set(SOURCE_PATH "${SOURCE_PATH}/vst3sdk")

## un-final some class(es)
#vcpkg_replace_string("${SOURCE_PATH}/vstgui4/vstgui/lib/platform/win32/win32frame.h" "class Win32Frame final :" "class Win32Frame :")
#vcpkg_replace_string("${SOURCE_PATH}/vstgui4/vstgui/lib/platform/win32/win32frame.cpp" "unuseD2D ();" "")
#vcpkg_replace_string("${SOURCE_PATH}/vstgui4/vstgui/lib/platform/win32/win32frame.cpp" "useD2D ();" "")
#vcpkg_replace_string("${SOURCE_PATH}/vstgui4/vstgui/lib/platform/win32/win32frame.h" "void paint (HWND hwnd);" "virtual void paint (HWND hwnd);")
#vcpkg_replace_string("${SOURCE_PATH}/vstgui4/vstgui/lib/platform/win32/win32frame.h" "~Win32Frame () noexcept;" "~Win32Frame () noexcept; virtual void fixStyle () {};")
#vcpkg_replace_string("${SOURCE_PATH}/vstgui4/vstgui/lib/platform/win32/win32frame.cpp" "RegisterDragDrop (" "fixStyle(); RegisterDragDrop (")

# allow adding options to validator via env var (-q: quiet, -e: extensive tests)
vcpkg_replace_string("${SOURCE_PATH}/cmake/modules/SMTG_AddVST3Library.cmake" "\$<TARGET_FILE:validator>" "\$<TARGET_FILE:validator> \$ENV{VALIDATOR_OPTS}")
# https://github.com/steinbergmedia/vst3sdk/issues/100
vcpkg_replace_string("${SOURCE_PATH}/cmake/modules/SMTG_AddSMTGLibrary.cmake" "string(REPLACE \"\${PLUGIN_PACKAGE_NAME}\" \"\$(TargetFileName)\" absolute_output_file_path \${absolute_output_file_path})" "")

configure_file("${CMAKE_CURRENT_LIST_DIR}/install.cmake" "${SOURCE_PATH}/install.cmake" @ONLY)
configure_file("${CMAKE_CURRENT_LIST_DIR}/Config.cmake.in" "${SOURCE_PATH}/Config.cmake.in" COPYONLY)
file(APPEND "${SOURCE_PATH}/CMakeLists.txt" "include(install.cmake)\n")
vcpkg_replace_string("${SOURCE_PATH}/CMakeLists.txt" "set(SMTG_ADD_MYPLUGINS_SRC_PATH ON)" "set(SMTG_ADD_MYPLUGINS_SRC_PATH OFF)")

set(BUILD_DIR_DEBUG "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")
set(BUILD_DIR_RELEASE "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")

set(config_opts)
list(APPEND config_opts "-DPKG_CONFIG_USE_CMAKE_PREFIX_PATH=FALSE") # don't use vcpkg libs
list(APPEND config_opts "-DSMTG_CREATE_PLUGIN_LINK=OFF")
#if(VCPKG_TARGET_IS_LINUX)
#    list(APPEND config_opts "-DCMAKE_CXX_FLAGS=-O2")
#endif()
if(VCPKG_TARGET_IS_WINDOWS)
    list(APPEND config_opts "-DSMTG_USE_STDATOMIC_H=OFF")
    #list(APPEND config_opts "-DEXPAT_LIBRARY=OFF") # force use of internal expat lib
endif()
if(VCPKG_TARGET_IS_OSX)
    execute_process(COMMAND xcodebuild -version RESULT_VARIABLE exitcode)
    if (NOT ("${exitcode}" STREQUAL "0"))
        message(STATUS "xcodebuild not found, enabling xcode command line tools hack: assuming xcode version 10")
        list(APPEND config_opts "-DXCODE_VERSION=10")
        set(ENV{XCODE_VERSION} "10")
    endif()
    list(APPEND config_opts "-DSMTG_ADD_VST3_PLUGINS_SAMPLES=OFF") # plugin validation is hanging
    vcpkg_replace_string("${SOURCE_PATH}/cmake/modules/SMTG_PlatformToolset.cmake"
        "add_compile_options(-Wsuggest-override)" "add_compile_options(-Winconsistent-missing-override -Werror=return-type -ffast-math -ffp-contract=fast)")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${config_opts}
)

vcpkg_cmake_install()

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/tools")
file(RENAME "${CURRENT_PACKAGES_DIR}/debug/bin" "${CURRENT_PACKAGES_DIR}/debug/tools/${PORT}")
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools")
file(RENAME "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/tools/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/include/${PORT}")

# includes
foreach(entry base;pluginterfaces;public.sdk;vstgui4)
    file(COPY "${SOURCE_PATH}/${entry}" DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")
endforeach()

# docs
file(COPY "${SOURCE_PATH}/doc" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

# cmake modules
vcpkg_replace_string("${SOURCE_PATH}/cmake/modules/SMTG_AddVST3Library.cmake" "CMAKE_RUNTIME_OUTPUT_DIRECTORY" "CMAKE_CURRENT_BINARY_DIR")
file(COPY "${SOURCE_PATH}/cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

# demo plugins
if(NOT VCPKG_TARGET_IS_OSX)
    file(COPY "${BUILD_DIR_DEBUG}/VST3/Debug" DESTINATION "${CURRENT_PACKAGES_DIR}/VST3")
    file(COPY "${BUILD_DIR_RELEASE}/VST3/Release" DESTINATION "${CURRENT_PACKAGES_DIR}/VST3")
endif()

file(COPY_FILE "${SOURCE_PATH}/LICENSE.txt" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright")

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

# copy pdbs
#vcpkg_copy_pdbs()
file(GLOB LIBS "${CURRENT_PACKAGES_DIR}/debug/lib/*.lib")
foreach(LIB ${LIBS})
    get_filename_component(NAME ${LIB} NAME_WLE)
    file(GLOB_RECURSE PDB "${BUILD_DIR_DEBUG}/${NAME}.pdb")
    file(COPY "${PDB}" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
endforeach()
