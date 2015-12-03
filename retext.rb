class Retext < Formula
  homepage "http://sourceforge.net/projects/retext/"
  url "https://downloads.sourceforge.net/project/retext/ReText-4.1/ReText-4.1.3.tar.gz"
  sha256 "bb4409982d27ac62cab01b0748fe41d9c6660853668b350f3369e76d155edd6c"
  revision 1

  bottle do
    cellar :any_skip_relocation
    sha256 "945f8f977ee6b12925878450832ba330a49da35e2bd3fc3a7432024d2d5698f2" => :yosemite
    sha256 "ba58f5250b1c149ad48068565587c84b25d3facdcea656ea7c8a4b3a24e9c0c4" => :mavericks
    sha256 "faa88d9f1843b9cbb1d8361162c86eee20e72359c4c35feb7ff9a71e318878a1" => :mountain_lion
  end

  depends_on :python3
  depends_on "pyqt" => "with-python3"
  # workaround for Homebrew dependency issue, 7/7/14
  depends_on "sip" => "with-python3"
  depends_on "enchant"

  resource "icons" do
    url "https://downloads.sourceforge.net/project/retext/Icons/ReTextIcons_r3.tar.gz"
    sha256 "13d61b338296c299f40ecb3a81271f67e61b3b9769ab8c381fafa5b2e48950d7"
  end

  resource "markups" do
    url "https://pypi.python.org/packages/source/M/Markups/Markups-0.4.tar.gz"
    sha256 "3c33a19200a224b9c320e48557ec29e13dbe8094c6670da2851b75d6657950b8"
  end

  resource "markdown" do
    url "https://pypi.python.org/packages/source/M/Markdown/Markdown-2.4.1.tar.gz"
    sha256 "812ec5249f45edc31330b7fb06e52aaf6ab2d83aa27047df7cb6837ef2d269b6"
  end

  resource "docutils" do
    url "https://pypi.python.org/packages/source/d/docutils/docutils-0.11.tar.gz"
    sha256 "9af4166adf364447289c5c697bb83c52f1d6f57e77849abcccd6a4a18a5e7ec9"
  end

  resource "pyenchant" do
    url "https://pypi.python.org/packages/source/p/pyenchant/pyenchant-1.6.6.tar.gz"
    sha256 "25c9d2667d512f8fc4410465fdd2e868377ca07eb3d56e2b6e534a86281d64d3"
  end

  def install
    version = Language::Python.major_minor_version "python3"
    ENV["PYTHONPATH"] = lib/"python#{version}/site-packages"
    ENV.prepend_create_path "PYTHONPATH", libexec/"lib/python#{version}/site-packages"

    res = %w{markups markdown docutils pyenchant}
    res.each do |r|
      resource(r).stage { system "python3", "setup.py", "install", "--prefix=#{libexec}" }
    end

    system "python3", "setup.py", "install", "--prefix=#{prefix}"
    bin.env_script_all_files(prefix, :PYTHONPATH => ENV["PYTHONPATH"])
    bin.install_symlink "retext" => "retext.py"

    retext_dir = lib/"python#{version}/site-packages/ReText/"
    icons_dir = retext_dir/"icons"
    resource("icons").stage { icons_dir.install Dir["*"] }
    inreplace retext_dir/"__init__.py", 'icon_path = "icons/"',
                                        "icon_path = '#{icons_dir}/'"

    inreplace retext_dir/"window.py", "menubar = QMenuBar(self)", "menubar = QMenuBar()"
  end
end
