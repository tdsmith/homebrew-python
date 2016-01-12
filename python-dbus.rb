class PythonDbus < Formula
  desc "Python bindings for libdbus"
  homepage "http://dbus.freedesktop.org/doc/dbus-python/"
  url "http://dbus.freedesktop.org/releases/dbus-python/dbus-python-1.2.0.tar.gz"
  sha256 "e12c6c8b2bf3a9302f75166952cbe41d6b38c3441bbc6767dbd498942316c6df"

  depends_on "pkg-config" => :build
  depends_on "d-bus"
  depends_on "dbus-glib"
  depends_on :python => :recommended
  depends_on :python3 => :optional

  if build.without?("python") && build.without?("python3")
    odie "You must build with python and/or python3 support."
  end

  def install
    # make check fails
    # https://bugs.freedesktop.org/show_bug.cgi?id=57140
    inreplace "test/test-standalone.py", "def test_utf8(self):", "def skip_utf8(self):"

    Language::Python.each_python(build) do |python, _|
      ENV["PYTHON"] = python
      system "./configure", "--disable-dependency-tracking",
                            "--prefix=#{prefix}"

      system "make", "clean"
      system "make"
      system "make", "check"
      system "make", "install"
    end
  end

  test do
    Language::Python.each_python(build) do |python, _|
      system python, "-c", "import dbus"
    end
  end
end
