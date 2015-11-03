class Pymssql < Formula
  desc "Python DB-API interface to Microsoft SQL Server."
  homepage "http://pymssql.org/"
  url "https://pypi.python.org/packages/source/p/pymssql/pymssql-2.1.1.tar.gz"
  sha256 "f1a1601dc3322c785733c84639d8d640c7204f9db4eab5f2a5cc908fb157140f"
  head "https://github.com/pymssql/pymssql.git"

  depends_on :python => :recommended
  depends_on :python3 => :optional

  depends_on "freetds"

  def install
    Language::Python.each_python(build) do |python, _version|
      system python, *Language::Python.setup_install_args(prefix)
    end
  end

  test do
    Language::Python.each_python(build) do |python, _version|
      system python, "-c", "import pymssql; print(pymssql); print(pymssql.__version__)"
    end
  end
end
