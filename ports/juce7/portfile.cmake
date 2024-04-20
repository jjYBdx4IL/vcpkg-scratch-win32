file(READ "${CMAKE_CURRENT_LIST_DIR}/vcpkg.json" _vcpkg_json)
string(JSON PKG_VER GET "${_vcpkg_json}" "version-semver")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO juce-framework/JUCE
    REF ${PKG_VER}
    SHA512 9f29fa0bb8d6246770a28c6aa537dba213fcc2f38a6fac2765a482e509a1e0956d7a1c465202bfa1f558e12947a13ed2e15c7becce1c269260e1bde4c152713d
    HEAD_REF master
)

include(${CMAKE_CURRENT_LIST_DIR}/../juce/portfile.inc.cmake)
