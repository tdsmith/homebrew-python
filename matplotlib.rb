class DvipngRequirement < Requirement
  fatal false
  cask "matctex"

  satisfy { which("dvipng") }

  def message
    s = <<-EOS.undent
      `dvipng` not found. This is optional for Matplotlib.
    EOS
    s += super
    s
  end
end

class NoExternalPyCXXPackage < Requirement
  fatal false

  satisfy do
    !quiet_system "python", "-c", "import CXX"
  end

  def message; <<-EOS.undent
    *** Warning, PyCXX detected! ***
    On your system, there is already a PyCXX version installed, that will
    probably make the build of Matplotlib fail. In python you can test if that
    package is available with `import CXX`. To get a hint where that package
    is installed, you can:
        python -c "import os; import CXX; print(os.path.dirname(CXX.__file__))"
    See also: https://github.com/Homebrew/homebrew-python/issues/56
    EOS
  end
end

class Matplotlib < Formula
  homepage "http://matplotlib.org"
  url "https://pypi.python.org/packages/source/m/matplotlib/matplotlib-1.4.3.tar.gz"
  sha256 "61f201c6a82e89e4d9e324266203fad44f95fd8f36d8eec0d8690273e1182f75"
  head "https://github.com/matplotlib/matplotlib.git"

  bottle do
    root_url "https://homebrew.bintray.com/bottles-python"
    sha256 "b3f67caebdcf086943f973fda99e4f5c7bbc3f72b82623bfbed4ffe027376aef" => :yosemite
    sha256 "9ac2bc778d212248e93e758e9b0c1ac495012d904dac88c269f9882342a4503b" => :mavericks
    sha256 "bebebabfa0adfc74e18db8ced70c4aa32effc202a1bb960a67f9164bff688798" => :mountain_lion
  end

  option "without-python", "Build without python2 support"
  depends_on :python => :recommended if MacOS.version <= :snow_leopard
  depends_on :python3 => :optional

  requires_py2 = []
  requires_py2 << "with-python" if build.with? "python"
  requires_py3 = []
  requires_py3 << "with-python3" if build.with? "python3"

  option "with-cairo", "Build with cairo backend support"
  option "with-pygtk", "Build with pygtk backend support (python2 only)"
  deprecated_option "with-gtk3" => "with-gtk+3"

  depends_on NoExternalPyCXXPackage => :build
  depends_on "pkg-config" => :build

  depends_on "freetype"
  depends_on "libpng"
  depends_on "homebrew/python/numpy" => requires_py3
  depends_on "ghostscript" => :optional
  depends_on "homebrew/dupes/tcl-tk" => :optional

  if build.with? "cairo"
    depends_on "py2cairo" if build.with? "python"
    depends_on "py3cairo" if build.with? "python3"
  end

  depends_on "gtk+3" => :optional
  depends_on "pygobject3" => requires_py3 if build.with? "gtk+3"

  depends_on "pygtk" => :optional
  depends_on "pygobject" if build.with? "pygtk"

  depends_on "pyside" => [:optional] + requires_py3
  depends_on "pyqt" => [:optional] + requires_py3
  depends_on "pyqt5" => [:optional] + requires_py2

  depends_on :tex => :optional
  depends_on DvipngRequirement if build.with? "tex"

  cxxstdlib_check :skip

  resource "dateutil" do
    url "https://pypi.python.org/packages/source/p/python-dateutil/python-dateutil-2.4.1.tar.bz2"
    sha256 "a9f62b12e28f11c732ad8e255721a9c7ab905f9479759491bc1f1e91de548d0f"
  end

  resource "mock" do
    url "https://pypi.python.org/packages/source/m/mock/mock-1.0.1.tar.gz"
    sha1 "ba2b1d5f84448497e14e25922c5e3293f0a91c7e"
  end

  resource "nose" do
    url "https://pypi.python.org/packages/source/n/nose/nose-1.3.4.tar.gz"
    sha1 "4d21578b480540e4e50ffae063094a14db2487d7"
  end

  resource "pyparsing" do
    url "https://pypi.python.org/packages/source/p/pyparsing/pyparsing-2.0.3.tar.gz"
    sha1 "39299b6bb894a27fb9cd5b548c21d168b893b434"
  end

  resource "pytz" do
    url "https://pypi.python.org/packages/source/p/pytz/pytz-2015.2.tar.bz2"
    sha256 "3e15b416c9a2039c1a51208b2cd3bb4ffd796cd19e601b1d2657afcb77c3dc90"
  end

  resource "six" do
    url "https://pypi.python.org/packages/source/s/six/six-1.9.0.tar.gz"
    sha256 "e24052411fc4fbd1f672635537c3fc2330d9481b18c0317695b46259512c91d5"
  end

  def install
    inreplace "setupext.py",
              "'darwin': ['/usr/local/'",
              "'darwin': ['#{HOMEBREW_PREFIX}'"

    # Apple has the Frameworks (esp. Tk.Framework) in a different place
    unless MacOS::CLT.installed?
      inreplace "setupext.py",
                "'/System/Library/Frameworks/',",
                "'#{MacOS.sdk_path}/System/Library/Frameworks',"
    end

    Language::Python.each_python(build) do |python, version|
      bundle_path = libexec/"lib/python#{version}/site-packages"
      bundle_path.mkpath
      ENV.append_path "PYTHONPATH", bundle_path
      resources.each do |r|
        r.stage do
          system python, *Language::Python.setup_install_args(libexec)
        end
      end
      dest_path = lib/"python#{version}/site-packages"
      dest_path.mkpath
      (dest_path/"homebrew-matplotlib-bundle.pth").write "#{bundle_path}\n"

      system python, *Language::Python.setup_install_args(prefix)
    end
  end

  def caveats
    s = <<-EOS.undent
      If you want to use the `wxagg` backend, do `brew install wxpython`.
      This can be done even after the matplotlib install.
    EOS
    if build.with?("python") && !Formula["python"].installed?
      homebrew_site_packages = Language::Python.homebrew_site_packages
      user_site_packages = Language::Python.user_site_packages "python"
      s += <<-EOS.undent
        If you use system python (that comes - depending on the OS X version -
        with older versions of numpy, scipy and matplotlib), you may need to
        ensure that the brewed packages come earlier in Python's sys.path with:
          mkdir -p #{user_site_packages}
          echo 'import sys; sys.path.insert(1, "#{homebrew_site_packages}")' >> #{user_site_packages}/homebrew.pth
      EOS
    end
    s
  end

  test do
    ohai "This test takes quite a while. Use --verbose to see progress."
    Language::Python.each_python(build) do |python, _version|
      system python, "-c", "import matplotlib as m; m.test()"
    end
  end
end
