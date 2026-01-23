# Install script for directory: /Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/clp-src/Clp

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
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/lib/libClp.1.17.10.dylib"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/lib/libClp.1.dylib"
    )
  foreach(file
      "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libClp.1.17.10.dylib"
      "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libClp.1.dylib"
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
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE SHARED_LIBRARY FILES "/Users/kpernyer/repo/converge.zone/converge-optimization/build/lib/libClp.dylib")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/coin" TYPE FILE FILES
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/clp-src/Clp/src/ClpCholeskyBase.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/clp-src/Clp/src/ClpCholeskyDense.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/clp-src/Clp/src/ClpConfig.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/clp-src/Clp/src/ClpConstraint.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/clp-src/Clp/src/ClpConstraintLinear.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/clp-src/Clp/src/ClpConstraintQuadratic.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/clp-src/Clp/src/ClpDualRowDantzig.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/clp-src/Clp/src/ClpDualRowPivot.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/clp-src/Clp/src/ClpDualRowSteepest.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/clp-src/Clp/src/ClpDummyMatrix.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/clp-src/Clp/src/ClpDynamicExampleMatrix.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/clp-src/Clp/src/ClpDynamicMatrix.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/clp-src/Clp/src/ClpEventHandler.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/clp-src/Clp/src/ClpFactorization.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/clp-src/Clp/src/ClpGubDynamicMatrix.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/clp-src/Clp/src/ClpGubMatrix.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/clp-src/Clp/src/ClpInterior.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/clp-src/Clp/src/ClpLinearObjective.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/clp-src/Clp/src/ClpMatrixBase.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/clp-src/Clp/src/ClpMessage.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/clp-src/Clp/src/ClpModel.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/clp-src/Clp/src/ClpNetworkMatrix.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/clp-src/Clp/src/ClpNode.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/clp-src/Clp/src/ClpNonLinearCost.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/clp-src/Clp/src/ClpObjective.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/clp-src/Clp/src/ClpPackedMatrix.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/clp-src/Clp/src/ClpParameters.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/clp-src/Clp/src/ClpPdcoBase.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/clp-src/Clp/src/ClpPdco.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/clp-src/Clp/src/ClpPEDualRowDantzig.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/clp-src/Clp/src/ClpPEDualRowSteepest.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/clp-src/Clp/src/ClpPEPrimalColumnDantzig.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/clp-src/Clp/src/ClpPEPrimalColumnSteepest.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/clp-src/Clp/src/ClpPESimplex.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/clp-src/Clp/src/ClpPlusMinusOneMatrix.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/clp-src/Clp/src/ClpPresolve.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/clp-src/Clp/src/ClpPrimalColumnDantzig.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/clp-src/Clp/src/ClpPrimalColumnPivot.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/clp-src/Clp/src/ClpPrimalColumnSteepest.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/clp-src/Clp/src/ClpQuadraticObjective.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/clp-src/Clp/src/ClpSimplex.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/clp-src/Clp/src/ClpSimplexDual.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/clp-src/Clp/src/ClpSimplexNonlinear.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/clp-src/Clp/src/ClpSimplexOther.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/clp-src/Clp/src/ClpSimplexPrimal.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/clp-src/Clp/src/ClpSolve.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/clp-src/Clp/src/Clp_C_Interface.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/clp-src/Clp/src/Idiot.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/clp-src/Clp/src/CbcOrClpParam.cpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/clp-build/Clp/config_clp.h"
    )
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE SHARED_LIBRARY FILES
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/lib/libOsiClp.1.17.10.dylib"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/lib/libOsiClp.1.dylib"
    )
  foreach(file
      "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libOsiClp.1.17.10.dylib"
      "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libOsiClp.1.dylib"
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
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE SHARED_LIBRARY FILES "/Users/kpernyer/repo/converge.zone/converge-optimization/build/lib/libOsiClp.dylib")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/coin" TYPE FILE FILES "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/clp-src/Clp/src/OsiClp/OsiClpSolverInterface.hpp")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE SHARED_LIBRARY FILES
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/lib/libClpSolver.1.17.10.dylib"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/lib/libClpSolver.1.dylib"
    )
  foreach(file
      "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libClpSolver.1.17.10.dylib"
      "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libClpSolver.1.dylib"
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
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE SHARED_LIBRARY FILES "/Users/kpernyer/repo/converge.zone/converge-optimization/build/lib/libClpSolver.dylib")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/coin" TYPE FILE FILES
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/clp-src/Clp/src/CbcOrClpParam.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/clp-src/Clp/src/Clp_ampl.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/clp-src/Clp/src/MyEventHandler.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/clp-src/Clp/src/MyMessageHandler.hpp"
    )
endif()

string(REPLACE ";" "\n" CMAKE_INSTALL_MANIFEST_CONTENT
       "${CMAKE_INSTALL_MANIFEST_FILES}")
if(CMAKE_INSTALL_LOCAL_ONLY)
  file(WRITE "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/clp-build/Clp/install_local_manifest.txt"
     "${CMAKE_INSTALL_MANIFEST_CONTENT}")
endif()
