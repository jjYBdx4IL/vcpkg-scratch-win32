cmake_minimum_required(VERSION 3.11)
project(fontstash C)

set(HEADERS src/fontstash.h src/gl3corefontstash.h src/glfontstash.h)

install(FILES ${HEADERS}
        DESTINATION include)

# install(EXPORT ${PROJECT_NAME}Targets
#   FILE ${PROJECT_NAME}Targets.cmake
#   NAMESPACE ${PROJECT_NAME}::
#   DESTINATION share/${PROJECT_NAME})

install(FILES
  ${CMAKE_CURRENT_SOURCE_DIR}/${PROJECT_NAME}Config.cmake
  DESTINATION share/${PROJECT_NAME})
