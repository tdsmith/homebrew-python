class MatplotlibBasemap < Formula
  desc "Python library for plotting 2D data on maps"
  homepage "http://matplotlib.org/basemap"
  url "https://downloads.sourceforge.net/project/matplotlib/matplotlib-toolkits/basemap-1.0.7/basemap-1.0.7.tar.gz"
  sha256 "e07ec2e0d63b24c9aed25a09fe8aff2598f82a85da8db74190bac81cbf104531"
  head "https://github.com/matplotlib/basemap.git"

  depends_on :python => :recommended
  depends_on :python3 => :optional
  depends_on "geos"

  if build.with? "python3"
    depends_on "homebrew/python/numpy" => "with-python3"
    depends_on "homebrew/python/matplotlib" => "with-python3"
    depends_on "homebrew/python/pillow" => "with-python3"
  else
    depends_on "homebrew/python/numpy"
    depends_on "homebrew/python/matplotlib"
    depends_on "homebrew/python/pillow"
  end

  resource "six" do
    url "https://pypi.python.org/packages/source/s/six/six-1.7.3.tar.gz"
    sha256 "7a842c9f882c0b2ab1064d567bb9fff6a21c9efbc3d9992083ad6193787ed393"
  end

  def package_installed?(python, module_name)
    quiet_system python, "-c", "import #{module_name}"
  end

  def install
    if build.with?("python3") && !package_installed?("python3", "six")
      resource("six").stage do
        system "python3", "setup.py", "install", "--prefix=#{prefix}",
                          "--single-version-externally-managed",
                          "--record=installed.txt"
      end
    end

    inreplace "setup.py" do |s|
      s.gsub! "GEOS_dir = None", "GEOS_dir = '#{Formula["geos"].opt_prefix}'"
    end

    Language::Python.each_python(build) do |python, _|
      system python, "setup.py", "install", "--prefix=#{prefix}", "--record=installed.txt"
    end
  end

  test do
    Language::Python.each_python(build) do |python, _|
      system python, "-c", "import mpl_toolkits.basemap.test as test; test.test()"
    end
  end
end
