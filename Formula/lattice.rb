# Generated for the Lattice-owned tap.
require "tmpdir"

class Lattice < Formula
  desc "Local-first engineering memory and workflow"
  homepage "https://lattice.qcqx.cn"
  version "1.30.2"
  license "MIT"
  on_macos do
    on_arm do
      url "https://github.com/qxchuckle/lattice/releases/download/v1.30.2/lattice-1.30.2-darwin-arm64.tar.gz", using: :nounzip
      sha256 "806738c694bbb759ed8539a3cffac8efa2b9c7ecf5b6c7b1b1e88a57da564d3d"
    end
    on_intel do
      url "https://github.com/qxchuckle/lattice/releases/download/v1.30.2/lattice-1.30.2-darwin-x64.tar.gz", using: :nounzip
      sha256 "3bf0b7390a72dcbc0d6df7f1fe8acbb55ea26827acd700406999ce468cd95e5f"
    end
  end
  on_linux do
    on_arm do
      url "https://github.com/qxchuckle/lattice/releases/download/v1.30.2/lattice-1.30.2-linux-arm64.tar.gz", using: :nounzip
      sha256 "1f35ec5d60d28f5c51c4c24d0eef29eeb14915e03f637308ee8f65d82a0009d9"
    end
    on_intel do
      url "https://github.com/qxchuckle/lattice/releases/download/v1.30.2/lattice-1.30.2-linux-x64.tar.gz", using: :nounzip
      sha256 "ac2828245c914bf06b5217a04d30c9e5ecf97dc016e82fd211e5858883ac15a0"
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
