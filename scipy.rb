require 'formula'

class Scipy < Formula
  homepage 'http://www.scipy.org'
  url 'https://downloads.sourceforge.net/project/scipy/scipy/0.14.0/scipy-0.14.0.tar.gz'
  sha1 'faf16ddf307eb45ead62a92ffadc5288a710feb8'
  head 'https://github.com/scipy/scipy.git'
  revision 1

  depends_on :python => :recommended
  depends_on :python3 => :optional
  depends_on 'swig' => :build
  depends_on :fortran
  option 'with-openblas', "Use openBLAS instead of Apple's Accelerate Framework"
  depends_on 'homebrew/science/openblas' => :optional

  numpy_options = []
  numpy_options << "with-python3" if build.with? "python3"
  numpy_options << "with-openblas" if build.with? "openblas"
  depends_on "numpy" => numpy_options

  cxxstdlib_check :skip

  # allow tests to pass on numpy 1.9.1
  # https://github.com/Homebrew/homebrew-python/issues/178
  patch do
    url "https://github.com/scipy/scipy/commit/8b0575.diff"
    sha1 "b8de832ef4b11cd346c54aabbd68ce5923da64d5"
  end

  def install
    config = <<-EOS.undent
      [DEFAULT]
      library_dirs = #{HOMEBREW_PREFIX}/lib
      include_dirs = #{HOMEBREW_PREFIX}/include

    EOS
    if build.with? 'openblas'
      # For maintainers:
      # Check which BLAS/LAPACK numpy actually uses via:
      # xcrun otool -L $(brew --prefix)/Cellar/scipy/<version>/lib/python2.7/site-packages/scipy/linalg/_flinalg.so
      # or the other .so files.
      openblas_dir = Formula["openblas"].opt_prefix
      # Setting ATLAS to None is important to prevent numpy from always
      # linking against Accelerate.framework.
      ENV['ATLAS'] = "None"
      ENV['BLAS'] = ENV['LAPACK'] = "#{openblas_dir}/lib/libopenblas.dylib"

      config << <<-EOS.undent
        [openblas]
        libraries = openblas
        library_dirs = #{openblas_dir}/lib
        include_dirs = #{openblas_dir}/include
      EOS
    else
      # https://github.com/Homebrew/homebrew-python/issues/110
      # There are ongoing problems with gcc+accelerate.
      odie "Please use brew install --with-openblas scipy to compile scipy using gcc." if ENV.compiler =~ /gcc-(4\.[3-9])/

      # https://github.com/Homebrew/homebrew-python/pull/73
      # Only save for gcc and allows you to `brew install scipy --cc=gcc-4.8`
      # ENV.append 'CPPFLAGS', '-D__ACCELERATE__' if ENV.compiler =~ /gcc-(4\.[3-9])/
    end

    Pathname('site.cfg').write config

    if (HOMEBREW_CELLAR/"gfortran").directory?
        opoo <<-EOS.undent
            It looks like the deprecated gfortran formula is installed.
            This causes build problems with scipy. gfortran is now provided by
            the gcc formula. Please run:
                brew rm gfortran
                brew install gcc
            if you encounter problems.
        EOS
    end

    # gfortran is gnu95
    Language::Python.each_python(build) do |python, version|
      ENV.prepend_create_path "PYTHONPATH", lib/"python#{version}/site-packages"
      system python, "setup.py", "build", "--fcompiler=gnu95"
      system python, *Language::Python.setup_install_args(prefix)
    end
  end

  test do
    Language::Python.each_python(build) do |python, version|
      system python, "-c", "import scipy; assert not scipy.test().failures"
    end
  end

  def caveats
    if build.with? "python" and not Formula["python"].installed?
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

end
