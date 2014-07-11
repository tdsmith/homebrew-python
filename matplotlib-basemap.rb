require "formula"

class MatplotlibBasemap < Formula
  homepage "http://matplotlib.org/basemap"
  url "https://downloads.sourceforge.net/project/matplotlib/matplotlib-toolkits/basemap-1.0.7/basemap-1.0.7.tar.gz"
  sha1 "e1d5750aab4b2d2c3191bba078a6ae3e2bafa068"
  head "https://github.com/matplotlib/basemap.git"

  depends_on :python => :recommended
  depends_on :python3 => :optional
  depends_on "geos"

  if build.with? "python3"
    depends_on "numpy" => "with-python3"
    depends_on "matplotlib" => "with-python3"
    depends_on "pillow" => "with-python3"
  else
    depends_on "numpy"
    depends_on "matplotlib"
    depends_on "pillow"
  end

  resource "six" do
    url "https://pypi.python.org/packages/source/s/six/six-1.7.3.tar.gz"
    sha1 "43d173ff19bf2ac41189aa3701c7240fcd1182e3"
  end

  def package_installed? python, module_name
    quiet_system python, "-c", "import #{module_name}"
  end

  def install
    if build.with? "python3" and not package_installed? "python3", "six"
      resource("six").stage do
        system "python3", "setup.py", "install", "--prefix=#{prefix}",
                          "--single-version-externally-managed",
                          "--record=installed.txt"
      end
    end

    Language::Python.each_python(build) do |python, version|
      system python, "setup.py", "install", "--prefix=#{prefix}", "--record=installed.txt"
    end
  end

  test do
    Language::Python.each_python(build) do |python, version|
      system python, "-c", "import mpl_toolkits.basemap.test as test; test.test()"
    end
  end
end
