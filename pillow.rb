class Pillow < Formula
  homepage "https://github.com/python-imaging/Pillow"
  url "https://github.com/python-pillow/Pillow/archive/3.3.1.tar.gz"
  sha256 "c76258246a157e99e745805098c25ae289bcdca4b56e5cf035daea091970e597"
  head "https://github.com/python-imaging/Pillow.git"

  bottle do
    cellar :any
    sha256 "dcc24bf458262f8e29457163985d4f5ddc2d2e6b5f7cb0777d5c9ff16c51f262" => :el_capitan
    sha256 "5c6fd6432f7f839ecfb90b94e18f26d25ac7cbc070edf567c4270bffdb1d9ff0" => :yosemite
    sha256 "d737d10606844d14166e1e9e8c2c1a01890736d8a249a20aa1167efaf96a3a2c" => :mavericks
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
  depends_on "openjpeg" => :optional

  resource "nose" do
    url "https://pypi.python.org/packages/source/n/nose/nose-1.3.3.tar.gz"
    sha256 "b40c2ff268beb85356ada25f626ca0dabc89705f31051649772cf00fc9510326"
  end

  def install
    inreplace "setup.py" do |s|
      sdkprefix = MacOS::CLT.installed? ? "" : MacOS.sdk_path
      s.gsub! "ZLIB_ROOT = None", "ZLIB_ROOT = ('#{sdkprefix}/usr/lib', '#{sdkprefix}/usr/include')"
      s.gsub! "LCMS_ROOT = None", "LCMS_ROOT = ('#{Formula["little-cms2"].opt_prefix}/lib', '#{Formula["little-cms2"].opt_prefix}/include')" if build.with? "little-cms2"
      s.gsub! "JPEG_ROOT = None", "JPEG_ROOT = ('#{Formula["jpeg"].opt_prefix}/lib', '#{Formula["jpeg"].opt_prefix}/include')"
      s.gsub! "JPEG2K_ROOT = None", "JPEG2K_ROOT = ('#{Formula["openjpeg"].opt_prefix}/lib', '#{Formula["openjpeg"].opt_prefix}/include')" if build.with? "openjpeg"
      s.gsub! "TIFF_ROOT = None", "TIFF_ROOT = ('#{Formula["libtiff"].opt_prefix}/lib', '#{Formula["libtiff"].opt_prefix}/include')" if build.with? "libtiff"
      s.gsub! "FREETYPE_ROOT = None", "FREETYPE_ROOT = ('#{Formula["freetype"].opt_prefix}/lib', '#{Formula["freetype"].opt_prefix}/include')"
    end

    # avoid triggering "helpful" distutils code that doesn't recognize Xcode 7 .tbd stubs
    ENV.delete "SDKROOT"
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
      system python, "setup.py", "build_ext"
      system python, *Language::Python.setup_install_args(prefix)
    end

    prefix.install "Tests"
  end

  test do
    cp_r prefix/"Tests", testpath
    Language::Python.each_python(build) do |python, _version|
      system "#{python} -m nose Tests/test_*"
    end
  end
end
