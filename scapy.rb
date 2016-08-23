class Scapy < Formula
  desc "Powerful interactive packet manipulation program"
  homepage "http://www.secdev.org/projects/scapy/"
  url "https://github.com/secdev/scapy/archive/v2.3.2.tar.gz"
  sha256 "3de539ca67dd39e41287f0b36afd85188bd437604092726684c98debd816df01"
  head "https://github.com/secdev/scapy.git"

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
