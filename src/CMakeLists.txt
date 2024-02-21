# CMakeLists.txt in the "src" directory

# Add all source files in the "src" directory
file(GLOB SOURCE_FILES *.cpp *.cu)

# Create a library for source files
add_library(src ${SOURCE_FILES})

# Link to the "include" library
target_link_libraries(src PUBLIC include)

# Set compile options for the "my_osqp" target
target_compile_options(src PRIVATE "$<$<AND:$<CONFIG:Debug,RelWithDebInfo>,$<COMPILE_LANGUAGE:CUDA>>:-G>")