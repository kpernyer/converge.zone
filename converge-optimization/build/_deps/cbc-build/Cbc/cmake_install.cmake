# Install script for directory: /Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cbc-src/Cbc

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
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/lib/libCbc.2.10.12.dylib"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/lib/libCbc.2.dylib"
    )
  foreach(file
      "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libCbc.2.10.12.dylib"
      "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libCbc.2.dylib"
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
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE SHARED_LIBRARY FILES "/Users/kpernyer/repo/converge.zone/converge-optimization/build/lib/libCbc.dylib")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/coin" TYPE FILE FILES
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cbc-src/Cbc/src/CbcConfig.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cbc-src/Cbc/src/CbcBranchActual.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cbc-src/Cbc/src/CbcBranchAllDifferent.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cbc-src/Cbc/src/CbcBranchBase.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cbc-src/Cbc/src/CbcBranchCut.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cbc-src/Cbc/src/CbcBranchDecision.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cbc-src/Cbc/src/CbcBranchDefaultDecision.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cbc-src/Cbc/src/CbcBranchDynamic.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cbc-src/Cbc/src/CbcBranchLotsize.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cbc-src/Cbc/src/CbcBranchToFixLots.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cbc-src/Cbc/src/CbcBranchingObject.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cbc-src/Cbc/src/CbcClique.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cbc-src/Cbc/src/CbcCompare.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cbc-src/Cbc/src/CbcCompareActual.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cbc-src/Cbc/src/CbcCompareBase.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cbc-src/Cbc/src/CbcCompareDefault.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cbc-src/Cbc/src/CbcCompareDepth.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cbc-src/Cbc/src/CbcCompareEstimate.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cbc-src/Cbc/src/CbcCompareObjective.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cbc-src/Cbc/src/CbcConsequence.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cbc-src/Cbc/src/CbcCountRowCut.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cbc-src/Cbc/src/CbcCutGenerator.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cbc-src/Cbc/src/CbcCutModifier.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cbc-src/Cbc/src/CbcCutSubsetModifier.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cbc-src/Cbc/src/CbcDummyBranchingObject.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cbc-src/Cbc/src/CbcEventHandler.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cbc-src/Cbc/src/CbcFathom.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cbc-src/Cbc/src/CbcFathomDynamicProgramming.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cbc-src/Cbc/src/CbcFeasibilityBase.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cbc-src/Cbc/src/CbcFixVariable.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cbc-src/Cbc/src/CbcFollowOn.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cbc-src/Cbc/src/CbcFullNodeInfo.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cbc-src/Cbc/src/CbcGeneral.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cbc-src/Cbc/src/CbcGeneralDepth.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cbc-src/Cbc/src/CbcHeuristic.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cbc-src/Cbc/src/CbcHeuristicDINS.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cbc-src/Cbc/src/CbcHeuristicDW.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cbc-src/Cbc/src/CbcHeuristicDive.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cbc-src/Cbc/src/CbcHeuristicDiveCoefficient.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cbc-src/Cbc/src/CbcHeuristicDiveFractional.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cbc-src/Cbc/src/CbcHeuristicDiveGuided.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cbc-src/Cbc/src/CbcHeuristicDiveLineSearch.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cbc-src/Cbc/src/CbcHeuristicDivePseudoCost.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cbc-src/Cbc/src/CbcHeuristicDiveVectorLength.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cbc-src/Cbc/src/CbcHeuristicFPump.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cbc-src/Cbc/src/CbcHeuristicGreedy.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cbc-src/Cbc/src/CbcHeuristicLocal.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cbc-src/Cbc/src/CbcHeuristicPivotAndFix.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cbc-src/Cbc/src/CbcHeuristicRENS.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cbc-src/Cbc/src/CbcHeuristicRINS.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cbc-src/Cbc/src/CbcHeuristicRandRound.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cbc-src/Cbc/src/CbcHeuristicVND.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cbc-src/Cbc/src/CbcMessage.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cbc-src/Cbc/src/CbcModel.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cbc-src/Cbc/src/CbcNWay.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cbc-src/Cbc/src/CbcNode.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cbc-src/Cbc/src/CbcNodeInfo.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cbc-src/Cbc/src/CbcObject.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cbc-src/Cbc/src/CbcObjectUpdateData.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cbc-src/Cbc/src/CbcParam.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cbc-src/Cbc/src/CbcPartialNodeInfo.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cbc-src/Cbc/src/CbcSOS.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cbc-src/Cbc/src/CbcSimpleInteger.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cbc-src/Cbc/src/CbcSimpleIntegerDynamicPseudoCost.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cbc-src/Cbc/src/CbcSimpleIntegerPseudoCost.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cbc-src/Cbc/src/CbcStrategy.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cbc-src/Cbc/src/CbcSubProblem.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cbc-src/Cbc/src/CbcTree.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cbc-src/Cbc/src/CbcTreeLocal.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cbc-src/Cbc/src/ClpAmplObjective.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cbc-src/Cbc/src/ClpConstraintAmpl.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cbc-build/Cbc/config_cbc.h"
    )
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE SHARED_LIBRARY FILES
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/lib/libOsiCbc.2.10.12.dylib"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/lib/libOsiCbc.2.dylib"
    )
  foreach(file
      "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libOsiCbc.2.10.12.dylib"
      "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libOsiCbc.2.dylib"
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
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE SHARED_LIBRARY FILES "/Users/kpernyer/repo/converge.zone/converge-optimization/build/lib/libOsiCbc.dylib")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/coin" TYPE FILE FILES "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cbc-src/Cbc/src/OsiCbc/OsiCbcSolverInterface.hpp")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE SHARED_LIBRARY FILES
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/lib/libCbcSolver.2.10.12.dylib"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/lib/libCbcSolver.2.dylib"
    )
  foreach(file
      "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libCbcSolver.2.10.12.dylib"
      "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libCbcSolver.2.dylib"
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
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE SHARED_LIBRARY FILES "/Users/kpernyer/repo/converge.zone/converge-optimization/build/lib/libCbcSolver.dylib")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/coin" TYPE FILE FILES
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cbc-src/Cbc/src/Cbc_C_Interface.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cbc-src/Cbc/src/Cbc_ampl.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cbc-src/Cbc/src/CbcLinked.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cbc-src/Cbc/src/CbcSolver.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cbc-src/Cbc/src/CbcMipStartIO.hpp"
    )
endif()

string(REPLACE ";" "\n" CMAKE_INSTALL_MANIFEST_CONTENT
       "${CMAKE_INSTALL_MANIFEST_FILES}")
if(CMAKE_INSTALL_LOCAL_ONLY)
  file(WRITE "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/cbc-build/Cbc/install_local_manifest.txt"
     "${CMAKE_INSTALL_MANIFEST_CONTENT}")
endif()
