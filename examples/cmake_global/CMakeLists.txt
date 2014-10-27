cmake_minimum_required(VERSION 2.8)
project(BppExample Fortran)

find_package(Bpp REQUIRED)

bpp_preprocess(SRC_Bpp example.F90.bpp)
add_executable(example ${SRC_Bpp})
