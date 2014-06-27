require 'formula'

class TexRequirement < Requirement
  fatal false
  env :userpaths

  def satisfied?
    quiet_system('latex', '-version')  && quiet_system("dvipng", "-version")
  end

  def message; <<-EOS.undent
    LaTeX not found. This is optional for Matplotlib.
    If you want, https://www.tug.org/mactex/ provides an installer.
    EOS
  end
end

class NoExternalPyCXXPackage < Requirement
  fatal false

  satisfy do
    not quiet_system "python", "-c", "import CXX"
  end

  def message; <<-EOS.undent
    *** Warning, PyCXX detected! ***
    On your system, there is already a PyCXX version installed, that will
    probably make the build of Matplotlib fail. In python you can test if that
    package is availbale with `import CXX`. To get a hint where that package
    is installed, you can:
        python -c "import os; import CXX; print(os.path.dirname(CXX.__file__))"
    See also: https://github.com/Homebrew/homebrew-python/issues/56
    EOS
  end
end

class Matplotlib < Formula
  homepage 'http://matplotlib.org'
  url 'https://downloads.sourceforge.net/project/matplotlib/matplotlib/matplotlib-1.3.1/matplotlib-1.3.1.tar.gz'
  sha1 '8578afc86424392591c0ee03f7613ffa9b6f68ee'
  head 'https://github.com/matplotlib/matplotlib.git'

  depends_on 'pkg-config' => :build
  depends_on :python => :recommended
  depends_on :python3 => :optional
  depends_on :freetype
  depends_on :libpng
  depends_on TexRequirement => :optional
  depends_on NoExternalPyCXXPackage
  depends_on 'cairo' => :optional
  depends_on 'ghostscript' => :optional
  # On Xcode-only Macs, the Tk headers are not found by matplotlib
  depends_on 'homebrew/dupes/tcl-tk' => :optional
  cxxstdlib_check :skip

  if build.with? "python3"
    depends_on 'numpy' => 'with-python3'
    depends_on 'pyside' => [:optional, 'with-python3']
    depends_on 'pyqt' => [:optional, 'with-python3']
  else
    depends_on 'numpy'
    depends_on 'pyside' => :optional
    depends_on 'pyqt' => :optional
    depends_on 'pygtk' => :optional
    depends_on 'pygobject' if build.with? 'pygtk'
  end

  resource 'pyparsing' do
    url 'https://pypi.python.org/packages/source/p/pyparsing/pyparsing-2.0.1.tar.gz'
    sha1 'b645857008881d70599e89c66e4bbc596fe22043'
  end

  resource 'python-dateutil' do
    url 'https://pypi.python.org/packages/source/p/python-dateutil/python-dateutil-2.2.tar.gz'
    sha1 'fbafcd19ea0082b3ecb17695b4cb46070181699f'
  end

  def package_installed? python, module_name
    quiet_system python, "-c", "import #{module_name}"
  end

  def patches
    p = []
    # Fix for freetpe 2.5.1 (https://github.com/samueljohn/homebrew-python/issues/62)
    p << 'https://github.com/matplotlib/matplotlib/pull/2623.diff' unless build.head?
    return p
  end

  def install
    # Tell matplotlib, where brew is installed
    inreplace "setupext.py",
              "'darwin': ['/usr/local/', '/usr', '/usr/X11', '/opt/local'],",
              "'darwin': ['#{HOMEBREW_PREFIX}', '/usr', '/usr/X11', '/opt/local'],"

    # Apple has the Frameworks (esp. Tk.Framework) in a different place
    unless MacOS::CLT.installed?
      inreplace "setupext.py",
                "'/System/Library/Frameworks/',",
                "'#{MacOS.sdk_path}/System/Library/Frameworks',"
    end

    Language::Python.each_python(build) do |python, version|

      resource("pyparsing").stage do
        system python, "setup.py", "install", "--prefix=#{prefix}"
      end unless package_installed? python, "pyparsing"

      resource("python-dateutil").stage do
        system python, "setup.py", "install",  "--prefix=#{prefix}",
                       "--single-version-externally-managed",
                       "--record=installed.txt"
      end unless package_installed? python, "dateutil"

      system python, "setup.py", "install", "--prefix=#{prefix}", "--record=installed.txt", "--single-version-externally-managed"
    end
  end

  def caveats
    s = <<-EOS.undent
      If you want to use the `wxagg` backend, do `brew install wxwidgets`.
      This can be done even after the matplotlib install.
    EOS
    if build.with? "python" and not Formula['python'].installed?
      s += <<-EOS.undent
        If you use system python (that comes - depending on the OS X version -
        with older versions of numpy, scipy and matplotlib), you actually may
        have to set the `PYTHONPATH` in order to make the brewed packages come
        before these shipped packages in Python's `sys.path`.
            export PYTHONPATH=#{HOMEBREW_PREFIX}/lib/python2.7/site-packages
      EOS
    end
    s
  end

  test do
    ohai "This test takes quite a while. Use --verbose to see progress."
    Language::Python.each_python(build) do |python, version|
      system python, "-c", "import matplotlib as m; m.test()"
    end
  end
end
