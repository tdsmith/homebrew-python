class Numpy < Formula
  desc "Package for scientific computing with Python"
  homepage "http://www.numpy.org"
  url "https://pypi.python.org/packages/source/n/numpy/numpy-1.10.4.tar.gz"
  sha256 "7356e98fbcc529e8d540666f5a919912752e569150e9a4f8d869c686f14c720b"
  head "https://github.com/numpy/numpy.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "6aa55385baad3df7b22edbcf8a8fda407e73a98dffb0fb5370705d2184806fd2" => :el_capitan
    sha256 "a6d8ff26322d381fbb863e47aeda1a8f727b981f1d274e27b5f3d3f9b590c522" => :yosemite
    sha256 "d14df008d4b178f7ace9d06fd18de710050b53a9ef9b14a9fcedc6b21903199c" => :mavericks
  end

  option "without-python", "Build without python2 support"

  depends_on :python => :recommended if MacOS.version <= :snow_leopard
  depends_on :python3 => :optional
  depends_on :fortran

  option "with-openblas", "Use openBLAS instead of Apple's Accelerate Framework"
  depends_on "homebrew/science/openblas" => (OS.mac? ? :optional : :recommended)

  resource "nose" do
    url "https://pypi.python.org/packages/source/n/nose/nose-1.3.7.tar.gz"
    sha256 "f1bffef9cbc82628f6e7d7b40d7e255aefaa1adb6a1b1d26c69a8b79e6208a98"
  end

  def install
    # https://github.com/numpy/numpy/issues/4203
    # https://github.com/Homebrew/homebrew-python/issues/209
    ENV.append "LDFLAGS", "-shared" if OS.linux?

    if build.with? "openblas"
      openblas_dir = Formula["openblas"].opt_prefix
      # Setting ATLAS to None is important to prevent numpy from always
      # linking against Accelerate.framework.
      ENV["ATLAS"] = "None"
      ENV["BLAS"] = ENV["LAPACK"] = "#{openblas_dir}/lib/libopenblas.dylib"

      config = <<-EOS.undent
        [openblas]
        libraries = openblas
        library_dirs = #{openblas_dir}/lib
        include_dirs = #{openblas_dir}/include
      EOS
      (buildpath/"site.cfg").write config
    end

    Language::Python.each_python(build) do |python, version|
      resource("nose").stage do
        system python, *Language::Python.setup_install_args(libexec/"nose")
        nose_path = libexec/"nose/lib/python#{version}/site-packages"
        dest_path = lib/"python#{version}/site-packages"
        mkdir_p dest_path
        (dest_path/"homebrew-numpy-nose.pth").write "#{nose_path}\n"
      end
      system python, "setup.py", "build", "--fcompiler=gnu95",
                     "install", "--prefix=#{prefix}"
    end
  end

  def caveats
    if build.with?("python") && !Formula["python"].installed?
      homebrew_site_packages = Language::Python.homebrew_site_packages
      user_site_packages = Language::Python.user_site_packages "python"
      <<-EOS.undent
        If you use system python (that comes - depending on the OS X version -
        with older versions of numpy, scipy and matplotlib), you may need to
        ensure that the brewed packages come earlier in Python's sys.path with:
          mkdir -p #{user_site_packages}
          echo 'import sys; sys.path.insert(1, "#{homebrew_site_packages}")' >> #{user_site_packages}/homebrew.pth
      EOS
    end
  end

  test do
    Language::Python.each_python(build) do |python, _version|
      system python, "-c", "import numpy; assert numpy.test().wasSuccessful()"
    end
  end
end
