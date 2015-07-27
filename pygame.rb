require 'formula'

# Todo: Install examples, run test
# todo: What about sdl_gfx?
# todo: depends_on :x11 ???

class Pygame < Formula
  homepage 'http://pygame.org'
  url 'http://pygame.org/ftp/pygame-1.9.1release.tar.gz'
  sha1 'a45aeb0623e36ae7a1707b5f41ee6274f72ca4fa'
  head 'https://bitbucket.org/pygame/pygame', :using => :hg

  depends_on :python
  depends_on 'sdl'
  depends_on 'sdl_image'
  depends_on 'sdl_mixer'
  depends_on 'sdl_ttf'
  depends_on 'smpeg'
  depends_on 'jpeg'
  depends_on 'libpng'
  depends_on 'portmidi'
  depends_on 'homebrew/python/numpy'

  # Upstream https://bitbucket.org/pygame/pygame/issue/94/src-scale_mmx64c-cannot-be-compiled-with
  # Will be fixed in next release.
  stable do
    patch :p0 do
      url "https://bitbucket.org/pygame/pygame/issue-attachment/94/pygame/pygame/20111022/94/patch-src_scale_mmx64.c.diff"
      sha1 "f189dfc2d684344a4ab756d76df26c05175b1e7e"
    end
  end

  def install
    # We provide a "Setup" file based on the "Setup.in" because the detection
    # code in config.py does not know about the HOMEBREW_PREFIX, assumes SDL
    # is built as a framework and cannot find the Frameworks inside of Xcode.
    mv 'Setup.in', 'Setup'
    sdl = Formula["sdl"].opt_prefix
    sdl_ttf = Formula["sdl_ttf"].opt_prefix
    sdl_image = Formula["sdl_image"].opt_prefix
    sdl_mixer = Formula["sdl_mixer"].opt_prefix
    smpeg = Formula["smpeg"].opt_prefix
    png = Formula["libpng"].opt_prefix
    jpeg = Formula["jpeg"].opt_prefix
    portmidi = Formula["portmidi"].opt_prefix
    inreplace 'Setup' do |s|
      s.gsub!(/^SDL =.*$/, "SDL = -I#{sdl}/include/SDL -Ddarwin -lSDL")
      s.gsub!(/^FONT =.*$/, "FONT = -I#{sdl_ttf}/include/SDL -lSDL_ttf")
      s.gsub!(/^IMAGE =.*$/, "IMAGE = -I#{sdl_image}/include/SDL -lSDL_image")
      s.gsub!(/^MIXER =.*$/, "MIXER = -I#{sdl_mixer}/include/SDL -lSDL_mixer")
      s.gsub!(/^SMPEG =.*$/, "SMPEG = -I#{smpeg}/include/smpeg2 -lsmpeg")
      s.gsub!(/^PNG =.*$/, "PNG = -lpng")
      s.gsub!(/^JPEG =.*$/, "JPEG = -ljpeg")
      s.gsub!(/^PORTMIDI =.*$/, "PORTMIDI = -I#{portmidi}/include/ -lportmidi")
      s.gsub!(/^PORTTIME =.*$/, "PORTTIME = -I#{portmidi}/include/ -lportmidi")
    end

    # Manually append what is the default for PyGame on the Mac
    system "cat Setup_Darwin.in >> Setup"

    ENV.prepend_create_path "PYTHONPATH", lib+"python2.7/site-packages"
    system "python", "setup.py", "install", "--prefix=#{prefix}"
  end
end
