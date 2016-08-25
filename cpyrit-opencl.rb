class CpyritOpencl < Formula
  desc "GPU-accelerated attack against WPA-PSK auth"
  homepage "https://code.google.com/p/pyrit/"
  url "https://pyrit.googlecode.com/files/cpyrit-opencl-0.4.0.tar.gz"
  sha256 "aac593bce3f00ea7fd3d558083dbd7e168332a92736e51a621a0459d1bc042fa"

  bottle do
    cellar :any
    sha256 "a18be7044c7228e3b8dd43bfbd1bd80f6ee64fbbf5e1a85d1f777075409eb15a" => :yosemite
    sha256 "e77974aa1fc02c0dc3396935ec4706e22f355fd238af6c190779327851132886" => :mavericks
    sha256 "63505ec80d2ec87a287e50c6c48756732a4b2999b052c4d85057135bfbbec016" => :mountain_lion
  end

  depends_on "libdnet"
  depends_on "pyrit"
  depends_on "scapy"

  def install
    system "python", *Language::Python.setup_install_args(prefix)
  end

  test do
    interactive_shell
    system "python", "-c", "import cpyrit._cpyrit_opencl"
  end
end
