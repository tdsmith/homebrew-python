class Numpy < Formula
  homepage "http://www.numpy.org"
  url "https://downloads.sourceforge.net/project/numpy/NumPy/1.9.2/numpy-1.9.2.tar.gz"
  sha256 "325e5f2b0b434ecb6e6882c7e1034cc6cdde3eeeea87dbc482575199a6aeef2a"
  head "https://github.com/numpy/numpy.git"
  revision 1

  bottle do
    root_url "https://homebrew.bintray.com/bottles-python"
    sha256 "95c8fdecedf44341c655b7257319c4f815e9446613af2ee0892d5ea5b161cb29" => :yosemite
    sha256 "b53604d6433256dad5f11f18b118350e31516d9f78e0b731855ae6aacae8f79a" => :mavericks
    sha256 "015370402167df9a4e27dd1f8502cfb7ca8826be317a3a6b870fe62de2d99e91" => :mountain_lion
  end

  option "without-python", "Build without python2 support"

  depends_on :python => :recommended if MacOS.version <= :snow_leopard
  depends_on :python3 => :optional
  depends_on :fortran

  option "with-openblas", "Use openBLAS instead of Apple's Accelerate Framework"
  depends_on "homebrew/science/openblas" => (OS.mac? ? :optional : :recommended)

  resource "nose" do
    url "https://pypi.python.org/packages/source/n/nose/nose-1.3.4.tar.gz"
    sha256 "76bc63a4e2d5e5a0df77ca7d18f0f56e2c46cfb62b71103ba92a92c79fab1e03"
  end

  stable do
    # fix build with build_ext --include-dirs set
    # https://github.com/numpy/numpy/pull/5866
    patch :DATA
  end

  def install
    ENV["HOME"] = buildpath

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

  test do
    Language::Python.each_python(build) do |python, _version|
      system python, "-c", "import numpy; numpy.test()"
    end
  end

  def caveats
    if build.with? "python" && !Formula["python"].installed?
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
diff --git a/numpy/distutils/command/build_ext.py b/numpy/distutils/command/build_ext.py
index b48e422..4311758 100644
--- a/numpy/distutils/command/build_ext.py
+++ b/numpy/distutils/command/build_ext.py
@@ -46,10 +46,14 @@ class build_ext (old_build_ext):
         self.fcompiler = None

     def finalize_options(self):
-        incl_dirs = self.include_dirs
+        if isinstance(self.include_dirs, str):
+            self.include_dirs = self.include_dirs.split(os.pathsep)
+        incl_dirs = self.include_dirs or []
+        if self.distribution.include_dirs is None:
+            self.distribution.include_dirs = []
+        self.include_dirs = self.distribution.include_dirs
+        self.include_dirs.extend(incl_dirs)
         old_build_ext.finalize_options(self)
-        if incl_dirs is not None:
-            self.include_dirs.extend(self.distribution.include_dirs or [])

     def run(self):
         if not self.extensions:
