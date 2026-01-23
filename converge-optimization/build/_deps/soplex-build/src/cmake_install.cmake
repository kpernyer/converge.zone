# Install script for directory: /Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src

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
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/soplex" TYPE FILE FILES
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/array.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/basevectors.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/changesoplex.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/classarray.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/classset.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/clufactor.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/clufactor.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/clufactor_rational.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/clufactor_rational.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/cring.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/dataarray.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/datahashtable.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/datakey.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/dataset.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/didxset.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/dsvector.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/dsvectorbase.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/dvector.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/enter.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/exceptions.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/fmt.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/idlist.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/idxset.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/islist.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/leave.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/lpcol.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/lpcolbase.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/lpcolset.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/lpcolsetbase.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/lprow.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/lprowbase.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/lprowset.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/lprowsetbase.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/mpsinput.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/nameset.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/notimer.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/random.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/rational.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/ratrecon.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/ratrecon.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/slinsolver.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/slinsolver_rational.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/slufactor.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/slufactor.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/slufactor_rational.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/slufactor_rational.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/sol.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/solbase.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/solverational.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/solvereal.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/sorter.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/spxalloc.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/spxautopr.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/spxautopr.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/spxbasis.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/spxbasis.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/spxboundflippingrt.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/spxboundflippingrt.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/spxbounds.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/spxchangebasis.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/spxdantzigpr.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/spxdantzigpr.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/spxdefaultrt.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/spxdefaultrt.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/spxdefines.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/spxdefines.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/spxdesc.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/spxdevexpr.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/spxdevexpr.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/spxequilisc.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/spxequilisc.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/spxfastrt.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/spxfastrt.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/spxfileio.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/spxfileio.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/spxgeometsc.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/spxgeometsc.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/spxgithash.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/spxharrisrt.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/spxharrisrt.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/spxhybridpr.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/spxhybridpr.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/spxid.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/spxleastsqsc.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/spxleastsqsc.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/spxlp.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/spxlpbase.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/spxlpbase_rational.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/spxlpbase_real.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/spxmainsm.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/spxmainsm.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/spxout.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/spxpapilo.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/spxparmultpr.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/spxparmultpr.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/spxpricer.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/spxquality.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/spxratiotester.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/spxscaler.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/spxscaler.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/spxshift.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/spxsimplifier.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/spxsolve.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/spxsolver.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/spxsolver.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/spxstarter.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/spxstarter.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/spxsteepexpr.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/spxsteeppr.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/spxsteeppr.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/spxsumst.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/spxsumst.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/spxvecs.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/spxvectorst.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/spxvectorst.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/spxweightpr.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/spxweightpr.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/spxweightst.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/spxweightst.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/spxwritestate.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/ssvector.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/ssvectorbase.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/stablesum.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/statistics.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/statistics.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/svector.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/svectorbase.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/svset.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/svsetbase.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/testsoplex.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/timer.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/timerfactory.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/unitvector.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/unitvectorbase.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/updatevector.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/updatevector.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/usertimer.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/validation.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/validation.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/vector.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/vectorbase.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/wallclocktimer.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex_interface.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-build/soplex/config.h"
    )
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include" TYPE FILE FILES
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex_interface.h"
    )
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/soplex/external/fmt" TYPE FILE FILES
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/external/fmt/chrono.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/external/fmt/color.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/external/fmt/compile.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/external/fmt/core.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/external/fmt/format-inl.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/external/fmt/format.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/external/fmt/locale.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/external/fmt/os.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/external/fmt/ostream.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/external/fmt/posix.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/external/fmt/printf.h"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/external/fmt/ranges.h"
    )
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/soplex/external/zstr" TYPE FILE FILES
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/external/zstr/zstr.hpp"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/external/zstr/strict_fstream.hpp"
    )
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/licenses/soplex/zstr" TYPE FILE FILES "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/external/zstr/License.txt")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE STATIC_LIBRARY FILES "/Users/kpernyer/repo/converge.zone/converge-optimization/build/lib/libsoplex.a")
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libsoplex.a" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libsoplex.a")
    execute_process(COMMAND "/usr/bin/ranlib" "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libsoplex.a")
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE STATIC_LIBRARY FILES "/Users/kpernyer/repo/converge.zone/converge-optimization/build/lib/libsoplex-pic.a")
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libsoplex-pic.a" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libsoplex-pic.a")
    execute_process(COMMAND "/usr/bin/ranlib" "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libsoplex-pic.a")
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE SHARED_LIBRARY FILES
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/lib/libsoplexshared.8.0.0.dylib"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/lib/libsoplexshared.8.0.dylib"
    )
  foreach(file
      "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libsoplexshared.8.0.0.dylib"
      "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libsoplexshared.8.0.dylib"
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
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE SHARED_LIBRARY FILES "/Users/kpernyer/repo/converge.zone/converge-optimization/build/lib/libsoplexshared.dylib")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/licenses/soplex" TYPE FILE FILES "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/LICENSE")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/licenses/soplex/fmt" TYPE FILE FILES "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-src/src/soplex/external/fmt/LICENSE.rst")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/cmake/soplex/soplex-targets.cmake")
    file(DIFFERENT _cmake_export_file_changed FILES
         "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/cmake/soplex/soplex-targets.cmake"
         "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-build/src/CMakeFiles/Export/7b30a661feffd7bbb1d77d2bef836267/soplex-targets.cmake")
    if(_cmake_export_file_changed)
      file(GLOB _cmake_old_config_files "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/cmake/soplex/soplex-targets-*.cmake")
      if(_cmake_old_config_files)
        string(REPLACE ";" ", " _cmake_old_config_files_text "${_cmake_old_config_files}")
        message(STATUS "Old export file \"$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/cmake/soplex/soplex-targets.cmake\" will be replaced.  Removing files [${_cmake_old_config_files_text}].")
        unset(_cmake_old_config_files_text)
        file(REMOVE ${_cmake_old_config_files})
      endif()
      unset(_cmake_old_config_files)
    endif()
    unset(_cmake_export_file_changed)
  endif()
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib/cmake/soplex" TYPE FILE FILES "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-build/src/CMakeFiles/Export/7b30a661feffd7bbb1d77d2bef836267/soplex-targets.cmake")
  if(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Rr][Ee][Ll][Ee][Aa][Ss][Ee])$")
    file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib/cmake/soplex" TYPE FILE FILES "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-build/src/CMakeFiles/Export/7b30a661feffd7bbb1d77d2bef836267/soplex-targets-release.cmake")
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib/cmake/soplex" TYPE FILE FILES
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-build/CMakeFiles/soplex-config.cmake"
    "/Users/kpernyer/repo/converge.zone/converge-optimization/build/soplex-config-version.cmake"
    )
endif()

string(REPLACE ";" "\n" CMAKE_INSTALL_MANIFEST_CONTENT
       "${CMAKE_INSTALL_MANIFEST_FILES}")
if(CMAKE_INSTALL_LOCAL_ONLY)
  file(WRITE "/Users/kpernyer/repo/converge.zone/converge-optimization/build/_deps/soplex-build/src/install_local_manifest.txt"
     "${CMAKE_INSTALL_MANIFEST_CONTENT}")
endif()
