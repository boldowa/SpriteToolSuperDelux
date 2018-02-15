#!/bin/sh
#-------------------------------------------------
# CMake build script
#
# Usage:
#   cmake_build.sh <option>
#
# Options:
#
#   -c      : Clean build
#
#   -d      : Debug build
#
#   -D<opt> : Define cmake options.
#             e.g.   -DFOO=1
#
#   -g      : force use gcc compiler
#
#   -j<num> : specify compile jobs.
#             default is 2.
#             e.g.  -j4
#
#   -l      : force use clang compiler
#
#   -r      : Release build
#
#   -s      : Minimum build
#
#   -v      : Verbose make command
#
#   -w      : Windows binary build
#             (Use MinGW-w64)
#
#   -?      : show usage
#
#-------------------------------------------------
BuildDir="build"
Target="pixi"

ShowUsage() {
	echo "Usage: $0 <option>"
	echo "Options:"
	echo "    -c      : clean build"
	echo "    -d      : debug build"
	echo "    -D<opt> : specify cmake define"
	echo "    -g      : force use gnu compiler(g++)"
	echo "    -j<num> : make jobs (default: 2)"
	echo "    -l      : force use llvm(clang++)"
	echo "    -r      : release build"
	echo "    -s      : minumum size build"
	echo "    -v      : verbose make compile command"
	echo "    -w      : windows binary build (with MinGW-w64 i686)"
	echo "    -?      : show usage"
}

main() {
	CompilerPrefix=""
	Windows=0
	CmakeFlags=""
	Jobs=2
	BuildType=""
	Clean=0
	Verbose=""
	Compiler=""
	ExeSuffix=""
	Help=0

	#--- get arguments
	while test ! -z "$1"; do
		case "$1" in
			-c)	# clean
				Clean=1 ;;

			-d)	# Debug build
				BuildType="-DCMAKE_BUILD_TYPE=Debug" ;;

			-D*)	# define
				CMakeFlags="${CmakeFlags} $1" ;;

			-g)	# gcc
				Compiler="g++" ;;

			-j*)	# jobs
				work=`echo "$1" | cut -c 3-`
				expr ${work} + 0 2>/dev/null
				if test $? -ne 0; then
					echo "Invalid jobs (${work})."
					return -1
				fi
				Jobs=${work} ;;

			-l)	# llvm clang
				Compiler="clang++" ;;

			-r)	# Release build
				BuildType="-DCMAKE_BUILD_TYPE=Release" ;;

			-s)	# Minimum build
				BuildType="-DCMAKE_BUILD_TYPE=MinSizeRel" ;;

			-v)
				Verbose="VERBOSE=1" ;;

			-w)	# Windows
				Windows=1 ;;

			-?)
				Help=1 ;;

			*)
				echo "Invalid option \"$1\"."
				return -1 ;;
		esac
		shift 1
	done

	if test $Help -ne 0; then
		ShowUsage "$0"
		return 0
	fi

	if test ${Windows} -ne 0; then
		ExeSuffix=".exe"
		CMakeFlags="${CmakeFlags} -DCLANG=1"
		CompilerPrefix="i686-w64-mingw32-"
	fi

	#--- Use clang++ if it is installed.
	which ${CompilerPrefix}clang++ >/dev/null 2>&1
	if test $? -eq 0; then
		export CXX="${CompilerPrefix}clang++"
	fi

	if test ! -z "${Compiler}"; then
		CMakeFlags="${CmakeFlags} -DCMAKE_CXX_COMPILER=${CompilerPrefix}${Compiler}"
	fi

	if test ${Clean} -ne 0; then
		rm -rf "${BuildDir}"
	fi

	if test ! -d "${BuildDir}"; then
		mkdir "${BuildDir}"
	fi

	cd "${BuildDir}"
	if test 0 -ne ${Windows}; then
		cmake ${BuildType} ${Compiler} ${CMakeFlags} -DCMAKE_TOOLCHAIN_FILE=../toolchain/mingw-x86.cmake ..
	else
		cmake ${BuildType} ${Compiler} ${CMakeFlags} ..
	fi

	make -j${Jobs} ${Verbose}
	if test $? -eq 0; then
		mv ${Target}${ExeSuffix} ../
	fi
}

cd `dirname "$0"`
main $*
