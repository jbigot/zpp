##############################################################################
# Copyright (c) 2013-2014, CEA
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
##############################################################################

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
