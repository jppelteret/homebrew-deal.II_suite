require 'formula'

class Fadbadpp < Formula

  homepage "http://www.imm.dtu.dk/fadbad.html"
  url "http://www.imm.dtu.dk/%7Ekm/FADBAD/FADBAD++-1.4.tar.gz"
  sha1 '953128f03e1c4754c0192c205865bc1a6f5dabda'
  
  option "with-tests",      "Build tests"
  
  needs :cxx11
  def install
    # Main header library
    system "mkdir -p #{prefix}/include"
    system "mv *.h #{prefix}/include"

    # Examples and documentation
    system "mkdir -p #{prefix}/share/fadbad++"
    system "cp -r EXAMPLES/* #{prefix}/share/fadbad++"
    
    # Tests
    if build.with? "tests"
      system "mkdir -p #{prefix}/share/tests"
      system "mv TEST #{prefix}/share/tests/fadbad++"
      
      Dir.chdir("#{prefix}/share/tests/fadbad++")
      inreplace "Makefile" do |s|
          s.gsub! "CFLAGS = -I..", "CFLAGS = -I#{prefix}/include" if s.include? "CFLAGS = -I.."
        end
    end
    
  end
  
  def test
    # take bare-bones step-3
    ohai "running tests"
    cp_r prefix/"share/tests/fadbad++", testpath
    Dir.chdir("fadbad++") do
      system "make", "all"
      system "./TestAll"
    end
  end

  def caveats
    
  end

end

