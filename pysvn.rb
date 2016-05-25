class Pysvn < Formula
  desc "Python interface to Subversion"
  homepage "http://pysvn.tigris.org/"
  url "http://pysvn.barrys-emacs.org/source_kits/pysvn-1.9.2.tar.gz"
  sha256 "4ff7a1983794107e2056abb008f6d0acd8ca5ac9126b815cf33388d0d80bb89e"

  bottle do
    cellar :any
    sha256 "99abe8206b8974d5f38a822a2e2cccf07c00650a8ef8aab8e1b554ddfa88ff55" => :el_capitan
    sha256 "6e92a01ee0d9668e14a3bc52b1f0567c3af2b551ad02619e7daed2869ff0c051" => :yosemite
    sha256 "fd8995e6ecf029abaf5c24efe462e859d447af01f55d0f67e4447d3c277222aa" => :mavericks
  end

  option "without-python", "Build without python2 support"
  depends_on :python3 => :optional
  depends_on "subversion"

  def install
    cd "Source"
    Language::Python.each_python(build) do |python, version|
      system "make", "clean" if File.exist?("Makefile")
      system python, "setup.py", "configure", "--link-python-framework-via-dynamic-lookup"
      system "make"
      (lib/"python#{version}/site-packages/pysvn").install "pysvn/__init__.py", Dir["pysvn/_pysvn*.so"]
    end
  end

  test do
    system "svnadmin", "create", "test"
    Language::Python.each_python(build) do |python, _version|
      system python, "-c", "import os, pysvn; pysvn.Client().info2('file://' + os.path.join(os.getcwd(), 'test'))"
    end
  end
end
