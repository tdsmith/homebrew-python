class Scipy < Formula
  homepage 'http://www.scipy.org'
  url "https://pypi.python.org/packages/source/s/scipy/scipy-0.16.0.tar.gz"
  sha256 "92592f40097098f3fdbe7f5855d535b29bb16719c2bb59c728bce5e7a28790e0"
  head 'https://github.com/scipy/scipy.git'

  bottle do
    sha256 "18f227d835bf67019aa6f383aa40ffe508201dff905ada6c8f8c8968e56dc689" => :yosemite
    sha256 "41800796d4506283f30d127f2186ac2a0e540471b6c78841d5e1aa1b8662d23b" => :mavericks
    sha256 "596824c7b0168b6ef05f6c04c64864f926c51266a18f1c9eaf9cdde17c356e79" => :mountain_lion
  end

  option "without-python", "Build without python2 support"

  depends_on 'swig' => :build
  depends_on :python => :recommended if MacOS.version <= :snow_leopard
  depends_on :python3 => :optional
  depends_on :fortran

  option "with-openblas", "Use openblas instead of Apple's Accelerate framework " \
                          "(required to build with gcc on OS X)"
  depends_on "homebrew/science/openblas" => (OS.mac? ? :optional : :recommended)

  numpy_options = []
  numpy_options << "with-python3" if build.with? "python3"
  numpy_options << "with-openblas" if build.with? "openblas"
  depends_on "homebrew/python/numpy" => numpy_options

  cxxstdlib_check :skip

  # https://github.com/Homebrew/homebrew-python/issues/110
  # There are ongoing problems with gcc+accelerate.
  fails_with :gcc if OS.mac? && build.without?("openblas")

  stable do
    # Hint Python headers
    # https://github.com/scipy/scipy/issues/5154
    patch :DATA
  end

  def install
    # avoid user numpy distutils config files
    ENV["HOME"] = buildpath

    # https://github.com/numpy/numpy/issues/4203
    # https://github.com/Homebrew/homebrew-python/issues/209
    # https://github.com/Homebrew/homebrew-python/issues/233
    if OS.linux?
      ENV.append "FFLAGS", "-fPIC"
      ENV.append "LDFLAGS", "-shared"
    end

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
    end

    Pathname('site.cfg').write config

    # gfortran is gnu95
    Language::Python.each_python(build) do |python, version|
      ENV["PYTHONPATH"] = Formula["numpy"].opt_lib/"python#{version}/site-packages"
      ENV.prepend_create_path "PYTHONPATH", lib/"python#{version}/site-packages"
      system python, "setup.py", "build", "--fcompiler=gnu95"
      system python, *Language::Python.setup_install_args(prefix)
    end
  end

  # cleanup leftover .pyc files from previous installs which can cause problems
  # see https://github.com/Homebrew/homebrew-python/issues/185#issuecomment-67534979
  def post_install
    Language::Python.each_python(build) do |python, version|
      rm_f Dir["#{HOMEBREW_PREFIX}/lib/python#{version}/site-packages/scipy/**/*.pyc"]
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
__END__
diff --git a/scipy/linalg/setup.py b/scipy/linalg/setup.py
index 452673d..56c8dd1 100755
--- a/scipy/linalg/setup.py
+++ b/scipy/linalg/setup.py
@@ -6,6 +6,7 @@


 def configuration(parent_package='',top_path=None):
+    from distutils.sysconfig import get_python_inc
     from numpy.distutils.system_info import get_info, NotFoundError, numpy_info
     from numpy.distutils.misc_util import Configuration, get_numpy_include_dirs
     from scipy._build_utils import (get_sgemv_fix, get_g77_abi_wrappers,
@@ -137,7 +138,7 @@ def configuration(parent_package='',top_path=None):
     sources = ['_blas_subroutine_wrappers.f', '_lapack_subroutine_wrappers.f']
     sources += get_g77_abi_wrappers(lapack_opt)
     sources += get_sgemv_fix(lapack_opt)
-    includes = numpy_info().get_include_dirs()
+    includes = numpy_info().get_include_dirs() + [get_python_inc()]
     config.add_library('fwrappers', sources=sources, include_dirs=includes)

     config.add_extension('cython_blas',
