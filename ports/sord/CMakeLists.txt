cmake_minimum_required(VERSION 3.17)
project(sord C)

find_package(serd CONFIG REQUIRED)

add_library(sord
    src/sord.c
    src/syntax.c
)

file(WRITE "${CMAKE_BINARY_DIR}/sord_config.h" "")

target_include_directories(sord
    PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}" "${CMAKE_CURRENT_SOURCE_DIR}/src" "${CMAKE_BINARY_DIR}"
)

target_link_libraries(sord PUBLIC serd::serd)

set_target_properties(sord PROPERTIES
    C_STANDARD 99
    C_STANDARD_REQUIRED ON
)

target_compile_definitions(sord PRIVATE SORD_INTERNAL _CRT_SECURE_NO_WARNINGS)

if(BUILD_SHARED_LIBS)
    target_compile_definitions(sord PUBLIC SORD_SHARED)
endif()

install(
    TARGETS sord 
    EXPORT sord-targets
    INCLUDES DESTINATION include
)

if(NOT DISABLE_INSTALL_HEADERS)
    install(DIRECTORY sord DESTINATION include)
endif()

install(
    EXPORT sord-targets
    NAMESPACE sord::
    DESTINATION "${CMAKE_INSTALL_PREFIX}/share/sord"
)

file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/sord-config.cmake" [[
include(CMakeFindDependencyMacro)
find_dependency(serd CONFIG)
include("${CMAKE_CURRENT_LIST_DIR}/sord-targets.cmake")
]])

install(
    FILES "${CMAKE_CURRENT_BINARY_DIR}/sord-config.cmake"
    DESTINATION "${CMAKE_INSTALL_PREFIX}/share/sord"
)


# sord_validate
find_package(pcre2 CONFIG REQUIRED)
add_executable(sord_validate
    src/sord_validate.c
)
target_link_libraries(sord_validate PRIVATE PCRE2::8BIT PCRE2::16BIT PCRE2::32BIT PCRE2::POSIX)
target_link_libraries(sord_validate PRIVATE sord)
target_include_directories(sord_validate
    PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}" "${CMAKE_CURRENT_SOURCE_DIR}/src" "${CMAKE_BINARY_DIR}"
)
set_target_properties(sord_validate PROPERTIES
    C_STANDARD 99
    C_STANDARD_REQUIRED ON
)
target_compile_definitions(sord_validate PRIVATE SORD_INTERNAL _CRT_SECURE_NO_WARNINGS)
add_compile_definitions(sord_validate "SORD_VERSION=\"???\"")

install(
    FILES "${CMAKE_CURRENT_BINARY_DIR}/sord_validate.exe"
    DESTINATION "${CMAKE_INSTALL_PREFIX}/tools/sord/."
)

