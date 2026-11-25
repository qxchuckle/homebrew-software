# Generated for the Lattice-owned tap.
require "tmpdir"

class Lattice < Formula
  desc "Local-first engineering memory and workflow"
  homepage "https://lattice.qcqx.cn"
  version "1.30.3"
  license "MIT"
  on_macos do
    on_arm do
      url "https://github.com/qxchuckle/lattice/releases/download/v1.30.3/lattice-1.30.3-darwin-arm64.tar.gz", using: :nounzip
      sha256 "cdce34f8ba0ece2158d8c2ddcf85f157ded0561d952155bdd47e3a3f7a9449a8"
    end
    on_intel do
      url "https://github.com/qxchuckle/lattice/releases/download/v1.30.3/lattice-1.30.3-darwin-x64.tar.gz", using: :nounzip
      sha256 "2a0faca25cd58f462296c7500d3f094f06a3a0712a56d15c4bf9512cc94af20f"
    end
  end
  on_linux do
    on_arm do
      url "https://github.com/qxchuckle/lattice/releases/download/v1.30.3/lattice-1.30.3-linux-arm64.tar.gz", using: :nounzip
      sha256 "e0f8f2aa8c3c1de00df8a18f8e262a67017980cfb4e09d88f461f5a1d67f0638"
    end
    on_intel do
      url "https://github.com/qxchuckle/lattice/releases/download/v1.30.3/lattice-1.30.3-linux-x64.tar.gz", using: :nounzip
      sha256 "f8606395ab91bdd963f26058e29a878e1e9c0731f72c3714b9170a266253c576"
    end
  end

  def install
    libexec.install Dir["*.tar.gz"].fetch(0) => "payload.tar.gz"
    bin.write_exec_script libexec/"payload/bin/ltc", libexec/"payload/bin/lattice"
  end

  # Homebrew fixes Mach-O linkage before post_install. Keep native files inside
  # the archive until that step has finished so their checksums stay intact.
  def post_install
    archive = libexec/"payload.tar.gz"
    destination = libexec/"payload"
    if destination.directory?
      verify_payload(destination)
    else
      Dir.mktmpdir(".lattice-payload-", libexec.to_s) do |stage|
        system "tar", "-xzf", archive, "-C", stage
        payload = Pathname(stage)/"payload"
        verify_payload(payload)
        payload.rename(destination)
      end
    end
    archive.unlink if archive.file?
  end

  def verify_payload(payload)
    with_env(NODE_OPTIONS: nil, NODE_PATH: nil) do
      system payload/"runtime/node", payload/"scripts/payload.cjs", version.to_s
    end
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/ltc --version").strip
    assert_match "--no-open", shell_output("#{bin}/ltc web --help")
    verify_payload(libexec/"payload")
  end
end
