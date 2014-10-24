################################################################################
# Copyright (c) 2013-2014, CEA
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#  1. Redistributions of source code must retain the above copyright notice,
# this list of conditions and the following disclaimer.
#  2. Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
################################################################################

function(test_fort_type RESULT_VAR TYPE KIND)
	if(DEFINED "${RESULT_VAR}")
		return()
	endif()
	message(STATUS "Checking whether Fortran supports type ${TYPE}(KIND=${KIND})")
	set(TEST_FILE "${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/cmake_test_${RESULT_VAR}.f90")
	file(WRITE "${TEST_FILE}" "
program test_${RESULT_VAR}
  ${TYPE}(KIND=${KIND}):: tstvar
end program test_${RESULT_VAR}
")
	try_compile(COMPILE_RESULT "${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}" "${TEST_FILE}"
		OUTPUT_VARIABLE COMPILE_OUTPUT
	)
	if(COMPILE_RESULT)
		file(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeOutput.log
		"${TYPE}(KIND=${KIND}) type successfully compiled with the following output:\n"
		"${COMPILE_OUTPUT}\n")
		message(STATUS "Checking whether Fortran supports type ${TYPE}(KIND=${KIND}) -- yes")
	else()
		file(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeError.log
		"${TYPE}(KIND=${KIND}) type failed to compile with the following output:\n"
		"${COMPILE_OUTPUT}\n")
		message(STATUS "Checking whether Fortran supports type ${TYPE}(KIND=${KIND}) -- no")
	endif()
	set("${RESULT_VAR}" "${COMPILE_RESULT}" CACHE BOOL "Whether Fortran supports type ${TYPE}(KIND=${KIND})")
	mark_as_advanced("${RESULT_VAR}")
endfunction()

function(test_fort_hdf5_type RESULT_VAR TYPE KIND)
	if(DEFINED "${RESULT_VAR}")
		return()
	endif()
	find_package(HDF5)
	if(NOT "${HDF5_FOUND}")
		set("${RESULT_VAR}" "HDF5-NOTFOUND" CACHE STRING "HDF5 constant for Fortran type ${TYPE}(KIND=${KIND})")
	mark_as_advanced("${RESULT_VAR}")
		return()
	endif()
	message(STATUS "Detecting HDF5 constant for Fortran type ${TYPE}(KIND=${KIND})")
	set(TEST_FILE "${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/cmake_test_${RESULT_VAR}.f90")
	if("${TYPE}" STREQUAL "INTEGER")
		math(EXPR SIZE "8*${KIND}")
		set(H5CST "H5T_STD_I${SIZE}LE")
	elseif("${TYPE}" STREQUAL "REAL")
		math(EXPR SIZE "8*${KIND}")
		set(H5CST "H5T_IEEE_F${SIZE}LE")
	else()
		set(H5CST "HDF5_CONSTANT-NOTFOUND")
	endif()
	file(WRITE "${TEST_FILE}" "
program test_${RESULT_VAR}
  use hdf5
  ${TYPE}(KIND=${KIND}):: tstvar
  integer(HID_T):: h5var
  h5var = ${H5CST}
end program test_${RESULT_VAR}
")
	try_compile(COMPILE_RESULT "${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}" "${TEST_FILE}"
		CMAKE_FLAGS
			"-DINCLUDE_DIRECTORIES=${HDF5_Fortran_INCLUDE_PATH}"
			"-DCMAKE_Fortran_FLAGS=${HDF5_Fortran_COMPILE_FLAGS}"
			"-DCMAKE_EXE_LINKER_FLAGS=${HDF5_Fortran_LINK_FLAGS}"
		LINK_LIBRARIES
			${HDF5_Fortran_LIBRARIES} ${HDF5_C_LIBRARIES}
		OUTPUT_VARIABLE COMPILE_OUTPUT
	)
	if(COMPILE_RESULT)
		file(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeOutput.log
		"Fortran/HDF5 ${TYPE}(KIND=${KIND}) type successfully compiled with the following output:\n"
		"${COMPILE_OUTPUT}\n")
		set("${RESULT_VAR}" "${H5CST}" CACHE STRING "HDF5 constant for Fortran type ${TYPE}(KIND=${KIND})")
	else()
		file(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeError.log
		"Fortran/HDF5 ${TYPE}(KIND=${KIND}) type failed to compile with the following output:\n"
		"${COMPILE_OUTPUT}\n")
		set("${RESULT_VAR}" "HDF5_CONSTANT-NOTFOUND" CACHE STRING "HDF5 constant for Fortran type ${TYPE}(KIND=${KIND})")
	endif()
	message(STATUS "Detecting HDF5 constant for Fortran type ${TYPE}(KIND=${KIND}) -- ${${RESULT_VAR}}")
	mark_as_advanced("${RESULT_VAR}")
endfunction()
