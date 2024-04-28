vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO jurihock/stftPitchShift
  HEAD_REF main
  REF v2.0
  SHA512 9a75e35e36502d6911313079a79e1281cc229790c6f5785ed542e8eabae5b0f7fdd03e3b930b749e7cb4dbb22ad36392ae4b33a918974542897aeda2f5c3faf1
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DVCPKG=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
  CONFIG_PATH "lib/cmake/${PORT}"
)

file(
  INSTALL "${SOURCE_PATH}/LICENSE"
  DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
  RENAME copyright
)

file(
  REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include"
)
