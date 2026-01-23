# Install script for directory: /Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/osi-src/Osi

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
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/lib/libOsi.0.108.11.dylib"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/lib/libOsi.0.dylib"
    )
  foreach(file
      "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libOsi.0.108.11.dylib"
      "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libOsi.0.dylib"
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
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE SHARED_LIBRARY FILES "/Users/kpernyer/repo/converge.zone/converge-optimization/build/lib/libOsi.dylib")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/coin" TYPE FILE FILES
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/osi-src/Osi/src/Osi/OsiConfig.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/osi-src/Osi/src/Osi/OsiAuxInfo.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/osi-src/Osi/src/Osi/OsiBranchingObject.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/osi-src/Osi/src/Osi/OsiChooseVariable.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/osi-src/Osi/src/Osi/OsiColCut.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/osi-src/Osi/src/Osi/OsiCollections.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/osi-src/Osi/src/Osi/OsiCut.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/osi-src/Osi/src/Osi/OsiCuts.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/osi-src/Osi/src/Osi/OsiPresolve.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/osi-src/Osi/src/Osi/OsiRowCut.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/osi-src/Osi/src/Osi/OsiRowCutDebugger.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/osi-src/Osi/src/Osi/OsiSolverBranch.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/osi-src/Osi/src/Osi/OsiSolverInterface.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/osi-src/Osi/src/Osi/OsiSolverParameters.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/osi-build/Osi/config_osi.h"
    )
endif()

string(REPLACE ";" "\n" CMAKE_INSTALL_MANIFEST_CONTENT
       "${CMAKE_INSTALL_MANIFEST_FILES}")
if(CMAKE_INSTALL_LOCAL_ONLY)
  file(WRITE "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/osi-build/Osi/install_local_manifest.txt"
     "${CMAKE_INSTALL_MANIFEST_CONTENT}")
endif()
