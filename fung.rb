require 'formula'

class Fung < Formula

  homepage "https://lubkoll.github.io/FunG/#home"
  
  head do
    url "https://github.com/lubkoll/FunG.git", :using => :git, :branch => "master"
  end
  
  option "with-tests",      "Build tests"

  depends_on "eigen"        => :optional
  
  needs :cxx11
  def install
    # Main header library
    system "mkdir -p #{prefix}/include"
    system "cp -r fung #{prefix}/include"
    system "rm -r #{prefix}/include/fung/examples"
    system "rm -r #{prefix}/include/fung/tests"
    ##include.install_symlink "#{prefix}/include"
    #include.install Dir["fung/*.hh"]
    #include.install Dir["fung/cmath/*"]
    #include.install Dir["fung/linear_algebra/*"]
    #include.install Dir["fung/mathematical_operations/*"]
    #include.install Dir["fung/util/*"]

    # Examples and documentation
    system "mkdir -p #{prefix}/share/fung"
    system "cp -r doc #{prefix}/share"
    system "cp -r cmake #{prefix}/share/fung"
    system "cp -r fung/examples #{prefix}/share/fung"
    ##share.install_symlink "#{prefix}/share"
    #share.install Dir["fung/examples/*"]
    #share.install Dir["cmake/*"]
    #share.install Dir["doc/*"]
    
    # Tests
    if build.with? "tests"
      system "mkdir -p #{prefix}/share/tests/fung"
      system "cp -r fung/tests #{prefix}/share/tests/fung"
      system "cp -r test #{prefix}/share/tests"
      system "cp -r cmake #{prefix}/share/tests"
      system "cp CMakeLists.txt #{prefix}/share/tests"
      
      ENV.cxx11
      args = %W[]
      
      #mkdir 'build' do
      #  system "cmake", *args, "#{prefix}/share/tests"
      #  system "ctest", "-j", Hardware::CPU.cores
      #end
    end
    
  end
  
  def test
    #system "make test"
  end

  def caveats
    
  end

end

