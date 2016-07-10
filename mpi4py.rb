class Mpi4py < Formula
  desc "MPI bindings for Python"
  homepage "http://pythonhosted.org/mpi4py"
  url "https://bitbucket.org/mpi4py/mpi4py/downloads/mpi4py-2.0.0.tar.gz"
  sha256 "6543a05851a7aa1e6d165e673d422ba24e45c41e4221f0993fe1e5924a00cb81"

  bottle do
    cellar :any
    sha256 "c831eb7752f7117ac8a72f5fccfe93413085bab7628a610fb756e5b46f51a027" => :el_capitan
    sha256 "ba0a5c9cd39e380525252d0ecc271a75b787588b531e10a3e762d966de082ec3" => :yosemite
    sha256 "c4cd1d1e2bd722d6cf154cf083ebf463e6588b0046f8d4ae6b1713c436450281" => :mavericks
  end

  head do
    url "https://bitbucket.org/mpi4py/mpi4py.git"

    resource "Cython" do
      url "http://cython.org/release/Cython-0.22.tar.gz"
      sha256 "14307e7a69af9a0d0e0024d446af7e51cc0e3e4d0dfb10d36ba837e5e5844015"
    end
  end

  option "without-python", "Build without python2 support"

  depends_on :mpi => [:cc, :cxx]
  depends_on :python => :recommended if MacOS.version <= :snow_leopard
  depends_on :python3 => :optional

  resource "setuptools" do
    url "https://pypi.python.org/packages/source/s/setuptools/setuptools-18.6.1.tar.gz"
    sha256 "ddb0f4bdd1ac0ceb41abfe561d6196a840abb76371551dbf0c3e59d8d5cde99a"
  end

  def install
    Language::Python.each_python(build) do |python, version|
      ENV.prepend_create_path "PYTHONPATH", buildpath/"vendor/lib/python#{version}/site-packages"

      resource("setuptools").stage do
        system python, *Language::Python.setup_install_args(buildpath/"vendor")
      end

      if build.head?
        resource("Cython").stage do
          system python, *Language::Python.setup_install_args(buildpath/"vendor")
        end
      end

      ENV.prepend_create_path "PYTHONPATH", lib/"python#{version}/site-packages"
      system python, *Language::Python.setup_install_args(prefix)
    end
  end

  test do
    Language::Python.each_python(build) do |python, _|
      system "mpiexec", "-np", Hardware::CPU.cores, python, "-m", "mpi4py", "helloworld"
    end
  end
end
