class Retext < Formula
  desc "Powerful editor for Markdown and reStructuredText"
  homepage "https://github.com/retext-project/retext"
  url "https://github.com/retext-project/retext/archive/5.2.1.tar.gz"
  sha256 "a1ec52bedf65332d817623f8552204a00adb8b7ce54d59359f07a18f821909a1"

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
    url "https://downloads.sourceforge.net/project/retext/Icons/ReTextIcons_r4.tar.gz"
    sha256 "c0a8c9791d320ef685a9087f230418f3308e6ccbefbf768b827490cde4084fd9"
  end

  resource "markups" do
    url "https://pypi.python.org/packages/source/M/Markups/Markups-0.6.3.tar.gz"
    sha256 "e3ff5de2be018240c526e017972b37181cb3d5dfb7c96ad14eae6639140f58ef"
  end

  resource "markdown" do
    url "https://pypi.python.org/packages/source/M/Markdown/Markdown-2.6.3.tar.gz"
    sha256 "ad75fc03c45492eba3bc63645e1e6465f65523a05fff0abf36910f810465a9af"
  end

  resource "docutils" do
    url "https://pypi.python.org/packages/source/d/docutils/docutils-0.12.tar.gz"
    sha256 "c7db717810ab6965f66c8cf0398a98c9d8df982da39b4cd7f162911eb89596fa"
  end

  resource "pyenchant" do
    url "https://pypi.python.org/packages/source/p/pyenchant/pyenchant-1.6.6.tar.gz"
    sha256 "25c9d2667d512f8fc4410465fdd2e868377ca07eb3d56e2b6e534a86281d64d3"
  end

  def install
    version = Language::Python.major_minor_version "python3"
    ENV["PYTHONPATH"] = lib/"python#{version}/site-packages"
    ENV.prepend_create_path "PYTHONPATH", libexec/"lib/python#{version}/site-packages"

    res = %w[markups markdown docutils pyenchant]
    res.each do |r|
      resource(r).stage do
        system "python3", "setup.py", "install", "--prefix=#{libexec}"
      end
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
