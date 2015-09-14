class Pymummer < Formula
  desc "Python3 wrapper for running MUMmer and parsing the output"
  homepage "https://github.com/sanger-pathogens/pymummer"
  url "https://github.com/sanger-pathogens/pymummer/archive/v0.4.0.tar.gz"
  sha256 "900b25019e5351882ea62c5992f019903cb838a2c80375de3842159e04cf1588"
  head "https://github.com/sanger-pathogens/pymummer.git"
  revision 1
  bottle do
    cellar :any_skip_relocation
    sha256 "3842098e80cd864c0b26a2b3a8710e67dbf7d0e6f4141ffdda23d0ddb18b0ea1" => :yosemite
    sha256 "77c945ed70338255bc6f1a5164451294f28d3c04e834a2e15f6216be8e1d0ef7" => :mavericks
    sha256 "97075fcd2f97846e09dd16b7020d6e9a4e99c4ace944bf781faac99402b05fe4" => :mountain_lion
  end

  # tag "bioinformatics"

  depends_on :python3
  depends_on "homebrew/science/mummer"
  depends_on "homebrew/python/numpy" => "with-python3"

  resource "pyfastaq" do
    url "https://pypi.python.org/packages/source/p/pyfastaq/pyfastaq-3.5.0.tar.gz"
    sha256 "599b28db5a05072335eacd3cea458aff511239e34a9559aaf2e7fe94cce785a9"
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
