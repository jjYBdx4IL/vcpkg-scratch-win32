file(READ "${CMAKE_CURRENT_LIST_DIR}/vcpkg.json" _vcpkg_json)
string(JSON PKG_VER GET "${_vcpkg_json}" "version-semver")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO juce-framework/JUCE
    REF ${PKG_VER}
    SHA512 2ca0d143ae1106271f6b1d6542e5388d5c57d471de5c9cac1f09b06d2de0662c03b354dea83860008526ec70cc0843115ab546481ce9af0a2c3f298adc02b328
    HEAD_REF master
)

include(${CMAKE_CURRENT_LIST_DIR}/../juce/portfile.inc.cmake)
