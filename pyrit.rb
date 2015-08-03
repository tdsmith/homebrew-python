class Pyrit < Formula
  desc "Pyrit allows to attack against WPA-PSK authentication"
  homepage "https://code.google.com/p/pyrit/"
  url "https://pyrit.googlecode.com/files/pyrit-0.4.0.tar.gz"
  sha256 "eb1a21cb844b1ded3eab613a8e9d5e4ef901530b04668fb18fe82ed1b4afa7cc"

  depends_on "libdnet"
  depends_on "scapy"

  def install
    system "python", *Language::Python.setup_install_args(prefix)
  end

  test do
    system python, "-c", "import pyrit_cli"
  end
end
