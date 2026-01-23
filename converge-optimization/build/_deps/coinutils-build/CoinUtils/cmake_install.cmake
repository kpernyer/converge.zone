# Install script for directory: /Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/coinutils-src/CoinUtils

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
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/lib/libCoinUtils.2.11.12.dylib"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/lib/libCoinUtils.2.dylib"
    )
  foreach(file
      "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libCoinUtils.2.11.12.dylib"
      "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libCoinUtils.2.dylib"
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
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE SHARED_LIBRARY FILES "/Users/kpernyer/repo/converge.zone/converge-optimization/build/lib/libCoinUtils.dylib")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/coin" TYPE FILE FILES
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/coinutils-src/CoinUtils/src/Coin_C_defines.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/coinutils-src/CoinUtils/src/CoinUtilsConfig.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/coinutils-src/CoinUtils/src/CoinAlloc.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/coinutils-src/CoinUtils/src/CoinBuild.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/coinutils-src/CoinUtils/src/CoinDenseVector.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/coinutils-src/CoinUtils/src/CoinDistance.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/coinutils-src/CoinUtils/src/CoinError.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/coinutils-src/CoinUtils/src/CoinFactorization.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/coinutils-src/CoinUtils/src/CoinSimpFactorization.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/coinutils-src/CoinUtils/src/CoinDenseFactorization.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/coinutils-src/CoinUtils/src/CoinOslFactorization.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/coinutils-src/CoinUtils/src/CoinFileIO.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/coinutils-src/CoinUtils/src/CoinFinite.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/coinutils-src/CoinUtils/src/CoinFloatEqual.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/coinutils-src/CoinUtils/src/CoinHelperFunctions.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/coinutils-src/CoinUtils/src/CoinIndexedVector.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/coinutils-src/CoinUtils/src/CoinLpIO.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/coinutils-src/CoinUtils/src/CoinMessage.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/coinutils-src/CoinUtils/src/CoinMessageHandler.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/coinutils-src/CoinUtils/src/CoinModel.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/coinutils-src/CoinUtils/src/CoinStructuredModel.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/coinutils-src/CoinUtils/src/CoinModelUseful.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/coinutils-src/CoinUtils/src/CoinMpsIO.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/coinutils-src/CoinUtils/src/CoinPackedMatrix.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/coinutils-src/CoinUtils/src/CoinPackedVector.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/coinutils-src/CoinUtils/src/CoinPackedVectorBase.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/coinutils-src/CoinUtils/src/CoinParam.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/coinutils-src/CoinUtils/src/CoinPragma.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/coinutils-src/CoinUtils/src/CoinPresolveDoubleton.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/coinutils-src/CoinUtils/src/CoinPresolveDual.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/coinutils-src/CoinUtils/src/CoinPresolveDupcol.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/coinutils-src/CoinUtils/src/CoinPresolveEmpty.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/coinutils-src/CoinUtils/src/CoinPresolveFixed.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/coinutils-src/CoinUtils/src/CoinPresolveForcing.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/coinutils-src/CoinUtils/src/CoinPresolveImpliedFree.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/coinutils-src/CoinUtils/src/CoinPresolveIsolated.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/coinutils-src/CoinUtils/src/CoinPresolveMatrix.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/coinutils-src/CoinUtils/src/CoinPresolveMonitor.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/coinutils-src/CoinUtils/src/CoinPresolvePsdebug.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/coinutils-src/CoinUtils/src/CoinPresolveSingleton.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/coinutils-src/CoinUtils/src/CoinPresolveSubst.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/coinutils-src/CoinUtils/src/CoinPresolveTighten.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/coinutils-src/CoinUtils/src/CoinPresolveTripleton.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/coinutils-src/CoinUtils/src/CoinPresolveUseless.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/coinutils-src/CoinUtils/src/CoinPresolveZeros.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/coinutils-src/CoinUtils/src/CoinSearchTree.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/coinutils-src/CoinUtils/src/CoinShallowPackedVector.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/coinutils-src/CoinUtils/src/CoinSignal.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/coinutils-src/CoinUtils/src/CoinSmartPtr.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/coinutils-src/CoinUtils/src/CoinSnapshot.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/coinutils-src/CoinUtils/src/CoinSort.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/coinutils-src/CoinUtils/src/CoinTime.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/coinutils-src/CoinUtils/src/CoinTypes.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/coinutils-src/CoinUtils/src/CoinUtility.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/coinutils-src/CoinUtils/src/CoinWarmStart.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/coinutils-src/CoinUtils/src/CoinWarmStartBasis.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/coinutils-src/CoinUtils/src/CoinWarmStartVector.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/coinutils-src/CoinUtils/src/CoinWarmStartDual.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/coinutils-src/CoinUtils/src/CoinWarmStartPrimalDual.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/coinutils-src/CoinUtils/src/CoinRational.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/coinutils-build/CoinUtils/config_coinutils.h"
    )
endif()

string(REPLACE ";" "\n" CMAKE_INSTALL_MANIFEST_CONTENT
       "${CMAKE_INSTALL_MANIFEST_FILES}")
if(CMAKE_INSTALL_LOCAL_ONLY)
  file(WRITE "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/coinutils-build/CoinUtils/install_local_manifest.txt"
     "${CMAKE_INSTALL_MANIFEST_CONTENT}")
endif()
