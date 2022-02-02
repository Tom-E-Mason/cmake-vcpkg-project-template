
include(FetchContent)

# clones vcpkg and runs its bootstrapping script
function (get_vcpkg)

    if(${CMAKE_SYSTEM_NAME} STREQUAL "Windows")
        set(VCPKG_BINARY "vcpkg.exe")
        set(OSNAME "windows")
    elseif(${CMAKE_SYSTEM_NAME} STREQUAL "Linux")
        set(VCPKG_BINARY "vcpkg")
        set(OSNAME "linux")
    endif()

    if(${CMAKE_SIZEOF_VOID_P} EQUAL "4")
        set(PLATFORMNAME "x86")
    elseif(${CMAKE_SIZEOF_VOID_P} EQUAL "8")
        set(PLATFORMNAME "x64")
    endif()
    
    set(VCPKG_TRIPLET "${PLATFORMNAME}-${OSNAME}" PARENT_SCOPE)

    add_custom_target(COMMAND "python ${PROJECT_SOURCE_DIR}/scripts/get-vcpkg.py"
        WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
    )

    set(VCPKG_DIR "${PROJECT_SOURCE_DIR}/vcpkg")
    set(VCPKG_DIR ${VCPKG_DIR} PARENT_SCOPE)

    set(VCPKG_CMD ${VCPKG_DIR}/${VCPKG_BINARY})
endfunction()

# installs PACKAGE_NAME
function (vcpkg_install PACKAGE_NAME)
    add_custom_command(
        OUTPUT "${VCPKG_DIR}/packages/${PACKAGE_NAME}_${VCPKG_TRIPLET}/BUILD_INFO"
        COMMAND ${VCPKG_CMD} install ${PACKAGE_NAME}:${VCPKG_TRIPLET}
        WORKING_DIRECTORY ${VCPKG_DIR}
        DEPENDS vcpkg
    )
    add_custom_target(
        get${PACKAGE_NAME}
        ALL
        DEPENDS "${VCPKG_DIR}/packages/${PACKAGE_NAME}_${VCPKG_TRIPLET}/BUILD_INFO"
    )
    # need to serialize vcpkg installs, so we establish a chain of dependencies
    if(DEFINED VCPKG_PRIOR_INSTALLED)
        add_dependencies(get${PACKAGE_NAME}
            get${VCPKG_PRIOR_INSTALLED}
        )
    endif()
    set(VCPKG_PRIOR_INSTALLED ${PACKAGE_NAME} PARENT_SCOPE)
    list(APPEND VCPKG_DEPENDENCIES "get${PACKAGE_NAME}")
    set(VCPKG_DEPENDENCIES ${VCPKG_DEPENDENCIES} PARENT_SCOPE)
endfunction()

#installs packages in vcpkg.txt
function (vcpkg_packagefile FILENAME)
    file(STRINGS ${FILENAME} filelist)
    foreach(pkgname ${filelist})
        vcpkg_install(${pkgname})
    endforeach()
    set(VCPKG_DEPENDENCIES ${VCPKG_DEPENDENCIES} PARENT_SCOPE)
endfunction()