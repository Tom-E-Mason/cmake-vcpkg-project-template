cmake_minimum_required(VERSION 3.22)

# https://cmake.org/pipermail/cmake/2018-January/067002.html
# MUST be done before call to 'project'
get_cmake_property(vars CACHE_VARIABLES)
foreach(var ${vars})
    get_property(currentHelpString CACHE "${var}" PROPERTY HELPSTRING)
        if("${currentHelpString}" MATCHES "No help, variable specified on the command line." OR "${currentHelpString}" STREQUAL "")
            list(APPEND CL_ARGS "-D${var}=${${var}}")
        endif()
endforeach()

project(top
    LANGUAGES CXX
)

list(APPEND
    CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/cmake
)

include(ExternalProject)
include(vcpkg_utilities)

vcpkg_config()

ExternalProject_Add(main_project
    DEPENDS vcpkg ${VCPKG_DEPENDENCIES}
    SOURCE_DIR "${CMAKE_CURRENT_LIST_DIR}/src"
    INSTALL_COMMAND ""
    CMAKE_ARGS ${CL_ARGS};
               --no-warn-unused-cli;
               -DCMAKE_TOOLCHAIN_FILE=${VCPKG_DIR}/scripts/buildsystems/vcpkg.cmake
)
