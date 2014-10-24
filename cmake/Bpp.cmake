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

include(${CMAKE_CURRENT_LIST_DIR}/TestFortType.cmake)

# A function to generate the BPP config.bpp.sh file
function(bpp_gen_config OUTFILE)
	foreach(TYPENAME "CHARACTER" "COMPLEX" "INTEGER" "LOGICAL" "REAL")
		foreach(TYPESIZE 1 2 4 8 16 32 64)
			test_fort_type("BPP_${TYPENAME}${TYPESIZE}_WORKS" "${TYPENAME}" "${TYPESIZE}")
			if ( "BPP_${TYPENAME}${TYPESIZE}_WORKS" )
				set(BPP_FORTTYPES "${BPP_FORTTYPES}${TYPENAME}${TYPESIZE} ")
			endif()
		endforeach()
	endforeach()
	file(WRITE "${OUTFILE}"
"# All types supported by the current Fortran implementation
BPP_FORTTYPES=\"${BPP_FORTTYPES}\"
# for compatibility
FORTTYPES=\"\${BPP_FORTTYPES}\"
")
endfunction()


# A function to preprocess a source file with BPP
function(bpp_preprocess OUTVAR FIRST_SRC)
	set(BPP_INCLUDE_PARAMS)

	get_property(INCLUDE_DIRS DIRECTORY PROPERTY INCLUDE_DIRECTORIES)
	foreach(INCLUDE_DIR ${BPP_DEFAULT_INCLUDES} ${INCLUDE_DIRS})
		set(BPP_INCLUDE_PARAMS ${BPP_INCLUDE_PARAMS} "-I" "${INCLUDE_DIR}")
	endforeach()

	bpp_gen_config("${CMAKE_CURRENT_BINARY_DIR}/bppconf/config.bpp.sh")
	set(BPP_INCLUDE_PARAMS ${BPP_INCLUDE_PARAMS} "-I" "${CMAKE_CURRENT_BINARY_DIR}/bppconf")

	set(RESULT)
	foreach(SRC "${FIRST_SRC}" ${ARGN})
		get_filename_component(OUTFILE "${SRC}" NAME)
		string(REGEX REPLACE "\\.[bB][pP][pP]$" "" OUTFILE "${OUTFILE}")
		set(OUTFILE "${CMAKE_CURRENT_BINARY_DIR}/${OUTFILE}")
		list(APPEND RESULT "${OUTFILE}")
		add_custom_command(OUTPUT "${OUTFILE}"
			COMMAND "${BPP_EXE}" ARGS ${BPP_INCLUDE_PARAMS} "${SRC}" "${OUTFILE}"
			WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
			MAIN_DEPENDENCY "${SRC}"
			VERBATIM
		)
	endforeach()

	set(${OUTVAR} ${RESULT} PARENT_SCOPE)
endfunction()
