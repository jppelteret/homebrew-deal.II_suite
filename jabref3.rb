class Jabref3 < Formula
  desc "An open source bibliography reference manager"
  homepage "http://www.jabref.org/"
  version '3.1'
  url "http://downloads.sourceforge.net/project/jabref/v#{version}/JabRef-#{version}.jar"
  sha256 "81adaa1b672535e7b64814b6ad8f6a00e8bcf0a82b0849ba4523e36cd440425d"

  bottle :unneeded

  depends_on :java => "1.7+"

  def install
    libexec.install "JabRef-#{version}.jar"
    bin.write_jar_script libexec/"JabRef-#{version}.jar", "jabref3"
  end

  test do
    system "#{bin}/jabref3"
  end
end
