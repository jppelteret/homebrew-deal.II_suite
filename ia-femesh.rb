require 'formula'

class IAFEMesh < Formula

  homepage "https://www.ccad.uiowa.edu/MIMX/projects/IA-FEMesh"
  head do
    url "https://github.com/ctpr/IA-FEMesh.git", :using => :git, :branch => "master"
  end

  depends_on "cmake"        => :build

  def install
    args  = %W[-DCMAKE_INSTALL_PREFIX=#{prefix}
               -DCMAKE_BUILD_TYPE=Release]
    args << "-DCMAKE_PREFIX_PATH=#{HOMEBREW_PREFIX}" # constrain Cmake to look for libraries in homebrew's prefix

    mkdir 'build' do
      system "cmake", *args, "../"
      system "make", "VERBOSE=1"
      system "make install"
    end
  end

end
