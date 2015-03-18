class Scapy < Formula
  homepage 'http://www.secdev.org/projects/scapy/'
  url "https://bitbucket.org/secdev/scapy/downloads/scapy-2.3.1.zip"
  sha256 "8972c02e39a826a10c02c2bdd5025f7251dce9589c57befd9bb55c65f02e4934"
  head "https://bitbucket.org/secdev/scapy", :using => :hg

  depends_on :python if MacOS.version <= :snow_leopard
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
    user_site = Language::Python.user_site_packages "python"
    homebrew_site = Language::Python.homebrew_site_packages
    user_site.mkpath
    (user_site/"homebrew-test.pth").write "import site; site.addsitedir('#{homebrew_site}')\n"

    command = "rdpcap('#{test_fixtures("test.pcap")}')"
    assert_match /TCP/, pipe_output(bin/"scapy", command)
  end
end
