class Pyrit < Formula
  desc "Pyrit allows to attack against WPA-PSK authentication"
  homepage "https://code.google.com/p/pyrit/"
  url "https://pyrit.googlecode.com/files/pyrit-0.4.0.tar.gz"
  sha256 "eb1a21cb844b1ded3eab613a8e9d5e4ef901530b04668fb18fe82ed1b4afa7cc"

  bottle do
    sha256 "988ba5e46df34c95ebf72294a146338ade7e3972d82ca76f1182f720717bf417" => :yosemite
    sha256 "f56281afb83a401d5af004a5e19dedf5ada98ebfcb08898015f4a941284555e5" => :mavericks
    sha256 "ca269489116ea7b57727d243200b696b0f72780c0836b27fa79b6de0f7e14cd3" => :mountain_lion
  end

  depends_on "libdnet"
  depends_on "scapy"

  def install
    system "python", *Language::Python.setup_install_args(prefix)
  end

  test do
    system "python", "-c", "import pyrit_cli"
  end
end
