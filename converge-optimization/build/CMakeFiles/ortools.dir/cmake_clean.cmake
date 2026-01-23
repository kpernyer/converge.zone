file(REMOVE_RECURSE
  "lib/.9"
  "lib/libortools.9.15.dylib"
  "lib/libortools.9.dylib"
  "lib/libortools.dylib"
  "lib/libortools.pdb"
)

# Per-language clean rules from dependency scanning.
foreach(lang CXX)
  include(CMakeFiles/ortools.dir/cmake_clean_${lang}.cmake OPTIONAL)
endforeach()
