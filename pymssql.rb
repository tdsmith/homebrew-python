class Pymssql < Formula
  homepage "http://pymssql.org/"
  url "https://pypi.python.org/packages/source/p/pymssql/pymssql-2.1.1.tar.gz"
  sha1 "968a254acf5358b79ad362247984c69b2855b712"
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
