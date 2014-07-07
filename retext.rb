require "formula"

class Retext < Formula
  homepage "http://sourceforge.net/projects/retext/"
  url "https://downloads.sourceforge.net/project/retext/ReText-4.1/ReText-4.1.3.tar.gz"
  sha1 "2b18319e17c2f62816926de46a2d18fa820e2e21"

  depends_on :python3
  depends_on "pyqt" => "with-python3"
  # workaround for Homebrew dependency issue, 7/7/14
  depends_on "sip" => "with-python3"
  depends_on "enchant"

  resource "icons" do
    url "https://downloads.sourceforge.net/project/retext/Icons/ReTextIcons_r3.tar.gz"
    sha1 "c51d4a687c21b7de3fd24a14a7ae16e9b0869e31"
  end

  resource "markups" do
    url "https://pypi.python.org/packages/source/M/Markups/Markups-0.4.tar.gz"
    sha1 "47c9fa5c0ad7076b6b52346d59195f5651cb670a"
  end

  resource "markdown" do
    url "https://pypi.python.org/packages/source/M/Markdown/Markdown-2.4.1.tar.gz"
    sha1 "2c9cedad000e9ecdf0b220bd1ad46bc4592d067e"
  end

  resource "docutils" do
    url "https://pypi.python.org/packages/source/d/docutils/docutils-0.11.tar.gz"
    sha1 "3894ebcbcbf8aa54ce7c3d2c8f05460544912d67"
  end

  resource "pyenchant" do
    url "https://pypi.python.org/packages/source/p/pyenchant/pyenchant-1.6.6.tar.gz"
    sha1 "353b0b06cb29deef46298337afdd96ec71f01625"
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
