# CMakeLists.txt in the "test" directory

# Add all source files in the "test" directory
file(GLOB TEST_FILES my_test/*.cpp)

# Create an executable for testing
add_executable(testExecutable ${TEST_FILES})

# Link to the "src" library
target_link_libraries(testExecutable PRIVATE src)
