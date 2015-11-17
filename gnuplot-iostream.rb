require 'formula'

class GnuplotIOStream < Formula

  # More info: http://www.stahlke.org/dan/gnuplot-iostream/
  homepage "https://github.com/dstahlke/gnuplot-iostream/wiki"
  
  head do
    url "https://github.com/dstahlke/gnuplot-iostream.git", :using => :git, :branch => "master"
  end

  #option "with-python_bindings", "Build Python bindings"
  # option "with-docs",            "Build documentation"
  # option "with-tests",           "Build tests"
  # option "with-full_logging",    "Enable full logging"
  # option "force_serial",         "Force the use of a single core for computation"

  # See https://openann.github.io/OpenANN-apidoc/Installation.html
  depends_on "boost"
  depends_on "gnuplot"
  # depends_on "cmake"        => :build
  # depends_on "pkg-config"   => :build
  # depends_on "wget"         => :build
  # depends_on "eigen"        => :build
  # depends_on "doxygen"      => [:build] if build.with? "docs"
  # depends_on "graphviz"     => [:build] if build.with? "docs"
  # depends_on "python"       => [:build] if build.with? "tests"
  # depends_on "matplotlib"   => [:build] if build.with? "tests"
  # depends_on "scipy"        => [:build] if build.with? "tests"
  #depends_on "python"       => [:build] if build.with? "python_bindings" or build.with? "tests"
  #depends_on "numpy"        => [:build] if build.with? "python_bindings"
  #depends_on "cython"       => [:build] if build.with? "python_bindings" # Does not exist!

  # Patch cmake includes to find libraries in homebrew path
  #patch :DATA

  def install
    #ENV.deparallelize
    # mkdir 'build' do
    #   system "cmake", *args, "../"
    #   system "make", "VERBOSE=1"
    #   system "make install"
    # end
    include.install_symlink Dir["*h"]
  end

  def caveats
    
  end

end

