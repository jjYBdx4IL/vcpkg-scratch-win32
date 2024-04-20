cmake_minimum_required(VERSION 3.11)
project(nanovg C)

find_path(STB_INCLUDES stb_image.h include)

set(NANOVG_SOURCES src/nanovg.c)
set(NANOVG_HEADERS src/nanovg.h src/nanovg_gl.h src/nanovg_gl_utils.h)
add_library(nanovg STATIC ${NANOVG_SOURCES} ${NANOVG_HEADERS})
set_target_properties(nanovg PROPERTIES PUBLIC_HEADER "${NANOVG_HEADERS}")
target_include_directories(nanovg PRIVATE ${STB_INCLUDES})

if(CMAKE_BUILD_TYPE STREQUAL "Debug")
  # disable STB build so we can use soil2, which includes an enhanced variant:
  target_compile_definitions(nanovg PRIVATE DEBUG NVG_NO_STB)
else()
  target_compile_definitions(nanovg PRIVATE NDEBUG NVG_NO_STB)
endif()

install(TARGETS nanovg
  EXPORT nanovgTargets
  RUNTIME DESTINATION bin
  ARCHIVE DESTINATION lib
  LIBRARY DESTINATION lib
  PUBLIC_HEADER DESTINATION include)

install(EXPORT nanovgTargets
  FILE nanovgTargets.cmake
  NAMESPACE nanovg::
  DESTINATION share/nanovg)

install(FILES
  ${CMAKE_CURRENT_SOURCE_DIR}/nanovgConfig.cmake
  DESTINATION share/nanovg)
