# A function to preprocess a source file through bash
function(bpp_preprocess OUTVAR FIRST_SRC)
	set(RESULT)

	get_property(INCLUDE_DIRS DIRECTORY PROPERTY INCLUDE_DIRECTORIES)
	set(BPP_INCLUDE_PARAMS)
	foreach(INCLUDE_DIR ${INCLUDE_DIRS})
		set(BPP_INCLUDE_PARAMS ${BPP_INCLUDE_PARAMS} "-I" "${INCLUDE_DIR}")
	endforeach()
	
	foreach(SRC "${FIRST_SRC}" ${ARGN})
		get_filename_component(OUTFILE "${SRC}" NAME)
		string(REGEX REPLACE "\\.[bB][pP][pP]$" "" OUTFILE "${OUTFILE}")
		set(OUTFILE "${CMAKE_CURRENT_BINARY_DIR}/${OUTFILE}")
		list(APPEND RESULT "${OUTFILE}")
		add_custom_command(OUTPUT "${OUTFILE}"
			COMMAND "${BPP_BINARY_DIR}/bpp" ARGS ${BPP_INCLUDE_PARAMS} "${SRC}" "${OUTFILE}"
			WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
			MAIN_DEPENDENCY "${SRC}"
			VERBATIM
		)
	endforeach()
	
	set(${OUTVAR} ${RESULT} PARENT_SCOPE)
endfunction()
