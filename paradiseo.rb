require 'formula'

class Paradiseo < Formula
  # Better option at this point than using the very old supplied packages
  head do
    url "https://gforge.inria.fr/git/paradiseo/paradiseo.git", :branch => "master"
    version "2.1dev"
  end

  option "with-smp", "Build with symmetric multi-processing module (Requires C++11 compatible compiler)"
  option "with-mpi", "Build with parallel and distributed metaheuristics module (Requires MPI compiler)"
  option "with-edo", "Build with (Experimental) EDO module"
  option "with-tests", "Enable build tests"
  option "release",       "Build with RELEASE flags"

  depends_on "cmake"        => :build
  depends_on :mpi           => [:cc, :cxx, :recommended] if build.with? "mpi"
  depends_on "gnuplot"      => :recommended
  depends_on "doxygen"      => :optional

  head do
    # Ensure that eoserial library is built
    patch :DATA if  build.with? "mpi"
  end

  def install
    args  = ((build.include? "release") ? %W[-DCMAKE_INSTALL_PREFIX=#{prefix} -DCMAKE_BUILD_TYPE=Release] : std_cmake_args)
    args << "-DCMAKE_PREFIX_PATH=#{HOMEBREW_PREFIX}" # constrain Cmake to look for libraries in homebrew's prefix
    if build.with? :mpi
      args << "-DCMAKE_C_COMPILER=mpicc"
      args << "-DCMAKE_CXX_COMPILER=mpicxx"
    end
    args << "-DINSTALL_TYPE=min"
    args << "-DSMP=" + ((build.with? "smp") ? "TRUE" : "FALSE")
    args << "-DMPI=" + ((build.with? "mpi") ? "TRUE" : "FALSE")
    args << "-DEDO=" + ((build.with? "edo") ? "TRUE" : "FALSE")
    args << "-DENABLE_CMAKE_TESTING=" + ((build.with? "tests") ? "YES" : "NO")

    mkdir 'build' do
      system "cmake", *args, "../"
      system "make", "VERBOSE=1"
      system "make test" if build.with? "tests"
      system "make install"
    end

    # add symlinks against Paradiseo libraries
    lib.install_symlink Dir["#{prefix}/lib64/*"]
  end

end

__END__
diff --git a/eo/src/CMakeLists.txt b/eo/src/CMakeLists.txt
index b2b445a..d45ddc7 100644
--- a/eo/src/CMakeLists.txt
+++ b/eo/src/CMakeLists.txt
@@ -47,7 +47,7 @@ install(DIRECTORY do es ga gp other utils
 add_subdirectory(es)
 add_subdirectory(ga)
 add_subdirectory(utils)
-#add_subdirectory(serial)
+add_subdirectory(serial) # Required when including <paradiseo/eo/utils/eoTimer.h> , which is need by <paradiseo/eo/mpi/eoMpi.h>
 
 if(ENABLE_PYEO)
   add_subdirectory(pyeo)
