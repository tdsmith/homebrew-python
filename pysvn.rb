class Pysvn < Formula
  desc "Python interface to Subversion"
  homepage "http://pysvn.tigris.org/"
  url "http://pysvn.barrys-emacs.org/source_kits/pysvn-1.9.2.tar.gz"
  sha256 "4ff7a1983794107e2056abb008f6d0acd8ca5ac9126b815cf33388d0d80bb89e"

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
