if(NOT TARGET libscip)
  include("${CMAKE_CURRENT_LIST_DIR}/scip-targets.cmake")
endif()

# For `find_dependency` function.
include(CMakeFindDependencyMacro)

list(APPEND CMAKE_MODULE_PATH /Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/scip-src/cmake/Modules)

set(SCIP_LIBRARIES libscip )
set(SCIP_INCLUDE_DIRS "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/scip-src/src;/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/scip-build")
# additional compilation flags to use
set(SCIP_COMPILE_FLAGS )
set(SCIP_FOUND TRUE)

# If SCIP was built with GMP then we also need it.
set(SCIP_WITH_GMP OFF)
if(SCIP_WITH_GMP AND SCIP_FOUND)
   if(NOT GMP_DIR)
      set(GMP_DIR "")
   endif()
   find_dependency(GMP)

   # TODO: Once we use targets, this will not be needed.
   set(SCIP_INCLUDE_DIRS ${SCIP_INCLUDE_DIRS} ${GMP_INCLUDE_DIRS})
endif()

# If SCIP was built with MPFR then we also need it.
set(SCIP_WITH_MPFR OFF)
if(SCIP_WITH_MPFR AND SCIP_FOUND)
   if(NOT MPFR_DIR)
      set(MPFR_DIR "")
   endif()
   find_dependency(MPFR)

   # TODO: Once we use targets, this will not be needed.
   set(SCIP_INCLUDE_DIRS ${SCIP_INCLUDE_DIRS} ${MPFR_INCLUDE_DIRS})
endif()

if(0 AND SCIP_FOUND)
   set(ZIMPL_DIR "")
   find_dependency(ZIMPL CONFIG)
endif()

if(0 AND SCIP_FOUND)
   set(SOPLEX_DIR "")
   find_dependency(SOPLEX CONFIG)
endif()
