include(TestFortType.cmake)

# A function to generate the BPP config.bpp.sh file
function(bpp_gen_config OUTFILE)
	foreach(TYPENAME "CHARACTER" "COMPLEX" "INTEGER" "LOGICAL" "REAL")
		foreach(TYPESIZE 1 2 4 8 16 32 64)
			test_fort_type("${TYPENAME}${TYPESIZE}_WORKS" "${TYPENAME}(KIND=${TYPESIZE})")
			if ( "${TYPENAME}${TYPESIZE}_WORKS" )
				set("ALLTYPES" "${ALLTYPES}${TYPENAME}${TYPESIZE} ")
			endif()
		endforeach()
	endforeach()
	file(WRITE "${OUTFILE}"
"#All types supported by the current Fortran implementation
FORTTYPES=\"${ALLTYPES}\"
")
endfunction()


# A function to preprocess a source file with BPP
function(bpp_preprocess OUTVAR FIRST_SRC)

	bpp_gen_config("${CMAKE_CURRENT_BINARY_DIR}/config.bpp.sh")
	set(BPP_INCLUDE_PARAMS "-I" "${CMAKE_CURRENT_BINARY_DIR}")

	get_property(INCLUDE_DIRS DIRECTORY PROPERTY INCLUDE_DIRECTORIES)
	foreach(INCLUDE_DIR ${INCLUDE_DIRS})
		set(BPP_INCLUDE_PARAMS ${BPP_INCLUDE_PARAMS} "-I" "${INCLUDE_DIR}")
	endforeach()

	set(RESULT)
	foreach(SRC "${FIRST_SRC}" ${ARGN})
		get_filename_component(OUTFILE "${SRC}" NAME)
		string(REGEX REPLACE "\\.[bB][pP][pP]$" "" OUTFILE "${OUTFILE}")
		set(OUTFILE "${CMAKE_CURRENT_BINARY_DIR}/${OUTFILE}")
		list(APPEND RESULT "${OUTFILE}")
		add_custom_command(OUTPUT "${OUTFILE}"
			COMMAND "${BPP_EXECUTABLE}" ARGS ${BPP_INCLUDE_PARAMS} "${SRC}" "${OUTFILE}"
			WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
			MAIN_DEPENDENCY "${SRC}"
			VERBATIM
		)
	endforeach()

	set(${OUTVAR} ${RESULT} PARENT_SCOPE)
endfunction()
