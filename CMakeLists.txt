cmake_minimum_required(VERSION 2.8)
# protect the project call to workaround a cmake bug
if("${CMAKE_CURRENT_SOURCE_DIR}" STREQUAL "${CMAKE_SOURCE_DIR}")
	project(Bpp Fortran)
endif()

include(cmake/Bpp.cmake)

# in tree config

set(BPP_EXE "${CMAKE_CURRENT_SOURCE_DIR}/scripts/bpp" CACHE PATH "BPP Executable")
set(BPP_CMAKE "${CMAKE_CURRENT_SOURCE_DIR}/cmake/Bpp.cmake")
set(BPP_DEFAULT_INCLUDES "${CMAKE_CURRENT_SOURCE_DIR}/include/" CACHE STRING "BPP default include path")

configure_file(cmake/BppConfig.cmake.in "${PROJECT_BINARY_DIR}/BppConfig.cmake" @ONLY)
configure_file(cmake/Bpp.cmake "${PROJECT_BINARY_DIR}/Bpp.cmake" COPYONLY)
configure_file(cmake/TestFortType.cmake "${PROJECT_BINARY_DIR}/TestFortType.cmake" COPYONLY)
export(PACKAGE Bpp)


# installable config

if(WIN32 AND NOT CYGWIN)
	set(INSTALL_CMAKE_DIR CMake)
else()
	set(INSTALL_CMAKE_DIR lib/CMake/Bpp)
endif()
set(WORK_DIR "${PROJECT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}")

set(BPP_EXE "${CMAKE_INSTALL_PREFIX}/bin/bpp")
set(BPP_CMAKE "${CMAKE_INSTALL_PREFIX}${INSTALL_CMAKE_DIR}/Bpp.cmake")
set(BPP_DEFAULT_INCLUDES "${CMAKE_INSTALL_PREFIX}/include/")

configure_file(cmake/BppConfig.cmake.in "${WORK_DIR}/BppConfig.cmake" @ONLY)
install(PROGRAMS scripts/bpp
	DESTINATION bin
)
install(FILES
		include/base.bpp.sh
		include/fortran.bpp.sh
		include/hdf5_fortran.bpp.sh
	DESTINATION include
)
install(FILES
		cmake/Bpp.cmake
		cmake/TestFortType.cmake
		"${WORK_DIR}/BppConfig.cmake"
	DESTINATION "${INSTALL_CMAKE_DIR}"
)
