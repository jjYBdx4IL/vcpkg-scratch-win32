cmake_minimum_required(VERSION 3.11)
project(pocketfft CXX)

set(HEADERS pocketfft_hdronly.h)

add_library(pocketfft INTERFACE ${HEADERS})

include(CMakePackageConfigHelpers)
include(GNUInstallDirs)

install(FILES ${HEADERS}
        DESTINATION include)

install(TARGETS ${PROJECT_NAME}
        EXPORT ${PROJECT_NAME}Targets
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
        INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})

install(EXPORT ${PROJECT_NAME}Targets
  FILE ${PROJECT_NAME}Targets.cmake
  NAMESPACE ${PROJECT_NAME}::
  DESTINATION share/${PROJECT_NAME})

install(FILES
  ${CMAKE_CURRENT_SOURCE_DIR}/${PROJECT_NAME}Config.cmake
  DESTINATION share/${PROJECT_NAME})
