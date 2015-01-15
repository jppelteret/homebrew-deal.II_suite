require 'formula'

class Dealii < Formula

  homepage "http://www.dealii.org"
  url "https://github.com/dealii/dealii/releases/download/v8.2.1/dealii-8.2.1.tar.gz"
  sha1 '18a83feb7b2d9bb7c7b3d7721176a90aa505b1eb'

  head do
    url "https://github.com/dealii/dealii.git", :branch => "master"
    version "8.2dev"
  end

  option "with-testsuite", "Run full test suite (7000+ tests). Takes a lot of time."

  depends_on "cmake"        => :build
  depends_on :mpi           => [:cc, :cxx, :f90, :recommended]
  depends_on "boost"        => :recommended
  depends_on "hdf5"         => [:recommended, (build.with? :mpi) ? "with-mpi" : ""]
  depends_on "arpack"       => [:recommended, (build.with? :mpi) ? "with-mpi" : ""]
  depends_on "mumps"        => :recommended
  depends_on "gsl"          => :recommended
  depends_on "metis"        => :recommended
  depends_on "opencascade"  => :recommended
  depends_on "p4est"        => :recommended if build.with? :mpi
  # Optional dependencies, enforce that they are built with `--with-XXX` options.
  depends_on "petsc"        => [:optional]
  depends_on "slepc"        => [:optional]
  depends_on "trilinos"     => [:optional, "without-python", "with-netcdf", "release"]

  def install
    args = %W[
      -DCMAKE_BUILD_TYPE=DebugRelease
      -DCMAKE_INSTALL_PREFIX=#{prefix}
      -DDEAL_II_COMPONENT_COMPAT_FILES=OFF
    ]
    # constrain Cmake to look for libraries in homebrew's prefix
    args << "-DCMAKE_PREFIX_PATH=#{HOMEBREW_PREFIX}"

    if build.with? :mpi
      args << "-DCMAKE_C_COMPILER=mpicc"
      args << "-DCMAKE_CXX_COMPILER=mpicxx"
      args << "-DCMAKE_Fortran_COMPILER=mpif90"
    end

    args << "-DDEAL_II_WITH_HDF5=OFF"  if build.without? "hdf5"
    args << "-DDEAL_II_WITH_MUMPS=OFF" if build.without? "mumps"
    args << "-DDEAL_II_WITH_METIS=OFF" if build.without? "metis"
    args << "-DDEAL_II_WITH_ARPACK=OFF"if build.without? "arpack"
    args << "-DDEAL_II_WITH_P4EST=OFF" if build.without? "p4est"
    args << "-DDEAL_II_WITH_GSL=OFF"   if build.without? "gsl"
    args << "-DDEAL_II_WITH_OPENCASCADE=OFF" if build.without? "opencascade"

    args << ("-DDEAL_II_WITH_PETSC="    + ((build.with? "petsc")    ? "ON" : "OFF"))
    args << ("-DDEAL_II_WITH_SLEPC="    + ((build.with? "slepc")    ? "ON" : "OFF"))
    args << ("-DDEAL_II_WITH_TRILINOS=" + ((build.with? "trilinos") ? "ON" : "OFF"))

    mkdir 'build' do
      system "cmake", *args, "../"
      system "make"
      # run minimal test cases (8 tests)
      system "make test"
      ohai 'Quick test results are in ~/Library/Logs/Homebrew/dealii/03.make. Please check.'
      # run full test suite if really needed
      if build.with? "testsuite"
        system "make setup_tests"
        system ("ctest -j" + Hardware::CPU.cores)
      end
      system "make install"
    end

  end
end
