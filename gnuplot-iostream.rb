require 'formula'

class GnuplotIostream < Formula

  # More info: http://www.stahlke.org/dan/gnuplot-iostream/
  homepage "https://github.com/dstahlke/gnuplot-iostream/wiki"
  
  head do
    url "https://github.com/dstahlke/gnuplot-iostream.git", :using => :git, :branch => "master"
  end
  
  option "with-tests",           "Build tests"

  depends_on "boost"
  depends_on "gnuplot"

  def install
    system "mkdir -p #{prefix}/include"
    system "cp *.h #{prefix}/include"
    
    include.install_symlink "#{prefix}/include/*.h"
    #system "make test" if build.with? "tests"
  end
  
  def test
    #system "make test"
  end

  def caveats
    
  end

end

