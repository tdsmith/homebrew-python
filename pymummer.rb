class Pymummer < Formula
  desc "Python3 wrapper for running MUMmer and parsing the output"
  homepage "https://github.com/sanger-pathogens/pymummer"
  url "https://github.com/sanger-pathogens/pymummer/archive/v0.8.1.tar.gz"
  sha256 "b7b137ac1e96fdaa24a18a56dc35db26c276b70615b511303518d3771631e189"
  head "https://github.com/sanger-pathogens/pymummer.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "80b55dcfa3cb1874c5d1063597cb070610663b1487387b7d96cb591c744c1594" => :el_capitan
    sha256 "9712b826640cac771e3b743a01644f5e40e2ee2b9451622da54ec78623976227" => :yosemite
    sha256 "cf8ed2f76013013315343f233a22a891f26e7dc7481a5433f2e73de9faf3d9aa" => :mavericks
  end

  # tag "bioinformatics"

  depends_on :python3
  depends_on "homebrew/science/mummer"

  resource "pyfastaq" do
    url "https://files.pythonhosted.org/packages/2a/46/6ece19838a79489556c97092e832bafeb46e7b28c52418a6c5a7568da999/pyfastaq-3.13.0.tar.gz"
    sha256 "79bfe342e053d51efbc7a901489c62e996566b4baf0f33cde1caff3a387756af"
  end

  def install
    version = Language::Python.major_minor_version "python3"
    ENV.prepend_create_path "PYTHONPATH", libexec/"vendor/lib/python#{version}/site-packages"

    resource("pyfastaq").stage do
      system "python3", *Language::Python.setup_install_args(libexec/"vendor")
      pyfastaq_path = libexec/"vendor/lib/python#{version}/site-packages"
      dest_path = lib/"python#{version}/site-packages"
      mkdir_p dest_path
      (dest_path/"homebrew-pymummer-pyfastaq.pth").write "#{pyfastaq_path}\n"
    end

    ENV.prepend_create_path "PYTHONPATH", prefix/"lib/python#{version}/site-packages"
    system "python3", *Language::Python.setup_install_args(prefix)
  end

  test do
    system "python3", "-c", "from pymummer import coords_file, alignment, nucmer; nucmer.Runner('ref', 'qry', 'outfile')"
  end
end
