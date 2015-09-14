class Numba < Formula
  desc "NumPy aware dynamic Python compiler using LLVM"
  homepage "http://numba.pydata.org/"
  url "https://pypi.python.org/packages/source/n/numba/numba-0.21.0.tar.gz"
  sha256 "1806d2f6ad49ad891e9ac6fed0cc0b0489cbfcd9ba2dc81081c1c30091e77604"

  bottle do
    sha256 "137e0c2d1377d31f9cc15f89ad84f1d2d2a203aa6fc8068c22b0803e9cbaab8d" => :yosemite
    sha256 "26fbb8d2a6c213c3820d9f09c641480204841b6c418d3e9c3fb740b15a72eeee" => :mavericks
    sha256 "28c11ce38a36a3934ab965862b1cb3073c2d544bf01667c3bfcf692cbae1dfb2" => :mountain_lion
  end

  option "without-python", "Build without python2 support"
  depends_on :python3 => :optional

  depends_on "llvm"
  depends_on "homebrew/python/numpy"

  resource "enum34" do
    url "https://pypi.python.org/packages/source/e/enum34/enum34-1.0.4.tar.gz"
    sha256 "d3c19f26a6a34629c18c775f59dfc5dd595764c722b57a2da56ebfb69b94e447"
  end

  resource "funcsigs" do
    url "https://pypi.python.org/packages/source/f/funcsigs/funcsigs-0.4.tar.gz"
    sha256 "d83ce6df0b0ea6618700fe1db353526391a8a3ada1b7aba52fed7a61da772033"
  end

  resource "llvmlite" do
    url "https://pypi.python.org/packages/source/l/llvmlite/llvmlite-0.7.0.tar.gz"
    sha256 "6d780980da05d2d82465991bce42c1b4625018d67feae17c672c6a9d5ad0bb1a"
  end

  resource "singledispatch" do
    url "https://pypi.python.org/packages/source/s/singledispatch/singledispatch-3.4.0.3.tar.gz"
    sha256 "5b06af87df13818d14f08a028e42f566640aef80805c3b50c5056b086e3c2b9c"
  end

  resource "six" do
    url "https://pypi.python.org/packages/source/s/six/six-1.9.0.tar.gz"
    sha256 "e24052411fc4fbd1f672635537c3fc2330d9481b18c0317695b46259512c91d5"
  end

  needs :cxx11
  cxxstdlib_check :skip

  def install
    Language::Python.each_python(build) do |python, pyver|
      ENV.prepend_create_path "PYTHONPATH", libexec/"vendor/lib/python#{pyver}/site-packages"
      if python == "python"
        %w[enum34 funcsigs singledispatch six].each do |r|
          resource(r).stage { system python, *Language::Python.setup_install_args(libexec/"vendor") }
        end
      end

      resource("llvmlite").stage do
        # https://github.com/numba/llvmlite/issues/97
        inreplace "ffi/Makefile.osx", /CXX =.*/, "\\0 -fno-rtti"
        system python, *Language::Python.setup_install_args(libexec/"vendor")
      end

      ENV.prepend_create_path "PYTHONPATH", libexec/"lib/python#{pyver}/site-packages"
      system python, *Language::Python.setup_install_args(libexec)

      site_packages = lib/"python#{pyver}/site-packages"
      site_packages.mkpath
      (site_packages/"homebrew-numba.pth").write <<-EOS.undent
        #{libexec}/vendor/lib/python#{pyver}/site-packages
        #{libexec}/lib/python#{pyver}/site-packages
      EOS
    end
    bin.install_symlink Dir[libexec/"bin/*"]
  end

  test do
    (testpath/"test.py").write <<-EOS.undent
      from numba import jit
      @jit
      def f(x, y):
        return x+y
      print(f(4, 3))
    EOS
    assert_match /7/, shell_output("python #{testpath}/test.py")
  end
end
