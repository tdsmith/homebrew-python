require "formula"

class Vpython < Formula
  url "https://downloads.sourceforge.net/project/vpythonwx/6.10-release/vpython-wx-src.6.10.tgz"
  sha1 "d51ca07dad92a1ae9a3d5cc57af48b180f457228"
  head "https://github.com/BruceSherwood/vpython-wx.git"
  homepage "http://vpython.org/"

  # no simultaneous python2+3 support from Homebrew boost yet
  depends_on :python
  depends_on "numpy"
  depends_on "wxpython"

  boost_args = ["with-python"]
  boost_args << "c++11" if MacOS.version < :mavericks
  depends_on "boost" => boost_args

  needs :cxx11
  # spurious errors because dependent numpy depends_on gcc through :fortran
  # https://github.com/Homebrew/homebrew/issues/30474
  cxxstdlib_check :skip

  def install
    ENV.cxx11
    system "python", "setup.py", "install", "--prefix=#{prefix}", "--single-version-externally-managed",
                     "--record=installed.txt"
  end

  test do
    system "python", "-c", "import visual"
  end
end
