file(REMOVE_RECURSE
  "testExecutable"
  "testExecutable.pdb"
)

# Per-language clean rules from dependency scanning.
foreach(lang )
  include(CMakeFiles/testExecutable.dir/cmake_clean_${lang}.cmake OPTIONAL)
endforeach()
