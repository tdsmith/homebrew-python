require 'formula'

class JdkInstalled < Requirement
  fatal true
  satisfy{ which 'javac'}
  def message; <<-EOS.undent
    A JDK is required.  You can get the official Oracle installers from:
    http://www.oracle.com/technetwork/java/javase/downloads/index.html
    EOS
  end
end

class JavaHome < Requirement
  fatal true
  satisfy { ENV["JAVA_HOME"] }
  def message; <<-EOS.undent
    JAVA_HOME is not set:  please set it to the correct value for your Java
    installation. For instance:
    /Library/Java/JavaVirtualMachines/jdk1.7.0_40.jdk/Contents/Home
    EOS
  end
end

class Pydoop < Formula
  homepage 'http://pydoop.sourceforge.net/'
  url "https://github.com/crs4/pydoop/archive/0.12.0.tar.gz"
  sha1 "78aad0d6dab093d9876dd835c5792ba4329e40b6"

  depends_on :python
  depends_on JdkInstalled
  depends_on JavaHome
  depends_on "boost-python"
  depends_on "hadoop" unless(ENV["HADOOP_HOME"])
  depends_on "openssl"
  
  def install
    unless(ENV["HADOOP_HOME"])
      ohai "HADOOP_HOME is not set. Using brewed version"
      ENV.append 'HADOOP_HOME', Formula["hadoop"].libexec
    end
    unless(ENV["BOOST_PYTHON"])
      ENV['BOOST_PYTHON'] = 'boost_python-mt'
    end
    inreplace "setup.py", 'self.compiler.linker_so.append("-Wl,--no-as-needed")', ""

    system "python", 'setup.py', 'install', "--prefix=#{prefix}"
    prefix.install %w[test examples]
  end

  test do
    system "python", "-c", "import pydoop"
  end
end
