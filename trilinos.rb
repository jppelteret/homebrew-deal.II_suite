require 'formula'

class Trilinos < Formula
  homepage 'http://trilinos.sandia.gov'
  url 'http://trilinos.org/oldsite/download/files/trilinos-11.12.1-Source.tar.gz'
  sha1 '84cd7f4fba7946e3d391f03d52902954bb4dcd60'
  head 'https://software.sandia.gov/trilinos/repositories/publicTrilinos', :using => :git

  option "with-teko",     "Enable the Teko secondary-stable package"
  option "with-shylu",    "Enable the ShyLU experimental package"
  option "with-check",    "Perform build time checks (time consuming and contains failures)"
  option "release",       "Build with RELEASE flags"
  option :cxx11

  depends_on "cmake"        => :build
  depends_on "boost"        => :recommended
  depends_on "scotch"       => :optional
  depends_on "netcdf"       => :optional
  depends_on "adol-c"       => :optional
  depends_on "suite-sparse" => :recommended
  depends_on "cppunit"      => :optional
  depends_on "eigen"        => :optional # Intrepid_test_Discretization_Basis_HGRAD_TET_Cn_FEM_ORTH_Test_02 fails to build
  depends_on "glpk"         => :optional
  depends_on "hdf5"         => :optional
  depends_on "hwloc"        => :optional
  depends_on "hypre"        => :optional
  depends_on "metis"        => :optional
  depends_on "mumps"        => :optional
  depends_on "petsc"        => :optional  # ML package does not compiles with Petsc 3.5.2 (wrong usage of VecCreateMPIWithArray) (known issue)
  depends_on "parmetis"     => :optional
  depends_on "scalapack"    => :optional
  depends_on "superlu"      => :optional
  depends_on "superlu_dist" => :optional  # Build fails with Superlu_dist
  depends_on "tbb"          => :recommended

  depends_on :mpi => [:cc, :cxx, :recommended]
  depends_on :fortran => :recommended
  depends_on :x11 => :optional
  depends_on "openblas" => :optional

  depends_on :python => :recommended
  depends_on "swig"  => :build if build.with? :python

  def onoff(s, cond)
    s + ((cond) ? "ON" : "OFF")
  end

  def install

    args  = ((build.include? "release") ? %W[-DCMAKE_INSTALL_PREFIX=#{prefix} -DCMAKE_BUILD_TYPE=Release] : std_cmake_args)
    #TODO
    #  tests    : Sacado, EpetraExt
    #  packages : Amesos (superlu_dist or CSparse)
    args += %W[-DBUILD_SHARED_LIBS=ON
               -DTPL_ENABLE_BLAS=ON
               -DTPL_ENABLE_LAPACK=ON
               -DTPL_ENABLE_Zlib:BOOL=ON
               -DTrilinos_ENABLE_ALL_PACKAGES=ON
               -DTrilinos_ENABLE_ALL_OPTIONAL_PACKAGES=ON
               -DTrilinos_ENABLE_TESTS:BOOL=ON
               -DTrilinos_ENABLE_EXAMPLES:BOOL=ON
               -DTrilinos_VERBOSE_CONFIGURE:BOOL=OFF
               -DTrilinos_WARNINGS_AS_ERRORS_FLAGS=""
               -DSacado_ENABLE_TESTS=OFF
               -DEpetraExt_ENABLE_TESTS=OFF]

    # BLAS / LAPACK support
    if build.with? "openblas"
      args += %W[-DTPL_ENABLE_BLAS=ON
                 -DBLAS_LIBRARY_NAMES=openblas
                 -DBLAS_LIBRARY_DIRS="#{Formula['openblas'].opt_lib}"
                 -DTPL_ENABLE_LAPACK=ON
                 -DLAPACK_LIBRARY_NAMES=openblas
                 -DLAPACK_LIBRARY_DIRS="#{Formula['openblas'].opt_lib}"]
    else
      if (OS.mac?) # Will find veclibfort in -L#{Formula['veclibfort'].opt_lib} -lveclibfort
        args += %W[-DTPL_ENABLE_BLAS=ON
                   -DTPL_ENABLE_LAPACK=ON]
      else # Linux: Use system library
        args += %W[-DTPL_ENABLE_BLAS=ON
                   -DTPL_ENABLE_LAPACK=ON]
      end
    end

    args << "-DTrilinos_ASSERT_MISSING_PACKAGES=OFF" if build.head?

    args << onoff("-DTPL_ENABLE_MPI:BOOL=",         (build.with? :mpi))
    args << onoff("-DTrilinos_ENABLE_OpenMP:BOOL=", (ENV.compiler != :clang))
    args << onoff("-DTrilinos_ENABLE_CXX11:BOOL=",  (build.cxx11?))

    # Extra non-default packages
    args << onoff("-DTrilinos_ENABLE_ShyLU:BOOL=",  (build.with? "shylu"))
    args << onoff("-DTrilinos_ENABLE_Teko:BOOL=",   (build.with? "teko"))

    # Third-party libraries
    args << onoff("-DTPL_ENABLE_Boost:BOOL=",       (build.with? "boost"))
    args << onoff("-DTPL_ENABLE_Scotch:BOOL=",      (build.with? "scotch"))
    args << onoff("-DTPL_ENABLE_Netcdf:BOOL=",      (build.with? "netcdf"))
    args << onoff("-DTPL_ENABLE_ADOLC:BOOL=",       (build.with? "adol-c"))
    args << onoff("-DTPL_ENABLE_AMD:BOOL=",         (build.with? "suite-sparse"))

    # Undefined symbols for architecture x86_64: "Amesos_CSparse::Amesos_CSparse(Epetra_LinearProblem const&)"
    # args << onoff("-DTPL_ENABLE_CSparse:BOOL=",     (build.with? "suite-sparse"))
    # args << "-DCSparse_LIBRARY_NAMES=cxsparse;amd;colamd;suitesparseconfig" if build.with? "suite-sparse"

    args << onoff("-DTPL_ENABLE_Cholmod:BOOL=",     (build.with? "suite-sparse"))

    args << onoff("-DTPL_ENABLE_UMFPACK:BOOL=",     (build.with? "suite-sparse"))
    args << "-DUMFPACK_LIBRARY_NAMES=umfpack;amd;colamd;cholmod;suitesparseconfig" if build.with? "suite-sparse"

    args << onoff("-DTPL_ENABLE_CppUnit:BOOL=",     (build.with? "cppunit"))
    args << onoff("-DTPL_ENABLE_Eigen:BOOL=",       (build.with? "eigen"))
    args << "-DEigen_INCLUDE_DIRS=#{Formula['eigen'].include}/eigen3" if build.with? "eigen"
    args << onoff("-DTPL_ENABLE_GLPK:BOOL=",        (build.with? "glpk"))
    args << onoff("-DTPL_ENABLE_HDF5:BOOL=",        (build.with? "hdf5"))
    args << onoff("-DTPL_ENABLE_HWLOC:BOOL=",       (build.with? "hwloc"))
    args << onoff("-DTPL_ENABLE_HYPRE:BOOL=",       (build.with? "hypre"))
    args << onoff("-DTPL_ENABLE_METIS:BOOL=",       (build.with? "metis"))
    args << onoff("-DTPL_ENABLE_MUMPS:BOOL=",       (build.with? "mumps"))
    args << onoff("-DTPL_ENABLE_PETSC:BOOL=",       (build.with? "petsc"))
    args << onoff("-DTPL_ENABLE_ParMETIS:BOOL=",    (build.with? "parmetis"))
    args << onoff("-DTPL_ENABLE_SCALAPACK:BOOL=",   (build.with? "scalapack"))

    args << onoff("-DTPL_ENABLE_SuperLU:BOOL=",     (build.with? "superlu"))
    args << "-DSuperLU_INCLUDE_DIRS=#{Formula['superlu'].include}/superlu" if build.with? "superlu"

    args << onoff("-DTPL_ENABLE_SuperLUDist:BOOL=", (build.with? "superlu_dist"))
    args << "-DSuperLUDist_INCLUDE_DIRS=#{Formula['superlu_dist'].include}/superlu_dist" if build.with? "superlu_dist"

    args << onoff("-DTPL_ENABLE_TBB:BOOL=",         (build.with? "tbb"))
    args << onoff("-DTPL_ENABLE_X11:BOOL=",         (build.with? :x11))

    args << onoff("-DTrilinos_ENABLE_Fortran=",     (build.with? :fortran))

    args << onoff("-DTrilinos_ENABLE_PyTrilinos:BOOL=", (build.with? :python))
    args << "-DPyTrilinos_INSTALL_PREFIX:PATH=#{prefix}" if build.with? :python

    mkdir "build" do
      system "cmake", "..", *args
      system "make", "VERBOSE=1"
      system ("ctest -j" + Hardware::CPU.cores) if build.with? "check"
      system "make install"
    end
  end

  test do
    system "#{bin}/Epetra_BasicPerfTest_test.exe 16 12 1 1 25 -v"
    system "mpirun -np 2 #{bin}/Epetra_BasicPerfTest_test.exe 10 12 1 2 9 -v" if build.with? :mpi
    system "#{bin}/Epetra_BasicPerfTest_test_LL.exe 16 12 1 1 25 -v"
    system "mpirun -np 2 #{bin}/Epetra_BasicPerfTest_test_LL.exe 10 12 1 2 9 -v" if build.with? :mpi
    # system "#{bin}/Ifpack2_BelosTpetraHybridPlatformExample.exe"  # Missing library!!
    system "#{bin}/KokkosClassic_SerialNodeTestAndTiming.exe"
    system "#{bin}/KokkosClassic_TPINodeTestAndTiming.exe"
    system "#{bin}/KokkosClassic_TBBNodeTestAndTiming.exe" if build.with? "tbb"
    system "#{bin}/Tpetra_GEMMTiming_TBB.exe" if build.with? "tbb"
    # system "#{bin}/Tpetra_GEMMTiming_TPI.exe"  # Fails!!
  end
end
