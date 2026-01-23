# Install script for directory: /Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/eigen3-src/unsupported/Eigen

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "/usr/local")
endif()
string(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
if(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
  if(BUILD_TYPE)
    string(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  else()
    set(CMAKE_INSTALL_CONFIG_NAME "Release")
  endif()
  message(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
endif()

# Set the component getting installed.
if(NOT CMAKE_INSTALL_COMPONENT)
  if(COMPONENT)
    message(STATUS "Install component: \"${COMPONENT}\"")
    set(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  else()
    set(CMAKE_INSTALL_COMPONENT)
  endif()
endif()

# Is this installation the result of a crosscompile?
if(NOT DEFINED CMAKE_CROSSCOMPILING)
  set(CMAKE_CROSSCOMPILING "FALSE")
endif()

# Set path to fallback-tool for dependency-resolution.
if(NOT DEFINED CMAKE_OBJDUMP)
  set(CMAKE_OBJDUMP "/usr/bin/objdump")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Devel" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/eigen3/unsupported/Eigen" TYPE FILE FILES
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/eigen3-src/unsupported/Eigen/AdolcForward"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/eigen3-src/unsupported/Eigen/AlignedVector3"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/eigen3-src/unsupported/Eigen/ArpackSupport"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/eigen3-src/unsupported/Eigen/AutoDiff"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/eigen3-src/unsupported/Eigen/BVH"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/eigen3-src/unsupported/Eigen/EulerAngles"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/eigen3-src/unsupported/Eigen/FFT"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/eigen3-src/unsupported/Eigen/IterativeSolvers"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/eigen3-src/unsupported/Eigen/KroneckerProduct"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/eigen3-src/unsupported/Eigen/LevenbergMarquardt"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/eigen3-src/unsupported/Eigen/MatrixFunctions"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/eigen3-src/unsupported/Eigen/MoreVectorization"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/eigen3-src/unsupported/Eigen/MPRealSupport"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/eigen3-src/unsupported/Eigen/NonLinearOptimization"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/eigen3-src/unsupported/Eigen/NumericalDiff"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/eigen3-src/unsupported/Eigen/OpenGLSupport"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/eigen3-src/unsupported/Eigen/Polynomials"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/eigen3-src/unsupported/Eigen/Skyline"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/eigen3-src/unsupported/Eigen/SparseExtra"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/eigen3-src/unsupported/Eigen/SpecialFunctions"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/eigen3-src/unsupported/Eigen/Splines"
    )
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Devel" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/eigen3/unsupported/Eigen" TYPE DIRECTORY FILES "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/eigen3-src/unsupported/Eigen/src" FILES_MATCHING REGEX "/[^/]*\\.h$")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for each subdirectory.
  include("/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/eigen3-build/unsupported/Eigen/CXX11/cmake_install.cmake")

endif()

string(REPLACE ";" "\n" CMAKE_INSTALL_MANIFEST_CONTENT
       "${CMAKE_INSTALL_MANIFEST_FILES}")
if(CMAKE_INSTALL_LOCAL_ONLY)
  file(WRITE "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/eigen3-build/unsupported/Eigen/install_local_manifest.txt"
     "${CMAKE_INSTALL_MANIFEST_CONTENT}")
endif()
