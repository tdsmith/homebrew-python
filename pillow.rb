require 'formula'

class Pillow < Formula
  homepage 'https://github.com/python-imaging/Pillow'
  url 'https://github.com/python-imaging/Pillow/archive/2.4.0.tar.gz'
  sha1 '2e07dd7545177019331e8f3916335b69869e82b0'
  head 'https://github.com/python-imaging/Pillow.git'

  depends_on :python => :recommended
  depends_on :python3 => :optional
  depends_on 'freetype'
  depends_on 'jpeg'
  depends_on 'libtiff' => :recommended
  depends_on 'little-cms2' => :recommended
  depends_on 'openjpeg21' => :recommended
  depends_on 'webp' => :recommended

  def install
    # Help pillow find zlib and freetype2
    inreplace "setup.py" do |s|
      s.gsub! "ZLIB_ROOT = None", "ZLIB_ROOT = ('#{MacOS.sdk_path}/usr/lib', '#{MacOS.sdk_path}/usr/include')" unless MacOS::CLT.installed?
      s.gsub! "LCMS_ROOT = None", "LCMS_ROOT = ('#{Formula["littlecms"].opt_prefix}/lib', '#{Formula["littlecms"].opt_prefix}/include')" if build.with? 'little-cms2'
      s.gsub! "JPEG_ROOT = None", "JPEG_ROOT = ('#{Formula["jpeg"].opt_prefix}/lib', '#{Formula["jpeg"].opt_prefix}/include')"
      s.gsub! "JPEG2K_ROOT = None", "JPEG2K_ROOT = ('#{Formula["openjpeg21"].opt_prefix}/lib', '#{Formula["openjpeg21"].opt_prefix}/include')" if build.with? 'openjpeg21'
      s.gsub! "TIFF_ROOT = None", "TIFF_ROOT = ('#{Formula["libtiff"].opt_prefix}/lib', '#{Formula["libtiff"].opt_prefix}/include')" if build.with? 'libtiff'
      s.gsub! "FREETYPE_ROOT = None", "FREETYPE_ROOT = ('#{Formula["freetype"].opt_prefix}/lib', '#{Formula["freetype"].opt_prefix}/include')"
    end

    ENV.append "CFLAGS", "-I#{MacOS.sdk_path}/System/Library/Frameworks/Tk.framework/Versions/8.5/Headers" unless MacOS::CLT.installed?

    Language::Python.each_python(build) do |python, version|
      system python, "setup.py", "install", "--prefix=#{prefix}", "--record=installed.txt", "--single-version-externally-managed"
    end
  end

  test do
    Language::Python.each_python(build) do |python, version|
      # Only a small test until https://github.com/python-imaging/Pillow/issues/17
      system python, "-c", "import PIL.Image"
    end
  end
end
