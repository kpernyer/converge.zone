# Install script for directory: /Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cgl-src/Cgl

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

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE SHARED_LIBRARY FILES
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/lib/libCgl.0.60.9.dylib"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/lib/libCgl.0.dylib"
    )
  foreach(file
      "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libCgl.0.60.9.dylib"
      "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libCgl.0.dylib"
      )
    if(EXISTS "${file}" AND
       NOT IS_SYMLINK "${file}")
      if(CMAKE_INSTALL_DO_STRIP)
        execute_process(COMMAND "/usr/bin/strip" -x "${file}")
      endif()
    endif()
  endforeach()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE SHARED_LIBRARY FILES "/Users/kpernyer/repo/converge.zone/converge-optimization/build/lib/libCgl.dylib")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/coin" TYPE FILE FILES
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cgl-src/Cgl/src/CglConfig.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cgl-src/Cgl/src/CglMixedIntegerRounding/CglMixedIntegerRounding.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cgl-src/Cgl/src/CglDuplicateRow/CglDuplicateRow.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cgl-src/Cgl/src/CglStored.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cgl-src/Cgl/src/CglPreProcess/CglPreProcess.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cgl-src/Cgl/src/CglProbing/CglProbing.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cgl-src/Cgl/src/CglMixedIntegerRounding2/CglMixedIntegerRounding2.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cgl-src/Cgl/src/CglLandP/CglLandP.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cgl-src/Cgl/src/CglLandP/CglLandPUtils.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cgl-src/Cgl/src/CglLandP/CglLandPValidator.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cgl-src/Cgl/src/CglLandP/CglLandPTabRow.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cgl-src/Cgl/src/CglLandP/CglLandPMessages.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cgl-src/Cgl/src/CglLandP/CglLandPSimplex.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cgl-src/Cgl/src/CglOddHole/CglOddHole.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cgl-src/Cgl/src/CglRedSplit/CglRedSplitParam.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cgl-src/Cgl/src/CglRedSplit/CglRedSplit.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cgl-src/Cgl/src/CglAllDifferent/CglAllDifferent.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cgl-src/Cgl/src/CglKnapsackCover/CglKnapsackCover.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cgl-src/Cgl/src/CglSimpleRounding/CglSimpleRounding.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cgl-src/Cgl/src/CglMessage.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cgl-src/Cgl/src/CglZeroHalf/CglZeroHalf.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cgl-src/Cgl/src/CglZeroHalf/Cgl012cut.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cgl-src/Cgl/src/CglRedSplit2/CglRedSplit2Param.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cgl-src/Cgl/src/CglRedSplit2/CglRedSplit2.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cgl-src/Cgl/src/CglCutGenerator.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cgl-src/Cgl/src/CglResidualCapacity/CglResidualCapacity.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cgl-src/Cgl/src/CglTwomir/CglTwomir.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cgl-src/Cgl/src/CglFlowCover/CglFlowCover.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cgl-src/Cgl/src/CglClique/CglClique.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cgl-src/Cgl/src/CglLiftAndProject/CglLiftAndProject.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cgl-src/Cgl/src/CglGomory/CglGomory.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cgl-src/Cgl/src/CglGMI/CglGMIParam.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cgl-src/Cgl/src/CglGMI/CglGMI.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cgl-src/Cgl/src/CglParam.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cgl-src/Cgl/src/CglTreeInfo.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cgl-build/Cgl/config_cgl.h"
    )
endif()

string(REPLACE ";" "\n" CMAKE_INSTALL_MANIFEST_CONTENT
       "${CMAKE_INSTALL_MANIFEST_FILES}")
if(CMAKE_INSTALL_LOCAL_ONLY)
  file(WRITE "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cgl-build/Cgl/install_local_manifest.txt"
     "${CMAKE_INSTALL_MANIFEST_CONTENT}")
endif()
