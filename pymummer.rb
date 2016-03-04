class Pymummer < Formula
  desc "Python3 wrapper for running MUMmer and parsing the output"
  homepage "https://github.com/sanger-pathogens/pymummer"
  url "https://github.com/sanger-pathogens/pymummer/archive/v0.7.0.tar.gz"
  sha256 "bd329946f67d3c7ebb783038077cbd831a63d65353e24f9454404150e5217876"
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
    url "https://pypi.python.org/packages/source/p/pyfastaq/pyfastaq-3.11.0.tar.gz"
    sha256 "343fa8eb4aa959c1d66050e2e864e4d3c49d80a41e3c51196a14df38220dba59"
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
