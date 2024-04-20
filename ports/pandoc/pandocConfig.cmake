get_filename_component(PACKAGE_PREFIX_DIR "${CMAKE_CURRENT_LIST_DIR}/../../" ABSOLUTE)
set(PANDOC_EXE "${PACKAGE_PREFIX_DIR}/tools/pandoc/pandoc")

macro(pandoc_convert SOURCE OUTPUT)
    if(NOT DEFINED PANDOC_EXE)
        message(FATAL_ERROR "pandoc not enabled")
    endif()
    add_custom_command(
        OUTPUT "${CMAKE_BINARY_DIR}/${OUTPUT}"
        COMMAND "${PANDOC_EXE}" --ascii "${CMAKE_CURRENT_SOURCE_DIR}/${SOURCE}" -o "${CMAKE_BINARY_DIR}/${OUTPUT}"
        DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/${SOURCE}"
        VERBATIM
    )
endmacro()

macro(pandoc_convert_standalone SOURCE OUTPUT)
    if(NOT DEFINED PANDOC_EXE)
        message(FATAL_ERROR "pandoc not enabled")
    endif()
    add_custom_command(
        OUTPUT "${CMAKE_BINARY_DIR}/${OUTPUT}"
        COMMAND "${PANDOC_EXE}" -s "${CMAKE_CURRENT_SOURCE_DIR}/${SOURCE}" -o "${CMAKE_BINARY_DIR}/${OUTPUT}"
        DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/${SOURCE}"
        VERBATIM
    )
endmacro()
