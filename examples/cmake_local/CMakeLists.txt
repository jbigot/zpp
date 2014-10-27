cmake_minimum_required(VERSION 2.8)
project(BppExample Fortran)

add_subdirectory(../../ bpp EXCLUDE_FROM_ALL)

bpp_preprocess(SRC_Bpp example.F90.bpp)
add_executable(example ${SRC_Bpp})
