#[[
 This file is part of the Ristra tangram project.
 Please see the license file at the root of this repository, or at:
 https://github.com/laristra/tangram/blob/master/LICENSE
]]

project(tangram)

cinch_minimum_required(2.0)



# If a C++14 compiler is available, then set the appropriate flags
include(cxx14)
check_for_cxx14_compiler(CXX14_COMPILER)
if(CXX14_COMPILER)
  enable_cxx14()
else()
  message(STATUS "C++14 compatible compiler not found")
endif()

# If we couldn't find a C++14 compiler, try to see if a C++11
# compiler is available, then set the appropriate flags
if (NOT CXX14_COMPILER)
  include(cxx11)
  check_for_cxx11_compiler(CXX11_COMPILER)
  if(CXX11_COMPILER)
    enable_cxx11()
  else()
    message(FATAL_ERROR "C++11 compatible compiler not found")
  endif()
endif()

# cinch extras

cinch_load_extras()

set(CINCH_HEADER_SUFFIXES "\\.h")

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${PROJECT_SOURCE_DIR}/cmake")


#-----------------------------------------------------------------------------
# Gather all the third party libraries needed for Tangram
#-----------------------------------------------------------------------------

set(ARCHOS ${CMAKE_SYSTEM_PROCESSOR}_${CMAKE_SYSTEM_NAME})

#------------------------------------------------------------------------------#
# If we are building with FleCSI, then we need a modern C++ compiler
#------------------------------------------------------------------------------#
if(ENABLE_FleCSI)
  # we already checked for CXX14 in project.cmake
  if(NOT CXX14_COMPILER)
    message(STATUS "C++14 compatible compiler not found")
  endif()
endif()

#------------------------------------------------------------------------------#
# Set up MPI builds
# (eventually most of this should be pushed down into cinch)
#------------------------------------------------------------------------------#
set(ENABLE_MPI OFF CACHE BOOL "")
if (ENABLE_MPI)

  add_definitions(-DENABLE_MPI)
  include(mpi)

  #message(STATUS "MPI_${MPI_LANGUAGE}_COMPILE_FLAGS=${MPI_${MPI_LANGUAGE}_COMPILE_FLAGS}")
  #message(STATUS "MPI_${MPI_LANGUAGE}_INCLUDE_PATH=${MPI_${MPI_LANGUAGE}_INCLUDE_PATH}")
  #message(STATUS "MPI_${MPI_LANGUAGE}_LIBRARY_DIRS=${MPI_${MPI_LANGUAGE}_LIBRARY_DIRS}")
endif ()


set(ARCHOS ${CMAKE_SYSTEM_PROCESSOR}_${CMAKE_SYSTEM_NAME})

#-----------------------------------------------------------------------------
# FleCSI and FleCSI-SP location
#-----------------------------------------------------------------------------

set(ENABLE_FleCSI FALSE CACHE BOOL "Use FleCSI")
if (ENABLE_FleCSI)
 
 find_package(FleCSI REQUIRED)
 message(STATUS "FleCSI_LIBRARIES=${FleCSI_LIBRARIES}" )
 include_directories(${FleCSI_INCLUDE_DIR})
 message(STATUS "FleCSI_INCLUDE_DIRS=${FleCSI_INCLUDE_DIR}")

 find_package(FleCSISP REQUIRED)
 message(STATUS "FleCSISP_LIBRARIES=${FleCSISP_LIBRARIES}" )
 include_directories(${FleCSISP_INCLUDE_DIR})
 message(STATUS "FleCSISP_INCLUDE_DIRS=${FleCSISP_INCLUDE_DIR}")

  ######################################################################
  # This is a placeholder for how we would do IO with FleCSI
  # There are still some issues with dumping the targetMesh data
  #
  # WARNING!!! THIS IS POTENTIALLY FRAGILE
  # it appears to work, but could cause conflicts with EXODUS and
  # other libraries used by Jali
  #
  # FOR NOW THIS IS DISABLED UNTIL WE CAN GET A PROPER WORKAROUND
  ######################################################################
  # STRING(REPLACE "flecsi" "flecsi-tpl" FLECSI_TPL_DIR ${FLECSI_INSTALL_DIR})
  # message(STATUS "FLECSI_TPL_DIR=${FLECSI_TPL_DIR}")
  # if(IS_DIRECTORY ${FLECSI_TPL_DIR})
  #   find_library(EXODUS_LIBRARY
  #     NAMES exodus
  #     PATHS ${FLECSI_TPL_DIR}
  #     PATH_SUFFIXES lib
  #     NO_DEFAULT_PATH)
  #   find_path(EXODUS_INCLUDE_DIR
  #     NAMES exodusII.h
  #     PATHS ${FLECSI_TPL_DIR}
  #     PATH_SUFFIXES include
  #     NO_DEFAULT_PATH)

  #   if(EXODUS_LIBRARY AND EXODUS_INCLUDE_DIR)
  #     set(FLECSI_LIBRARIES ${EXODUS_LIBRARY} ${FLECSI_LIBRARIES})
  #     include_directories(${EXODUS_INCLUDE_DIR})
  #     add_definitions(-DHAVE_EXODUS)
  #   endif(EXODUS_LIBRARY AND EXODUS_INCLUDE_DIR)

  # endif(IS_DIRECTORY ${FLECSI_TPL_DIR})
endif()



