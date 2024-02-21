# CMakeLists.txt in the "include" directory

# Add all header files in the "include" directory
file(GLOB HEADER_FILES *.h)

# Create an interface library for headers
add_library(include INTERFACE)
target_sources(include INTERFACE ${HEADER_FILES})
target_include_directories(include INTERFACE ${CMAKE_CURRENT_SOURCE_DIR})