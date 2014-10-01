cmake_minimum_required(2.8)
list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")

project(BPP LANGUAGES)

include(TestFortType)

foreach(TYPENAME "CHARACTER" "COMPLEX" "INTEGER" "LOGICAL" "REAL")
	foreach(TYPESIZE 1 2 4 8 16 32 64 128)
		test_fort_type("${TYPENAME}${TYPESIZE}_WORKS" "${TYPENAME}(${TYPESIZE})")
		if ( "${TYPENAME}${TYPESIZE}_WORKS" )
			set(ALLTYPES "${ALLTYPES}${TYPENAME}${TYPESIZE} ")
		endif()
	endforeach()
endforeach()

configure_file(include/fortran.bpp.sh.in fortran.bpp.sh @ONLY)
configure_file(include/hdf5_fortran.bpp.sh.in hdf5_fortran.bpp.sh @ONLY)
configure_file(scripts/bpp.in bpp @ONLY)
