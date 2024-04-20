vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO juce-framework/JUCE
    REF 2f980209cc4091a4490bb1bafc5d530f16834e58
    SHA512 0ef05c3900efe8942575f142ba131e4c6cb841f3e8478b1a50220cf4ffdbc82f359e4a83f3410fa7359f9beefc4a4cfe74debba314addc235699891ff3326145
    HEAD_REF master
)

include(${CMAKE_CURRENT_LIST_DIR}/portfile.inc.cmake)
