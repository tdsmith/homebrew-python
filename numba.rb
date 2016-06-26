class Numba < Formula
  desc "NumPy aware dynamic Python compiler using LLVM"
  homepage "http://numba.pydata.org/"
  url "https://files.pythonhosted.org/packages/6f/b1/e3773ec83b112caddc6d3808326c241f59261f569e6a8db90a2bde89c66e/numba-0.26.0.tar.gz"
  sha256 "84547fdd19783104a37f3662a45b8b32f940b2af55d2eb0467dc782af43420aa"

  bottle do
    sha256 "6819683ae11a1fc89b9e99c10c94e85ea5a8973df354687ee2c4aa43e7f5d579" => :el_capitan
    sha256 "fd96119f466ce803c840b1fdda51369df7640b335e1a569245575dbe4c4f8794" => :yosemite
    sha256 "f3234cb6e634c95ca604ffa9f95e8df70b829764877b24bf0503ae6338e4f5d4" => :mavericks
  end

  option "without-python", "Build without python2 support"
  depends_on :python3 => :optional

  depends_on "homebrew/versions/llvm37"
  depends_on "homebrew/python/numpy"

  resource "enum34" do
    url "https://files.pythonhosted.org/packages/bf/3e/31d502c25302814a7c2f1d3959d2a3b3f78e509002ba91aea64993936876/enum34-1.1.6.tar.gz"
    sha256 "8ad8c4783bf61ded74527bffb48ed9b54166685e4230386a9ed9b1279e2df5b1"
  end

  resource "funcsigs" do
    url "https://files.pythonhosted.org/packages/94/4a/db842e7a0545de1cdb0439bb80e6e42dfe82aaeaadd4072f2263a4fbed23/funcsigs-1.0.2.tar.gz"
    sha256 "a7bb0f2cf3a3fd1ab2732cb49eba4252c2af4240442415b4abce3b87022a8f50"
  end

  resource "llvmlite" do
    url "https://files.pythonhosted.org/packages/3c/bc/3548a91224b06c3fc29715d42483a14bfb67427d7e6d7873ce46338b5916/llvmlite-0.11.0.tar.gz"
    sha256 "93cfee5bb9e4d16e42d8986b480191a4c1f149a5818c654d58ae142449f382bd"
  end

  resource "singledispatch" do
    url "https://files.pythonhosted.org/packages/d9/e9/513ad8dc17210db12cb14f2d4d190d618fb87dd38814203ea71c87ba5b68/singledispatch-3.4.0.3.tar.gz"
    sha256 "5b06af87df13818d14f08a028e42f566640aef80805c3b50c5056b086e3c2b9c"
  end

  resource "setuptools" do
    url "https://files.pythonhosted.org/packages/9f/7c/0a33c528164f1b7ff8cf0684cf88c2e733c8ae0119ceca4a3955c7fc059d/setuptools-23.1.0.tar.gz"
    sha256 "4e269d36ba2313e6236f384b36eb97b3433cf99a16b94c74cca7eee2b311f2be"
  end

  resource "six" do
    url "https://files.pythonhosted.org/packages/b3/b2/238e2590826bfdd113244a40d9d3eb26918bd798fc187e2360a8367068db/six-1.10.0.tar.gz"
    sha256 "105f8d68616f8248e24bf0e9372ef04d3cc10104f1980f54d57b2ce73a5ad56a"
  end

  needs :cxx11
  cxxstdlib_check :skip

  def install
    Language::Python.each_python(build) do |python, pyver|
      ENV.prepend_create_path "PYTHONPATH", libexec/"vendor/lib/python#{pyver}/site-packages"
      if python == "python"
        %w[setuptools enum34 funcsigs singledispatch six].each do |r|
          resource(r).stage { system python, *Language::Python.setup_install_args(libexec/"vendor") }
        end
      end

      resource("llvmlite").stage do
        ENV["LLVM_CONFIG"] = which "llvm-config-3.7"
        # https://github.com/numba/llvmlite/issues/177
        inreplace "setup.py", "distutils.command.install", "setuptools.command.install"
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
