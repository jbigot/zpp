function(test_fort_type RESULT_VAR TYPE)
  if(DEFINED "${RESULT_VAR}")
    return()
  endif()
  message(STATUS "Checking whether Fortran supports type ${TYPE}")
  set(TEST_FILE "${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/cmake_test_${TYPE}.f90")
  file(WRITE "${TEST_FILE}" "
program test_${TYPE}
  ${TYPE}:: iunit
end program test_${TYPE}
")
  try_compile(COMPILE_RESULT "${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}" "${TEST_FILE}"
    OUTPUT_VARIABLE COMPILE_OUTPUT
  )
  if(COMPILE_RESULT)
    file(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeOutput.log
      "${TYPE} type successfully compiled with the following output:\n"
      "${COMPILE_OUTPUT}\n")
    message(STATUS "Checking whether Fortran supports type ${TYPE} -- yes")
  else()
    file(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeError.log
      "${TYPE} type failed to compile with the following output:\n"
      "${COMPILE_OUTPUT}\n")
    message(STATUS "Checking whether Fortran supports type ${TYPE} -- no")
  endif()
  set("${RESULT_VAR}" "${COMPILE_RESULT}" CACHE BOOL "Checking whether Fortran supports type ${TYPE}")
  mark_as_advanced("${RESULT_VAR}")
endfunction()

function(test_h5fort_type RESULT_VAR TYPE)
  if(DEFINED "${RESULT_VAR}")
    return()
  endif()
  message(STATUS "Checking whether HDF5/Fortran supports type ${TYPE}")
  set(TEST_FILE "${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/cmake_test_${TYPE}.f90")
  file(WRITE "${TEST_FILE}" "
program test_${TYPE}
  ${TYPE}:: iunit
end program test_${TYPE}
")
  try_compile(COMPILE_RESULT "${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}" "${TEST_FILE}"
    OUTPUT_VARIABLE COMPILE_OUTPUT
  )
  if(COMPILE_RESULT)
    file(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeOutput.log
      "HDF5/Fortran ${TYPE} type successfully compiled with the following output:\n"
      "${COMPILE_OUTPUT}\n")
    message(STATUS "Checking whether HDF5/Fortran supports type ${TYPE} -- yes")
  else()
    file(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeError.log
      "HDF5/Fortran ${TYPE} type failed to compile with the following output:\n"
      "${COMPILE_OUTPUT}\n")
    message(STATUS "Checking whether HDF5/Fortran supports type ${TYPE} -- no")
  endif()
  set("${RESULT_VAR}" "${COMPILE_RESULT}" CACHE BOOL "Checking whether HDF5/Fortran supports type ${TYPE}")
  mark_as_advanced("${RESULT_VAR}")
endfunction()
