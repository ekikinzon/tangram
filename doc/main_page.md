# Welcome to tangram!   {#mainpage}

Tangram is a framework that computational physics applications can use
to build a highly customized, hybrid parallel (MPI+X) interface
reconstruction library for constructing in-cell material polytopes
based on given volume fractions and, optionally, centroids data.

We aim to provide:
- A modern, modular design - pick and choose your preferred
  intersection and interface reconstruction methods
- Support for general polytopal meshes and higher-order material moments
- High flexibility for application customization
- Algorithms that take advantage of both distrubuted and on-node parallelism
- An _Open Source Community_ for these tools!
- Use of client application's native mesh data structures

See the [Concepts](@ref concepts) page for a high-level discussion of
the components of tangram.

See the [Example Use](@ref example) page for a simple example of
hooking tangram up to a mesh and interface reconstructor.

---

# Details and Requirements

At a minimum, tangram requires:
- A C++-11 compatible compiler; regular testing is performed with GCC
  5.3+ and Intel 17+.
- CMake 3.0+
- Boost (1.53.0+) **or** Thrust (1.6.0+)

Distributed parallelism of tangram is currently supported through MPI;
regular testing is performed with OpenMPI 1.10.3+ . Most application
tests are currently only built if MPI is
used.  MPI is enabled in tangram by setting the CMake variable
`ENABLE_MPI=True`.

On-node parallelism is exposed through
the [Thrust](https://thrust.github.io) library.  Enabling Thrust
within tangram requires setting at least two CMake variables:
`ENABLE_THRUST=True` and `THRUST_DIR=<path_to_thrust_directory>`.
Additionally, one can specify the Thrust backend to utilize, with the
default being the OpenMP backend
`THRUST_BACKEND=THRUST_DEVICE_SYSTEM_OMP`.  Tangram also supports the
`THRUST_DEVICE_SYSTEM_TBB` backend.  Regular testing happens with
Thrust 1.8.

## Obtaining tangram

The latest release of [tangram](https://github.com/laristra/tangram)
can be found on GitHub.  Tangram makes use of git submodules, so it must be
cloned recursively:

```sh
git clone --recursive https://github.com/laristra/tangram
```

## Building

Tangram uses the CMake build system.  In the simplest case where you
want to build a serial version of the code, and CMake knows where to
find your Boost installations, one can do

```sh
tangram/ $ mkdir build
tangram/ $ cd build
tangram/build/ $ cmake ..
tangram/build/ $ make
```

This will build a serial version of the code into a library (without
any tests).  A more complete build with MPI, Thrust (for on-node
parallelism), unit and application test support, documentation
support, and support for both [Jali](https://github.com/lanl/jali) and
[XMOF2D](https://github.com/laristra/XMOF2D) libraries would look
like:

~~~sh
tangram/ $ mkdir build
tangram/ $ cd build
tangram/build/ $ cmake -DENABLE_UNIT_TESTS=True \
					   -DENABLE_MPI=True \
					   -DENABLE_THRUST=True -DTHRUST_DIR=/path/to/thrust/include/directory \
					   -DJali_DIR=path/to/Jali/lib \
             -DXMOF2D_DIR=path/to/XMOF2D/lib \
					   -DENABLE_DOXYGEN=True \
					   ..
tangram/build/ $ make           # builds the library and tests
tangram/build/ $ make test      # runs the tests
tangram/build/ $ make doxygen   # builds this HTML and a PDF form of the documentation
tangram/build/ $ make install   # installs the tangram library and headers into CMAKE_INSTALL_PREFIX
~~~

## Useful CMake Flags
Below is a non-exhaustive list of useful CMake flags for building
tangram.

| CMake flag:type | Description | Default |
|:----------|:------------|:--------|
| `CMAKE_BUILD_TYPE:STRING`| `Debug` or optimized `Release` build | `Debug` |
| `CMAKE_INSTALL_PREFIX:PATH` | Location for the tangram library and headers to be installed | `/usr/local` |
| `CMAKE_PREFIX_PATH:PATH` | Locations where CMake can look for packages | "" |
| `ENABLE_APP_TESTS:BOOL` | Turn on compilation and test harness of application tests | `False` |
| `ENABLE_DOXYGEN:BOOL` | Create a target to build this documentation | `False` |
| `ENABLE_MPI:BOOL` | Build with support for MPI | `False` |
| `ENABLE_TCMALLOC:BOOL` | Build with support for TCMalloc | `False` |
| `ENABLE_THRUST:BOOL` | Turn on Thrust support for on-node parallelism | `False` |
| `ENABLE_UNIT_TESTS:BOOL` | Turn on compilation and test harness of unit tests | `False` |
| `Jali_DIR:PATH` | Hint location for CMake to find Jali.  This version of tangram works with version 0.9.8 of Jali | "" |
| `XMOF2D_DIR:PATH` | Hint location for CMake to find XMOF2D | "" |
| `TCMALLOC_LIB:PATH` | The TCMalloc library to use | `${HOME}` |
| `THRUST_DIR:PATH` | Directory of the Thrust install | "" |
| `BOOST_ROOT:PATH` | Directory of the Boost install | "" |
| `THRUST_BACKEND:STRING` | Backend to use for Thrust | `"THRUST_DEVICE_SYSTEM_OMP"` |