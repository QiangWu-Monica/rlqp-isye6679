# CMAKE generated file: DO NOT EDIT!
# Generated by "Unix Makefiles" Generator, CMake Version 3.23

# Delete rule output on recipe failure.
.DELETE_ON_ERROR:

#=============================================================================
# Special targets provided by cmake.

# Disable implicit rules so canonical targets will work.
.SUFFIXES:

# Disable VCS-based implicit rules.
% : %,v

# Disable VCS-based implicit rules.
% : RCS/%

# Disable VCS-based implicit rules.
% : RCS/%,v

# Disable VCS-based implicit rules.
% : SCCS/s.%

# Disable VCS-based implicit rules.
% : s.%

.SUFFIXES: .hpux_make_needs_suffix_list

# Command-line flag to silence nested $(MAKE).
$(VERBOSE)MAKESILENT = -s

#Suppress display of executed commands.
$(VERBOSE).SILENT:

# A target that is always out of date.
cmake_force:
.PHONY : cmake_force

#=============================================================================
# Set environment variables for the build.

# The shell in which to execute make rules.
SHELL = /bin/sh

# The CMake executable.
CMAKE_COMMAND = /storage/pace-apps/spack/packages/linux-rhel7-x86_64/gcc-4.8.5/cmake-3.23.1-327dblnbramviejdezocehqsujhu7yyg/bin/cmake

# The command to remove a file.
RM = /storage/pace-apps/spack/packages/linux-rhel7-x86_64/gcc-4.8.5/cmake-3.23.1-327dblnbramviejdezocehqsujhu7yyg/bin/cmake -E rm -f

# Escaping for special characters.
EQUALS = =

# The top-level source directory on which CMake was run.
CMAKE_SOURCE_DIR = /home/hice1/qwu350/coc-ice-home-data/ISYE6679/proj/main

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /home/hice1/qwu350/coc-ice-home-data/ISYE6679/proj/main/build

# Include any dependencies generated for this target.
include test/CMakeFiles/testExecutable.dir/depend.make
# Include any dependencies generated by the compiler for this target.
include test/CMakeFiles/testExecutable.dir/compiler_depend.make

# Include the progress variables for this target.
include test/CMakeFiles/testExecutable.dir/progress.make

# Include the compile flags for this target's objects.
include test/CMakeFiles/testExecutable.dir/flags.make

# Object files for target testExecutable
testExecutable_OBJECTS =

# External object files for target testExecutable
testExecutable_EXTERNAL_OBJECTS =

test/testExecutable: test/CMakeFiles/testExecutable.dir/build.make
test/testExecutable: src/libsrc.a
test/testExecutable: test/CMakeFiles/testExecutable.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --bold --progress-dir=/home/hice1/qwu350/coc-ice-home-data/ISYE6679/proj/main/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_1) "Linking CUDA executable testExecutable"
	cd /home/hice1/qwu350/coc-ice-home-data/ISYE6679/proj/main/build/test && $(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/testExecutable.dir/link.txt --verbose=$(VERBOSE)

# Rule to build all files generated by this target.
test/CMakeFiles/testExecutable.dir/build: test/testExecutable
.PHONY : test/CMakeFiles/testExecutable.dir/build

test/CMakeFiles/testExecutable.dir/clean:
	cd /home/hice1/qwu350/coc-ice-home-data/ISYE6679/proj/main/build/test && $(CMAKE_COMMAND) -P CMakeFiles/testExecutable.dir/cmake_clean.cmake
.PHONY : test/CMakeFiles/testExecutable.dir/clean

test/CMakeFiles/testExecutable.dir/depend:
	cd /home/hice1/qwu350/coc-ice-home-data/ISYE6679/proj/main/build && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /home/hice1/qwu350/coc-ice-home-data/ISYE6679/proj/main /home/hice1/qwu350/coc-ice-home-data/ISYE6679/proj/main/test /home/hice1/qwu350/coc-ice-home-data/ISYE6679/proj/main/build /home/hice1/qwu350/coc-ice-home-data/ISYE6679/proj/main/build/test /home/hice1/qwu350/coc-ice-home-data/ISYE6679/proj/main/build/test/CMakeFiles/testExecutable.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : test/CMakeFiles/testExecutable.dir/depend
