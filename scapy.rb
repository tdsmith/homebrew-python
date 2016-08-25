class Scapy < Formula
  desc "Powerful interactive packet manipulation program"
  homepage "http://www.secdev.org/projects/scapy/"
  url "https://github.com/secdev/scapy/archive/v2.3.2.tar.gz"
  sha256 "3de539ca67dd39e41287f0b36afd85188bd437604092726684c98debd816df01"
  head "https://github.com/secdev/scapy.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "2ca5dbe42f8cee37f90918ff1405fba4ac5de0383c9e97d3aaa645d693985212" => :el_capitan
    sha256 "289e7128c18924e591ed843c8bcb91cb2c6f15c45b0ec1858f84f15fc36ad27d" => :yosemite
    sha256 "c7d010874cb8aea533d927b1a7874d4f2bf015dad112e8fa6163a2941d2cf7d9" => :mavericks
  end

  depends_on :python
  depends_on "libdnet"

  resource "pylibpcap" do
    url "https://downloads.sourceforge.net/project/pylibpcap/pylibpcap/0.6.4/pylibpcap-0.6.4.tar.gz"
    sha256 "cfc365f2707a7986496acacf71789fef932a5ddbeaa36274cc8f9834831ca3b1"
  end

  def install
    vendor_path = libexec/"vendor/lib/python2.7/site-packages"
    ENV.prepend_create_path "PYTHONPATH", vendor_path
    resource("pylibpcap").stage do
      system "python", *Language::Python.setup_install_args(libexec/"vendor")
    end
    (lib/"python2.7/site-packages/homebrew-scapy-pylibpcap.pth").write "#{vendor_path}\n"
    system "python", *Language::Python.setup_install_args(prefix)
  end

  test do
    command = "rdpcap('#{test_fixtures("test.pcap")}')"
    assert_match "TCP", pipe_output(bin/"scapy", command)
  end
end
