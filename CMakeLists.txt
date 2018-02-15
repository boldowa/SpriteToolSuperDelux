#-------------------------------------------------
# CMakeLists for PIXI
#
#   This is an script for generate
#   executable binary (or msvc project).
#
# -- How to
#
#      Unix or MinGW:
#        1. cd build
#        2. cmake ..
#        3. make
#
#      Visual studio:
#        1. Load this file with cmake-gui
#        2. Configure & Generate
#        3. Open project
#        4. Build the solution
#
#-------------------------------------------------
cmake_minimum_required(VERSION 3.1)

if(NOT CMAKE_BUILD_TYPE)
        message(STATUS "No build type selected, default to Release")
        set(CMAKE_BUILD_TYPE "Release" CACHE STRING 
                "Choose the type of build, options are: Debug Release RelWithDebInfo MinSizeRel." FORCE)
endif()

project(pixi)
set_property(DIRECTORY PROPERTY VS_STARTUP_PROJECT "pixi")

#--- link directory
link_directories(
        "${CMAKE_CURRENT_BINARY_DIR}"
        "."
        ".."
        )

macro(add_option var opt)
        set(${var} "${${var}} ${opt}")
endmacro(add_option)

#--- platform options (common)
if(UNIX OR MINGW)
        set(CMAKE_C_FLAGS "-fpic -Wall -Wno-format -Wconversion")
elseif(MSVC)
        # What should I specify here ... ;( ???
endif()
set(CMAKE_CXX_FLAGS "${CMAKE_C_FLAGS}")

#--- platform options (c++)
if(UNIX OR MINGW)
        add_option(CMAKE_CXX_FLAGS "-std=c++11")
elseif(MSVC)
        # What should I specify here ... ;( ???
endif()

#--- build type option
if(UNIX OR MINGW)
        set(CMAKE_CXX_FLAGS_RELEASE "-O2 -DRELEASE -DNDEBUG -ffunction-sections -fdata-sections")
        set(CMAKE_EXE_LINKER_FLAGS_RELEASE "-s -Wl,--gc-sections")
        set(CMAKE_CXX_FLAGS_DEBUG "-O0 -g3")
elseif(MSVC)
        # What should I specify here ... ;( ???
endif()
if(MINGW)
        add_option(CMAKE_EXE_LINKER_FLAGS_RELEASE "-static")
endif()

#--- collect sources & build
file(GLOB SRC "${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp")
add_executable(pixi
        ${SRC}
        "${CMAKE_CURRENT_SOURCE_DIR}/src/asar/asardll.c")
target_include_directories(pixi PRIVATE
        "${CMAKE_CURRENT_SOURCE_DIR}/src"
        "${CMAKE_CURRENT_SOURCE_DIR}/src/asar"
        )
if(UNIX)
        target_link_libraries(pixi "dl" "asar")
endif()

