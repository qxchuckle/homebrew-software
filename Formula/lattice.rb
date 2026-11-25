# Generated for the Lattice-owned tap.
require "tmpdir"

class Lattice < Formula
  desc "Local-first engineering memory and workflow"
  homepage "https://lattice.qcqx.cn"
  version "1.30.1"
  license "MIT"
  on_macos do
    on_arm do
      url "https://github.com/qxchuckle/lattice/releases/download/v1.30.1/lattice-1.30.1-darwin-arm64.tar.gz", using: :nounzip
      sha256 "54858d7d4667cff3ddc27a10b271bc7c8a6ce402ca1f9d64b9bbd2d60f1a1567"
    end
    on_intel do
      url "https://github.com/qxchuckle/lattice/releases/download/v1.30.1/lattice-1.30.1-darwin-x64.tar.gz", using: :nounzip
      sha256 "ba897504fa14433bf979cce17d1b044ec510e9329c2d604fa300f528e9b18cd6"
    end
  end
  on_linux do
    on_arm do
      url "https://github.com/qxchuckle/lattice/releases/download/v1.30.1/lattice-1.30.1-linux-arm64.tar.gz", using: :nounzip
      sha256 "6dd06a2664399e66ededaba68097ae0d378bedd961d26847d87785a176acc383"
    end
    on_intel do
      url "https://github.com/qxchuckle/lattice/releases/download/v1.30.1/lattice-1.30.1-linux-x64.tar.gz", using: :nounzip
      sha256 "5eb9a9a164cda13ac7dbf62140862a988601272a1bc1a3d22d5398303b68454d"
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
