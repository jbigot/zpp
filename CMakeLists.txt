cmake_minimum_required(VERSION 2.8)
project(Bpp Fortran)
include(cmake/Bpp.cmake)


# in tree config

set(BPP_EXE "${CMAKE_CURRENT_SOURCE_DIR}/scripts/bpp")
configure_file(cmake/BppConfig.cmake.in "${PROJECT_BINARY_DIR}/BppConfig.cmake" @ONLY)
configure_file(cmake/Bpp.cmake "${PROJECT_BINARY_DIR}/Bpp.cmake" COPONLY)
configure_file(cmake/TestFortType.cmake "${PROJECT_BINARY_DIR}/TestFortType.cmake" COPONLY)
export(PACKAGE Bpp)



# installable config

set(BPP_EXE "${CMAKE_INSTALL_PREFIX}/bin/bpp")
configure_file(cmake/BppConfig.cmake.in "${PROJECT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/BppConfig.cmake" @ONLY)
if(WIN32 AND NOT CYGWIN)
	set(INSTALL_CMAKE_DIR CMake)
else()
	set(INSTALL_CMAKE_DIR lib/CMake/Bpp)
endif()
install(PROGRAMS scripts/bpp
	DESTINATION bin
)
install(FILES
		include/base.bpp.sh
		include/config.bpp.sh.in
		include/fortran.bpp.sh
	DESTINATION include
)
install(FILES
		cmake/Bpp.cmake
		cmake/TestFortType.cmake
		"${PROJECT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/BppConfig.cmake"
	DESTINATION "${INSTALL_CMAKE_DIR}"
)
