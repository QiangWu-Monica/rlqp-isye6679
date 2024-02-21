cmake_minimum_required(VERSION 3.12)
project(my_osqp CUDA)

set(CMAKE_CUDA_STANDARD 11)

set(CMAKE_CXX_FLAGS_DEBUG "-g -O0 -fopenmp -Wall")
set(CMAKE_CUDA_FLAGS_DEBUG "-G")

set(CMAKE_BUILD_TYPE Debug)  # Add this line to enable debug mode
set(ENALBE_GPU ON)  # Add this line to enable debug modeß

target_compile_options(src PRIVATE "$<$<AND:$<CONFIG:Debug,RelWithDebInfo>,$<COMPILE_LANGUAGE:CUDA>>:-G>")

# Include subdirectories
add_subdirectory(include)
add_subdirectory(src)
add_subdirectory(test)
