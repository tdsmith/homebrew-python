class CudaRequirement < Requirement
  build true
  fatal true

  satisfy { which "nvcc" }

  env do
    # nVidia CUDA installs (externally) into this dir (hard-coded):
    ENV.append "CFLAGS", "-F/Library/Frameworks"
    # because nvcc has to be used
    ENV.append_path "PATH", which("nvcc").dirname

    ENV.append "LDFLAGS", "-L/usr/local/cuda/lib"
  end

  def message
    <<-EOS.undent
      To use this formula with NVIDIA graphics cards you will need to
      download and install the CUDA drivers and tools from nvidia.com.

          https://developer.nvidia.com/cuda-downloads

      Select "Mac OS" as the Operating System and then select the
      'Developer Drivers for MacOS' package.
      You will also need to download and install the 'CUDA Toolkit' package.

      The `nvcc` has to be in your PATH then (which is normally the case).
      If it's not there you can add by adding export PATH=$PATH:/usr/local/cuda/bin
    EOS
  end
end

class CpyritCuda < Formula
  homepage "https://code.google.com/p/pyrit/"
  url "https://pyrit.googlecode.com/files/cpyrit-cuda-0.4.0.tar.gz"
  sha256 "6035f01874f699f010e460618694ec876f719bea475313b991f5dd3dd84d831b"

  depends_on :python
  depends_on "pyrit"
  depends_on CudaRequirement

  def install
    system "python", "setup.py", "build"
    system "python", "setup.py", "install", "--prefix=#{prefix}"
  end
end
