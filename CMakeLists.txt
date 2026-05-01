cmake_minimum_required(VERSION 3.20)
project(vtutil C)

add_library(vtutil STATIC
    libvtutil/vtutil.c
)

target_include_directories(vtutil PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/libvtutil
)
