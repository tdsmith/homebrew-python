class Numba < Formula
  desc "NumPy aware dynamic Python compiler using LLVM"
  homepage "http://numba.pydata.org/"
  url "https://pypi.python.org/packages/source/n/numba/numba-0.23.1.tar.gz"
  sha256 "80ce9968591db7c93e36258cc5e6734eb1e42826332799746dc6c073a6d5d317"

  bottle do
    sha256 "51ef0baa6f63d3bb88e1a4c94ff36464255dbb886563d5fa047269dc5e28fcb5" => :el_capitan
    sha256 "54be52f21878e978375728649edc688d243720497d2f6c51e0f65d53fceae068" => :yosemite
    sha256 "7d734629218937dea104c93c5a85ede3ec0c0d532b3371f7605122889249336c" => :mavericks
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
    url "https://pypi.python.org/packages/source/l/llvmlite/llvmlite-0.8.0.tar.gz"
    sha256 "a10d8d5e597c6a54ec418baddd31a51a0b7937a895d75b240d890aead946081c"
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
