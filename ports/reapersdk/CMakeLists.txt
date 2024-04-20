cmake_minimum_required(VERSION 3.11)
project(reapersdk C)

file(GLOB HEADERS "sdk/*.h")

install(FILES ${HEADERS}
        DESTINATION include/${PROJECT_NAME})

# install(EXPORT ${PROJECT_NAME}Targets
#   FILE ${PROJECT_NAME}Targets.cmake
#   NAMESPACE ${PROJECT_NAME}::
#   DESTINATION share/${PROJECT_NAME})

install(FILES
  ${CMAKE_CURRENT_SOURCE_DIR}/${PROJECT_NAME}Config.cmake
  DESTINATION share/${PROJECT_NAME})
