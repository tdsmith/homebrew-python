class Pygame < Formula
  homepage 'http://pygame.org'
  url "https://bitbucket.org/pygame/pygame",
      :revision => "faa5879a7e6bfe10e4e5c79d04a3d2fb65d74a62",
      :using => :hg
  version "1.9.2a0"
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
  depends_on "freetype"

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
      s.gsub!(/^FREETYPE =.*$/, "FREETYPE = -I#{Formula["freetype"].opt_include}/freetype2 -lfreetype")
    end

    # Manually append what is the default for PyGame on the Mac
    system "cat Setup_Darwin.in >> Setup"

    ENV.prepend_create_path "PYTHONPATH", lib+"python2.7/site-packages"
    system "python", "setup.py", "install", "--prefix=#{prefix}"
  end
end
