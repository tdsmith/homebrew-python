require "formula"

class Pillow < Formula
  homepage "https://github.com/python-imaging/Pillow"
  url "https://github.com/python-pillow/Pillow/archive/2.7.0.tar.gz"
  sha1 "923cfa2108e0784b3c1c915f0ca835186e4b47f2"
  head "https://github.com/python-imaging/Pillow.git"

  # waiting on upstream resolution of JPEG2000 issues
  # https://github.com/python-pillow/Pillow/issues/767
  # option "with-openjpeg", "Enable JPEG2000 support"

  depends_on :python => :recommended
  depends_on :python3 => :optional
  depends_on "freetype"
  depends_on "jpeg"
  depends_on "libtiff" => :recommended
  depends_on "little-cms2" => :recommended
  depends_on "webp" => :recommended
  # depends_on "homebrew/versions/openjpeg21" if build.with? "openjpeg"

  resource "nose" do
    url "https://pypi.python.org/packages/source/n/nose/nose-1.3.3.tar.gz"
    sha1 "cad94d4c58ce82d35355497a1c869922a603a9a5"
  end

  def package_installed? python, module_name
    quiet_system python, "-c", "import #{module_name}"
  end

  def install
    inreplace "setup.py" do |s|
      s.gsub! "ZLIB_ROOT = None", "ZLIB_ROOT = ('#{MacOS.sdk_path}/usr/lib', '#{MacOS.sdk_path}/usr/include')" unless MacOS::CLT.installed?
      s.gsub! "LCMS_ROOT = None", "LCMS_ROOT = ('#{Formula["little-cms2"].opt_prefix}/lib', '#{Formula["little-cms2"].opt_prefix}/include')" if build.with? "little-cms2"
      s.gsub! "JPEG_ROOT = None", "JPEG_ROOT = ('#{Formula["jpeg"].opt_prefix}/lib', '#{Formula["jpeg"].opt_prefix}/include')"
      # s.gsub! "JPEG2K_ROOT = None", "JPEG2K_ROOT = ('#{Formula["openjpeg21"].opt_prefix}/lib', '#{Formula["openjpeg21"].opt_prefix}/include')" if build.with? "openjpeg"
      s.gsub! "TIFF_ROOT = None", "TIFF_ROOT = ('#{Formula["libtiff"].opt_prefix}/lib', '#{Formula["libtiff"].opt_prefix}/include')" if build.with? "libtiff"
      s.gsub! "FREETYPE_ROOT = None", "FREETYPE_ROOT = ('#{Formula["freetype"].opt_prefix}/lib', '#{Formula["freetype"].opt_prefix}/include')"
    end

    ENV.append "CFLAGS", "-I#{MacOS.sdk_path}/System/Library/Frameworks/Tk.framework/Versions/8.5/Headers" unless MacOS::CLT.installed?

    Language::Python.each_python(build) do |python, version|
      unless package_installed?(python, "nose")
        resource("nose").stage do
          system python, *Language::Python.setup_install_args(libexec)
          nose_path = libexec/"lib/python#{version}/site-packages"
          dest_path = lib/"python#{version}/site-packages"
          mkdir_p dest_path
          (dest_path/"homebrew-pillow-nose.pth").atomic_write(nose_path.to_s + "\n")
          ENV.append_path "PYTHONPATH", nose_path
        end
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
