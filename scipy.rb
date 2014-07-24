require 'formula'

class Scipy < Formula
  homepage 'http://www.scipy.org'
  url 'https://downloads.sourceforge.net/project/scipy/scipy/0.14.0/scipy-0.14.0.tar.gz'
  sha1 'faf16ddf307eb45ead62a92ffadc5288a710feb8'
  head 'https://github.com/scipy/scipy.git'

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

  resource "wheel" do
    url "https://pypi.python.org/packages/source/w/wheel/wheel-0.24.0.tar.gz"
    sha1 "c02262299489646af253067e8136c060a93572e3"
  end

  resource "delocate" do
    url "https://github.com/matthew-brett/delocate/archive/0.4.0.tar.gz"
    sha1 "4a9e27c3863ad1452801e90a0f451b4a95eaa31e"
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

    if HOMEBREW_CELLAR.subdirs.map{ |f| File.basename f }.include? 'gfortran'
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
      system python, "setup.py", "build", "--fcompiler=gnu95", "install", "--prefix=#{prefix}"
    end

    mkdir_p libexec/"lib/python2.7/site-packages"
    ENV["PYTHONPATH"] = libexec/"lib/python2.7/site-packages"
    %w[wheel delocate].each do |r|
      resource(r).stage { system "python", "setup.py", "install", "--prefix=#{libexec}" }
    end
    delocate = <<-EOS.undent
      from delocate import delocate_path
      gcc_filter = lambda x: "/gcc/" in x
      delocate_path("#{lib}", "#{libexec}/lib", copy_filt_func=gcc_filter)
    EOS
    system "python", "-c", delocate
  end

  test do
    Language::Python.each_python(build) do |python, version|
      system python, "-c", "import scipy; scipy.test()"
    end
  end

  def caveats
    if build.with? "python" and not Formula['python'].installed?
      <<-EOS.undent
        If you use system python (that comes - depending on the OS X version -
        with older versions of numpy, scipy and matplotlib), you actually may
        have to set the `PYTHONPATH` in order to make the brewed packages come
        before these shipped packages in Python's `sys.path`.
            export PYTHONPATH=#{HOMEBREW_PREFIX}/lib/python2.7/site-packages
      EOS
    end
  end

end
