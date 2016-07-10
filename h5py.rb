class H5py < Formula
  desc "Pythonic interface to the HDF5 binary data format"
  homepage "http://www.h5py.org"
  url "https://pypi.python.org/packages/source/h/h5py/h5py-2.6.0.tar.gz"
  sha256 "b2afc35430d5e4c3435c996e4f4ea2aba1ea5610e2d2f46c9cae9f785e33c435"

  option "without-python", "Build without python2 support"
  depends_on :python => :recommended if MacOS.version <= :snow_leopard
  depends_on :python3 => :optional
  depends_on :mpi => :optional
  depends_on "homebrew/science/hdf5" => (build.with?("mpi") ? "with-mpi" : [])

  if build.with? :mpi
    depends_on "mpi4py" => ["with-python3"] if build.with? :python3
  end

  if build.with? :python3
    depends_on "homebrew/python/numpy" => ["with-python3"]
  end

  resource "cython" do
    url "https://pypi.python.org/packages/c6/fe/97319581905de40f1be7015a0ea1bd336a756f6249914b148a17eefa75dc/Cython-0.24.1.tar.gz"
    sha256 "84808fda00508757928e1feadcf41c9f78e9a9b7167b6649ab0933b76f75e7b9"
  end

  def install
    Language::Python.each_python(build) do |python, version|
      ENV.prepend_create_path "PATH", buildpath/"vendor/bin"
      ENV.prepend_create_path "PYTHONPATH", buildpath/"vendor/lib/python#{version}/site-packages"
      resource("cython").stage do
        system python, *Language::Python.setup_install_args(buildpath/"vendor")
      end

      args = Language::Python.setup_install_args(prefix)
      args << "configure"
      args << "--hdf5=#{Formula["homebrew/science/hdf5"].opt_prefix}"
      args << "--mpi" if build.with? :mpi

      ENV.prepend_create_path "PYTHONPATH", lib/"python#{version}/site-packages"
      system python, *args
    end
  end

  test do
    Language::Python.each_python(build) do |python, _|
      system python, "-c", "import h5py; print(h5py.__version__)"
    end
  end
end