#------------------------------------------------------------------------------#
# Configure Jali
# (this includes the TPLs that Jali will need)
#------------------------------------------------------------------------------#

if (Jali_DIR)

   # Look for the Jali package

   find_package(Jali REQUIRED
                HINTS ${Jali_DIR}/lib)

   message(STATUS "Located Jali")
   message(STATUS "Jali_DIR=${Jali_DIR}")

   # add full path to jali libs
   unset(_LIBS)
   foreach (_lib ${Jali_LIBRARIES})
      set(_LIBS ${_LIBS};${Jali_LIBRARY_DIRS}/lib${_lib}.a)
   endforeach()
   set(Jali_LIBRARIES ${_LIBS})

   include_directories(${Jali_INCLUDE_DIRS} ${Jali_TPL_INCLUDE_DIRS})

endif (Jali_DIR)

#------------------------------------------------------------------------------#
# Configure XMOF2D
#------------------------------------------------------------------------------#

if (XMOF2D_DIR)

   # Look for the XMOF2D package

   find_package(XMOF2D REQUIRED
                HINTS ${XMOF2D_DIR}/lib)

   message(STATUS "Located XMOF2D")
   message(STATUS "XMOF2D_DIR=${XMOF2D_DIR}")

   # add full path to XMOF2D libs
   unset(_LIBS)
   foreach (_lib ${XMOF2D_LIBRARIES})
      set(_LIBS ${_LIBS};${XMOF2D_LIBRARY_DIRS}/lib${_lib}.a)
   endforeach()
   set(XMOF2D_LIBRARIES ${_LIBS})

   # message(STATUS "XMOF2D_INCLUDE_DIRS=${XMOF2D_INCLUDE_DIRS}")
   # message(STATUS "XMOF2D_LIBRARY_DIRS=${XMOF2D_LIBRARY_DIRS}")
   # message(STATUS "XMOF2D_LIBRARIES=${XMOF2D_LIBRARIES}")

   include_directories(${XMOF2D_INCLUDE_DIRS})

endif (XMOF2D_DIR)

#-----------------------------------------------------------------------------
# General NGC include directory information
#-----------------------------------------------------------------------------
set(NGC_INCLUDE_DIR "$ENV{NGC_INCLUDE_DIR}" CACHE PATH "NGC include directory")
if(NGC_INCLUDE_DIR)
  message(STATUS "Using NGC_INCLUDE_DIR=${NGC_INCLUDE_DIR}")
endif(NGC_INCLUDE_DIR)

#-----------------------------------------------------------------------------
# Thrust information
#-----------------------------------------------------------------------------
set(ENABLE_THRUST FALSE CACHE BOOL "Use Thrust")
if(ENABLE_THRUST)
  message(STATUS "Enabling compilation with Thrust")
  # allow the user to specify a THRUST_DIR, otherwise use ${NGC_INCLUDE_DIR}
  # NOTE: thrust internally uses include paths from the 'root' directory, e.g.
  #
  #       #include "thrust/device_vector.h"
  #
  #       so the path here should point to the directory that has thrust as
  #       a subdirectory.
  # Use THRUST_DIR directly if specified, otherwise try to build from NGC
  set(THRUST_DIR "${NGC_INCLUDE_DIR}" CACHE PATH "Thrust directory")
  message(STATUS "Using THRUST_DIR=${THRUST_DIR}")

  # Allow for swapping backends - should this be in CACHE?
  set(THRUST_BACKEND "THRUST_DEVICE_SYSTEM_OMP" CACHE STRING "Thrust backend")
  message(STATUS "Using ${THRUST_BACKEND} as Thrust backend.")
  include_directories(${THRUST_DIR})
  add_definitions(-DTHRUST)
  add_definitions(-DTHRUST_DEVICE_SYSTEM=${THRUST_BACKEND})

  if("${THRUST_BACKEND}" STREQUAL "THRUST_DEVICE_SYSTEM_OMP")
    FIND_PACKAGE( OpenMP REQUIRED)
    if(OPENMP_FOUND)
      set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${OpenMP_C_FLAGS}")
      set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${OpenMP_CXX_FLAGS}")
      set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${OpenMP_EXE_LINKER_FLAGS}")
    endif(OPENMP_FOUND)
  endif ()

  if("${THRUST_BACKEND}" STREQUAL "THRUST_DEVICE_SYSTEM_TBB")
    FIND_PACKAGE(TBB REQUIRED)
    if(TBB_FOUND)
      include_directories(${TBB_INCLUDE_DIRS})
      link_directories(${TBB_LIBRARY_DIRS})
      set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -ltbb")
    endif(TBB_FOUND)
  endif()

else (ENABLE_THRUST)

  find_package(Boost REQUIRED)
  if(Boost_FOUND)
   message(STATUS "Boost location: ${Boost_INCLUDE_DIRS}")
   include_directories( ${Boost_INCLUDE_DIRS} )
  endif()

endif(ENABLE_THRUST)


#-----------------------------------------------------------------------------
# Now add the source directories and library targets
#-----------------------------------------------------------------------------

cinch_add_application_directory(app)
cinch_add_library_target(tangram tangram)


# Add application tests
# May pull this logic into cinch at some future point
option(ENABLE_APP_TESTS "Enable testing of full app" OFF)
if(ENABLE_APP_TESTS)
  enable_testing()
endif()

#------------------------------------------------------------------------------#
#
#------------------------------------------------------------------------------#

