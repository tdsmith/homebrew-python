class Pillow < Formula
  homepage "https://github.com/python-imaging/Pillow"
  url "https://github.com/python-pillow/Pillow/archive/3.1.1.tar.gz"
  sha256 "a2ab64b39378031effdd86a6cd303de7b5b606445ab0338359e9ff9dc3f2e634"
  head "https://github.com/python-imaging/Pillow.git"

  bottle do
    sha256 "93cfe129fc31ec2f920375ed45a9641dfc547c2e5b6231d2eb7484590eb489a3" => :yosemite
    sha256 "2806bdd5505927bca5aef9a7af420b026a0305614f87dc6584712db816d391ca" => :mavericks
    sha256 "79e4b628c14701053e93bd5e0361930b3f97fce3667f69d9d7e406bd5731ca4f" => :mountain_lion
  end

  # waiting on upstream resolution of JPEG2000 issues
  # https://github.com/python-pillow/Pillow/issues/767
  # option "with-openjpeg", "Enable JPEG2000 support"

  option "without-python", "Build without python2 support"

  depends_on :python3 => :optional
  depends_on "freetype"
  depends_on "jpeg"
  depends_on "libtiff" => :recommended
  depends_on "little-cms2" => :recommended
  depends_on "webp" => :recommended
  # depends_on "homebrew/versions/openjpeg21" if build.with? "openjpeg"

  resource "nose" do
    url "https://pypi.python.org/packages/source/n/nose/nose-1.3.3.tar.gz"
    sha256 "b40c2ff268beb85356ada25f626ca0dabc89705f31051649772cf00fc9510326"
  end

  def install
    inreplace "setup.py" do |s|
      # Don't automatically detect Tcl or Tk in /Library
      # Fixes https://github.com/Homebrew/homebrew-python/issues/190
      s.gsub! '"/Library/Frameworks",', ""

      s.gsub! "ZLIB_ROOT = None", "ZLIB_ROOT = ('#{MacOS.sdk_path}/usr/lib', '#{MacOS.sdk_path}/usr/include')" unless MacOS::CLT.installed?
      s.gsub! "LCMS_ROOT = None", "LCMS_ROOT = ('#{Formula["little-cms2"].opt_prefix}/lib', '#{Formula["little-cms2"].opt_prefix}/include')" if build.with? "little-cms2"
      s.gsub! "JPEG_ROOT = None", "JPEG_ROOT = ('#{Formula["jpeg"].opt_prefix}/lib', '#{Formula["jpeg"].opt_prefix}/include')"
      # s.gsub! "JPEG2K_ROOT = None", "JPEG2K_ROOT = ('#{Formula["openjpeg21"].opt_prefix}/lib', '#{Formula["openjpeg21"].opt_prefix}/include')" if build.with? "openjpeg"
      s.gsub! "TIFF_ROOT = None", "TIFF_ROOT = ('#{Formula["libtiff"].opt_prefix}/lib', '#{Formula["libtiff"].opt_prefix}/include')" if build.with? "libtiff"
      s.gsub! "FREETYPE_ROOT = None", "FREETYPE_ROOT = ('#{Formula["freetype"].opt_prefix}/lib', '#{Formula["freetype"].opt_prefix}/include')"
    end

    ENV.append "CFLAGS", "-I#{MacOS.sdk_path}/System/Library/Frameworks/Tk.framework/Versions/8.5/Headers" unless MacOS::CLT.installed?

    Language::Python.each_python(build) do |python, version|
      resource("nose").stage do
        system python, *Language::Python.setup_install_args(libexec)
        nose_path = libexec/"lib/python#{version}/site-packages"
        dest_path = lib/"python#{version}/site-packages"
        mkdir_p dest_path
        (dest_path/"homebrew-pillow-nose.pth").atomic_write(nose_path.to_s + "\n")
        ENV.append_path "PYTHONPATH", nose_path
      end
      # don't accidentally discover openjpeg since it isn't working
      system python, "setup.py", "build_ext", "--disable-jpeg2000" # if build.without? "openjpeg"
      system python, *Language::Python.setup_install_args(prefix)
    end

    prefix.install "Tests"
  end

  test do
    cp_r prefix/"Tests", testpath
    Language::Python.each_python(build) do |python, version|
      system "#{python} -m nose Tests/test_*"
    end
  end
end
