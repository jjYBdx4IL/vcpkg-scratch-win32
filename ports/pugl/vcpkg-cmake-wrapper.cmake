include(FindPackageHandleStandardArgs)
include(SelectLibraryConfigurations)

find_path(pugl_INCLUDE_DIR pugl.h PATH_SUFFIXES pugl)
get_filename_component(pugl_INCLUDE_DIR ${pugl_INCLUDE_DIR} DIRECTORY)

set(pugl_INCLUDE_DIRS ${pugl_INCLUDE_DIR})
set(pugl_LIBRARIES)

set(_libprefix "pugl_win")
set(external_LIBS "opengl32")
if(UNIX)
    set(_libprefix "libpugl_x11")
    set(external_LIBS "GL;X11")
endif()
if(APPLE)
    set(_libprefix "libpugl_mac")
    set(external_LIBS "-framework Cocoa -framework CoreVideo")
endif()

file(GLOB files "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/lib/${_libprefix}*")

foreach(file ${files})

    get_filename_component(fn "${file}" NAME)
    if("${fn}" MATCHES "^(lib)?(pugl_[a-z0-9]+(|_([a-z]+))-0)\\.[^.]*\$")
        set(libname "${CMAKE_MATCH_2}")
        set(libsu "${CMAKE_MATCH_4}")
    else()
        continue()
    endif()

    if("${libsu}" STREQUAL "")
        set(libalias "core")
    else()
        set(libalias "${libsu}")
    endif()

    unset(pugl_LIBRARY_DEBUG CACHE)
    unset(pugl_LIBRARY_RELEASE CACHE)
    find_library(pugl_LIBRARY_DEBUG NAMES ${libname} NAMES_PER_DIR PATH_SUFFIXES lib PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug" NO_DEFAULT_PATH REQUIRED)
    find_library(pugl_LIBRARY_RELEASE NAMES ${libname} NAMES_PER_DIR PATH_SUFFIXES lib PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}" NO_DEFAULT_PATH REQUIRED)

    if("${VCPKG_TARGET_TRIPLET}" MATCHES "static")
        add_library("pugl::${libalias}" STATIC IMPORTED)
        target_compile_definitions("pugl::${libalias}" INTERFACE PUGL_STATIC)
        set_target_properties("pugl::${libalias}" PROPERTIES
            IMPORTED_LOCATION_RELEASE "${pugl_LIBRARY_RELEASE}"
            IMPORTED_LOCATION_DEBUG "${pugl_LIBRARY_DEBUG}"
        )
    else()
        add_library("pugl::${libalias}" SHARED IMPORTED)
        set_target_properties("pugl::${libalias}" PROPERTIES
            IMPORTED_LOCATION_RELEASE "${pugl_LIBRARY_RELEASE}"
            IMPORTED_LOCATION_DEBUG "${pugl_LIBRARY_DEBUG}"
        )
        if(MSVC)
            set_target_properties("pugl::${libalias}" PROPERTIES
                IMPORTED_IMPLIB_RELEASE "${pugl_LIBRARY_RELEASE}"
                IMPORTED_IMPLIB_DEBUG "${pugl_LIBRARY_DEBUG}"
            )
        endif()
    endif()

    set_target_properties("pugl::${libalias}" PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${pugl_INCLUDE_DIR}"
        IMPORTED_LINK_INTERFACE_LIBRARIES "${external_LIBS}"
    )

    list(APPEND pugl_LIBRARIES "pugl::${libalias}")
endforeach()
