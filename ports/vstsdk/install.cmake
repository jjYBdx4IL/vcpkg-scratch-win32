include(CMakePackageConfigHelpers)
include(GNUInstallDirs)

set(ALL_TARGETS)
foreach(TGT sdk;sdk_common;sdk_hosting;base;pluginterfaces;base_ios;pluginterfaces_ios;vstgui;vstgui_support;vstgui_uidescription;vstgui_standalone)
    if(TARGET ${TGT})
        list(APPEND ALL_TARGETS ${TGT})
        get_target_property(var ${TGT} INTERFACE_INCLUDE_DIRECTORIES)
        message("${TGT}:${var}")
        message("${CMAKE_CURRENT_SOURCE_DIR}")
        if(NOT ("${var}" STREQUAL "var-NOTFOUND"))
            file(RELATIVE_PATH outvar "${CMAKE_CURRENT_SOURCE_DIR}" "${var}")
            message("outvar=${outvar}")
            set_target_properties(${TGT} PROPERTIES
                INTERFACE_INCLUDE_DIRECTORIES
                "$<INSTALL_INTERFACE:include/@PORT@/${outvar}>;$<BUILD_INTERFACE:${var}>")
        endif()
        # if("${TGT}" MATCHES "sdk(_common|_hosting)?")
        #     install(FILES $<TARGET_PDB_FILE:${TGT}> DESTINATION lib OPTIONAL)
        # endif()
    endif()
endforeach()

install(TARGETS ${ALL_TARGETS};editorhost;validator;moduleinfotool;VST3Inspector
        EXPORT ${PROJECT_NAME}Targets
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
        BUNDLE DESTINATION ${CMAKE_INSTALL_BINDIR}
        INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})

#install(FILES ${HEADER_FILES}
#        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/utils)

install(EXPORT ${PROJECT_NAME}Targets
        FILE ${PROJECT_NAME}Targets.cmake
        NAMESPACE ${PROJECT_NAME}::
        DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME})

configure_package_config_file(${CMAKE_CURRENT_SOURCE_DIR}/Config.cmake.in
        "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}Config.cmake"
        INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}
      )

write_basic_package_version_file(
    "${PROJECT_NAME}ConfigVersion.cmake"
    VERSION "@version@"
    COMPATIBILITY AnyNewerVersion)

install(
    FILES
        ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}Config.cmake
        ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME})

