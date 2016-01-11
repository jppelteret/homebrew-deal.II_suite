require 'formula'

class Fadbadpp < Formula

  homepage "http://www.fadbad.com/fadbad.html"
  version '2.1'
  url "http://www.fadbad.com/download/FADBAD++-#{version}.tar.gz"
  sha1 '6b7a54add512b239df6d37c6a1c82356e804ab7e'
  
  option "with-tests",      "Build tests"
  
  needs :cxx11
  def install
    # Main header library
    system "mkdir -p #{prefix}/include/fadbad++"
    system "mv *.h #{prefix}/include/fadbad++"

    # Examples and documentation
    system "mkdir -p #{prefix}/share/fadbad++"
    system "cp -r examples/* #{prefix}/share/fadbad++"
    system "mv extra #{prefix}/share/fadbad++"
    
    # Tests
    if build.with? "tests"
      system "mkdir -p #{prefix}/share/tests"
      system "mv test #{prefix}/share/tests/fadbad++"
      
      Dir.chdir("#{prefix}/share/tests/fadbad++")
      inreplace "Makefile" do |s|
          s.gsub! "CFLAGS = -I..", "CFLAGS = -I#{prefix}/include/fadbad++" if s.include? "CFLAGS = -I.."
        end
    end
    
  end
  
  def test
    ohai "running tests"
    cp_r prefix/"share/tests/fadbad++", testpath
    cp_r prefix/"include/fadbad++", testpath
    cp_r prefix/"share/fadbad++", testpath
    Dir.chdir("fadbad++") do
      system "make", "all"
      system "./ExampleBAD"
      system "./ExampleFAD"
      system "./ExampleTAD1"
      system "./ExampleTAD2"
      system "./ExampleTAD3"
      system "./ExampleBADFAD1"
      system "./ExampleBADFAD2"
      system "./ExampleBADFAD3"
      system "./ExampleBADFAD4"
      system "./MonteCarlo"
    end
  end

  def caveats
    
  end

end

