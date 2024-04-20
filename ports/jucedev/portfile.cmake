vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO juce-framework/JUCE
    REF 220fa03eb0d73a11860fd133b426d05db1ef20ce
    SHA512 695ef2076fc25f9a2ffde8cbbc5b24d4bacb0a049e79f925c2511b5e1438606e56fd51a979f07012fba7d46ffcbfeac3a78eb9428e8c13ab6a5411c234315f51
    HEAD_REF develop
)

include(${CMAKE_CURRENT_LIST_DIR}/../juce/portfile.inc.cmake)
