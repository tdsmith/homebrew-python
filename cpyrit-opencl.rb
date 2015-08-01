class CpyritOpencl < Formula
  desc "GPU-accelerated attack against WPA-PSK auth"
  homepage "https://code.google.com/p/pyrit/"
  url "https://pyrit.googlecode.com/files/cpyrit-opencl-0.4.0.tar.gz"
  sha256 "aac593bce3f00ea7fd3d558083dbd7e168332a92736e51a621a0459d1bc042fa"

  depends_on "libdnet"
  depends_on "pyrit"
  depends_on "scapy"

  def install
    system "python", *Language::Python.setup_install_args(prefix)
  end

  test do
    system python, "-c", "import _cpyrit_opencl"
  end
end
