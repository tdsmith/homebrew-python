class Numpy < Formula
  homepage "http://www.numpy.org"
  url "https://downloads.sourceforge.net/project/numpy/NumPy/1.9.1/numpy-1.9.1.tar.gz"
  sha256 "0075bbe07e30b659ae4415446f45812dc1b96121a493a4a1f8b1ba77b75b1e1c"
  head "https://github.com/numpy/numpy.git"

  depends_on :python => :recommended
  depends_on :python3 => :optional
  depends_on :fortran

  option "with-openblas", "Use openBLAS instead of Apple's Accelerate Framework"
  depends_on "homebrew/science/openblas" => :optional

  resource "nose" do
    url "https://pypi.python.org/packages/source/n/nose/nose-1.3.4.tar.gz"
    sha1 "4d21578b480540e4e50ffae063094a14db2487d7"
  end

  def package_installed?(python, module_name)
    quiet_system python, "-c", "import #{module_name}"
  end

  def install
    ENV["HOME"] = buildpath

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

    if (HOMEBREW_CELLAR/"gfortran").directory?
      opoo <<-EOS.undent
        It looks like the deprecated gfortran formula is installed.
        This causes build problems with numpy. gfortran is now provided by
        the gcc formula. Please run:
            brew rm gfortran
            brew install gcc
        if you encounter problems.
      EOS
    end

    Language::Python.each_python(build) do |python, version|
      resource("nose").stage do
        Language::Python.setup_install python, libexec/"nose"
        nose_path = libexec/"nose/lib/python#{version}/site-packages"
        dest_path = lib/"python#{version}/site-packages"
        mkdir_p dest_path
        (dest_path/"homebrew-numpy-nose.pth").atomic_write(nose_path.to_s + "\n")
      end unless package_installed? python, "nose"
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
