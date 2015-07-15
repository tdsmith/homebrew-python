class Vpython < Formula
  url "https://github.com/BruceSherwood/vpython-wx/archive/v6.11.tar.gz"
  sha256 "5fcc87d401d6d39c9044979f2f9a5286a277504b26465eb6c89bfa7ec4a9783d"
  head "https://github.com/BruceSherwood/vpython-wx.git"
  bottle do
    root_url "https://homebrew.bintray.com/bottles-python"
    sha256 "54163d86963ed9c8706e564012947c46719c8bb7c0ed8c21e1b71a0a0f9a424e" => :yosemite
    sha256 "b40e535dc217729b55f3cf82bfa48fb830abd50341acff828f14fea0e9cc1ece" => :mavericks
    sha256 "b354b9d7813c54046c4bb6edd72c866c3ea24b816e6bd02c937612ca36db24da" => :mountain_lion
  end

  homepage "http://vpython.org/"

  depends_on "homebrew/python/numpy"
  depends_on "wxpython"

  boost_args = []
  boost_args << "c++11" if MacOS.version < :mavericks
  depends_on "boost" => boost_args
  depends_on "boost-python" => boost_args

  resource "FontTools" do
    url "https://pypi.python.org/packages/source/F/FontTools/FontTools-2.4.tar.gz"
    sha256 "0a937fc607cbd31e30f45146e37adf4bdcd935565376bd8c626c9221d99fef8d"
  end

  resource "Polygon2" do
    url "https://pypi.python.org/packages/source/P/Polygon2/Polygon2-2.0.7.zip"
    sha256 "a779378f2258a8586f1a5967896c419c4c6859d8a067677259dacd3146453f24"
  end

  resource "TTFQuery" do
    url "https://pypi.python.org/packages/source/T/TTFQuery/TTFQuery-1.0.5.tar.gz"
    sha256 "d5b8d369903ee2754541819f27de8ea35486d124484e36a4869503d9a9ac7e4d"
  end

  needs :cxx11

  # spurious errors because dependent numpy depends_on gcc through :fortran
  # https://github.com/Homebrew/homebrew/issues/30474
  cxxstdlib_check :skip

  def install
    ENV.cxx11

    vendor_packages = libexec/"vendor/lib/python2.7/site-packages"
    ENV.prepend_create_path "PYTHONPATH", vendor_packages
    resources.each do |r|
      r.stage do
        system "python", *Language::Python.setup_install_args(libexec/"vendor")
      end
    end
    pth_contents = "#{vendor_packages}\n#{vendor_packages}/FontTools\n"
    (lib/"python2.7/site-packages/homebrew-vpython-bundle.pth").write pth_contents

    system "python", *Language::Python.setup_install_args(prefix)
  end

  test do
    shell_output "python -c 'import visual'", 255
  end
end
