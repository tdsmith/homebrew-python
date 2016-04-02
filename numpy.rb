class Numpy < Formula
  desc "Package for scientific computing with Python"
  homepage "http://www.numpy.org"
  url "https://pypi.python.org/packages/source/n/numpy/numpy-1.11.0.tar.gz"
  sha256 "a1d1268d200816bfb9727a7a27b78d8e37ecec2e4d5ebd33eb64e2789e0db43e"
  head "https://github.com/numpy/numpy.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "965f01d919ba6ff326a89323695daafed1b5d5d04f7ecc799fa5f060f6b1b68a" => :el_capitan
    sha256 "731d24a96f667c3b35ab4bee94ce3a047d18668f5310618c94717ac9e07f0941" => :yosemite
    sha256 "59c48e12bf686909c23d99388d999ef05f425ffbc3931e359a4fc825985b6fe1" => :mavericks
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
      dest_path = lib/"python#{version}/site-packages"
      dest_path.mkpath

      resource("nose").stage do
        system python, *Language::Python.setup_install_args(libexec/"nose")
        nose_path = libexec/"nose/lib/python#{version}/site-packages"
        (dest_path/"homebrew-numpy-nose.pth").write "#{nose_path}\n"
      end

      system python, "setup.py",
        "build", "--fcompiler=gnu95", "--parallel=#{ENV.make_jobs}",
        "install", "--prefix=#{prefix}",
        "--single-version-externally-managed", "--record=installed.txt"
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
