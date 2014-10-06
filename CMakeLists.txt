cmake_minimum_required(VERSION 2.8)
list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")

project(Bpp Fortran)

include(TestFortType)

configure_file(include/config.bpp.sh.in config.bpp.sh @ONLY)

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
		"${CMAKE_CURRENT_BINARY_DIR}/config.bpp.sh"
	DESTINATION include
)

export(PACKAGE Bpp)
get_filename_component(BPP_PREFIX ${CMAKE_CURRENT_BINARY_DIR} REALPATH)
set(BPP_EXE
configure_file(cmake/BppConfig.cmake.in "${PROJECT_BINARY_DIR}/BppConfig.cmake" @ONLY)

# get_filename_component(BPP_PREFIX ${CMAKE_INSTALL_PREFIX} REALPATH)
# configure_file(cmake/BppConfig.cmake.in "${PROJECT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/BppConfig.cmake" @ONLY)
# install(FILES
#     "${PROJECT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/BppConfig.cmake"
#     DESTINATION "${INSTALL_CMAKE_DIR}")
# install(EXPORT Bpp DESTINATION "${INSTALL_CMAKE_DIR}")