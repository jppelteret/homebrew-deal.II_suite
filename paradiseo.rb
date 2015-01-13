require 'formula'

class Paradiseo < Formula
  homepage "http://paradiseo.gforge.inria.fr/index.php"
  url "https://gforge.inria.fr/frs/download.php/31732/ParadisEO-2.0.1.tar.gz"
  sha1 "3ae7425892d48372d8d940c0af32b29ab3182113"

  # Additional resources for when not building from head
  resource "peo_files" do
    url "https://gforge.inria.fr/frs/download.php/31739/peo-2.0.1.tar.gz"
    sha1 "bed444f94ccc416584b7aef1772792988ea6c19c"
  end

  # Currently does not build due to bug in code
  head do
    url "https://gforge.inria.fr/git/paradiseo/paradiseo.git", :branch => "master"
    version "2.1dev"
  end

  option "with-smp", "Build with symmetric multi-processing module (Requires C++11 compatible compiler)"
  option "with-peo", "Build with parallel and distributed metaheuristics module (Requires MPI compiler)"
  option "with-tests", "Enable build tests"
  option "with-shared-libs", "Build shared libraries"
  option "release",       "Build with RELEASE flags"

  depends_on "cmake"        => :build
  depends_on :mpi           => [:cc, :cxx, :recommended] if build.with? "peo"
  depends_on "libxml2"      => [:build] if build.with? "peo"
  depends_on "gnuplot"      => :recommended
  depends_on "doxygen"      => :optional

  # Add missing header guards protecting against OpenMP library inclusion in :
  # eo/src/apply.h , eo/src/utils/eoParallel.cpp , eo/test/t-eoParallel.cpp , eo/test/t-openmp.cpp
  patch :DATA if not build.head?

  def install
    if build.with? "peo" and not build.head?
      resource("peo_files").stage do
        (buildpath/"peo").install Dir["*"]
      end
    end

    args  = ((build.include? "release") ? %W[-DCMAKE_INSTALL_PREFIX=#{prefix} -DCMAKE_BUILD_TYPE=Release] : std_cmake_args)
    args << "-DCMAKE_PREFIX_PATH=#{HOMEBREW_PREFIX}" # constrain Cmake to look for libraries in homebrew's prefix
    if build.with? :mpi
      args << "-DCMAKE_C_COMPILER=mpicc"
      args << "-DCMAKE_CXX_COMPILER=mpicxx"
    end
    args << "-DINSTALL_TYPE=min"
    args << "-DBUILD_SHARED_LIBS:BOOL=" + ((build.with? "shared-libs") ? "ON" : "OFF")
    args << "-DSMP=" + ((build.with? "smp") ? "TRUE" : "FALSE")
    args << "-DPEO=" + ((build.with? "peo") ? "TRUE" : "FALSE")
    args << "-DENABLE_CMAKE_TESTING=" + ((build.with? "tests") ? "YES" : "NO")

    mkdir 'build' do
      system "cmake", *args, "../"
      system "make", "VERBOSE=1"
      system "make test" if build.with? "tests"
      system "make install"
    end
  end

end

__END__
diff --git a/eo/src/apply.h b/eo/src/apply.h
index f685f8d..99983e2 100644
--- a/eo/src/apply.h
+++ b/eo/src/apply.h
@@ -31,7 +31,10 @@
 #include <utils/eoLogger.h>
 #include <eoFunctor.h>
 #include <vector>
+
+#ifdef _OPENMP
 #include <omp.h>
+#endif // !_OPENMP
 
 /**
   Applies a unary function to a std::vector of things.
diff --git a/eo/src/utils/eoParallel.cpp b/eo/src/utils/eoParallel.cpp
index d9d09c3..78af14d 100644
--- a/eo/src/utils/eoParallel.cpp
+++ b/eo/src/utils/eoParallel.cpp
@@ -25,7 +25,9 @@ Caner Candan <caner.candan@thalesgroup.com>
 
 */
 
+#ifdef _OPENMP
 #include <omp.h>
+#endif // !_OPENMP
 
 #include "eoParallel.h"
 #include "eoLogger.h"
diff --git a/eo/test/t-eoParallel.cpp b/eo/test/t-eoParallel.cpp
index 72d4f26..d40548c 100644
--- a/eo/test/t-eoParallel.cpp
+++ b/eo/test/t-eoParallel.cpp
@@ -2,7 +2,9 @@
 // t-eoParallel.cpp
 //-----------------------------------------------------------------------------
 
+#ifdef _OPENMP
 #include <omp.h>
+#endif // !_OPENMP
 
 #include <eo>
 #include <es/make_real.h>
@@ -42,6 +44,7 @@ int main(int ac, char** av)
 
     eo::log << eo::quiet << "DONE!" << std::endl;
 
+#ifdef _OPENMP
 #pragma omp parallel
     {
  if ( 0 == omp_get_thread_num() )
@@ -49,6 +52,7 @@ int main(int ac, char** av)
    eo::log << "num of threads: " << omp_get_num_threads() << std::endl;
      }
     }
+#endif // !_OPENMP
 
     return 0;
 }
diff --git a/eo/test/t-openmp.cpp b/eo/test/t-openmp.cpp
index d2f4cf3..ab301fd 100644
--- a/eo/test/t-openmp.cpp
+++ b/eo/test/t-openmp.cpp
@@ -37,7 +37,9 @@ Caner Candan <caner.candan@thalesgroup.com>
 
 #include <apply.h>
 
+#ifdef _OPENMP
 #include <omp.h>
+#endif // !_OPENMP
 
 #include <unistd.h>
 
