require 'formula'

class Openann < Formula

  homepage "https://openann.github.io/OpenANN-apidoc/index.html"
  url "https://github.com/OpenANN/OpenANN/archive/1.1.0.tar.gz"
  sha1 '8f8674c1887e4dafe5cf997dbb9cd93ea2c3bdfc'

  head do
    url "https://github.com/OpenANN/OpenANN.git", :using => :git, :branch => "master"
  end

  #option "with-python_bindings", "Build Python bindings"
  option "with-docs",            "Build documentation"
  option "with-tests",           "Build tests"
  option "with-full_logging",    "Enable full logging"
  option "force_serial",         "Force the use of a single core for computation"

  # See https://openann.github.io/OpenANN-apidoc/Installation.html
  depends_on "cmake"        => :build
  depends_on "pkg-config"   => :build
  depends_on "wget"         => :build
  depends_on "eigen"        => :build
  depends_on "doxygen"      => [:build] if build.with? "docs"
  depends_on "graphviz"     => [:build] if build.with? "docs"
  depends_on "python"       => [:build] if build.with? "tests"
  depends_on "matplotlib"   => [:build] if build.with? "tests"
  depends_on "scipy"        => [:build] if build.with? "tests"
  #depends_on "python"       => [:build] if build.with? "python_bindings" or build.with? "tests"
  #depends_on "numpy"        => [:build] if build.with? "python_bindings"
  #depends_on "cython"       => [:build] if build.with? "python_bindings" # Does not exist!

  # Patch cmake includes to find libraries in homebrew path
  patch :DATA

  def install
    #ENV.deparallelize
    args  = %W[-DCMAKE_INSTALL_PREFIX=#{prefix}
               -DCMAKE_BUILD_TYPE=Release] # Must have a release/debug option in order to compile
    args << "-DCMAKE_PREFIX_PATH=#{HOMEBREW_PREFIX}" # constrain Cmake to look for libraries in homebrew's prefix
    args << ("-DLOG_LEVEL="                  + ((build.with? "full_logging") ? "DEBUG" : "INFO"))
    args << ("-DPARALLEL_CORES="             + ((build.with? "force_serial") ? "1" : "2"))
    args << ("-DALWAYS_BUILD_DOCUMENTATION=" + ((build.with? "docs") ? "ON" : "OFF"))
    args << ("-DBUILD_PYTHON="               + ((build.with? "python_bindings") ? "ON" : "OFF"))
    args << ("-DEXCLUDE_TESTS_FROM_ALL="     + ((build.with? "tests") ? "OFF" : "ON"))

    mkdir 'build' do
      system "cmake", *args, "../"
      system "make", "VERBOSE=1"
      system "make install"
    end
  end

  def caveats
    "Test will probably fail with: No rule to make target `test/lib/CPP-Test/CMakeFiles/CPPTest.dir/depend'. "
  end

end

__END__
diff --git a/cmake/FindEigen3.cmake b/cmake/FindEigen3.cmake
index 1aeeb1f..203de1e 100644
--- a/cmake/FindEigen3.cmake
+++ b/cmake/FindEigen3.cmake
@@ -2,6 +2,7 @@ find_path(EIGEN3_INCLUDE_DIRS Eigen/Dense
   ${CMAKE_INSTALL_PREFIX}/include/eigen3
   /usr/include/eigen3
   /opt/local/include/eigen3
+  HOMEBREW_PREFIX/include/eigen3
   DOC "Eigen 3 include directory")

 set(EIGEN3_FOUND ${EIGEN3_INCLUDE_DIRS} CACHE BOOL "" FORCE)
