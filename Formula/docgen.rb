# typed: false
# frozen_string_literal: true

# Homebrew formula for docgen CLI
# This file should be copied to your homebrew-tap repository
class Docgen < Formula
  desc "CLI tool for generating professional business documents with Typst"
  homepage "https://github.com/casoon/typst-business-templates"
  version "0.4.5"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/casoon/typst-business-templates/releases/download/v#{version}/docgen-aarch64-apple-darwin.tar.gz"
      sha256 "f719ad5906909b9b4dec3e88505bbea14209c9aefb7030c498020a497304d395"
    end
    on_intel do
      url "https://github.com/casoon/typst-business-templates/releases/download/v#{version}/docgen-x86_64-apple-darwin.tar.gz"
      sha256 "d23a3fa0f2b0922c41001af8786668c833f60e622c4a98b2baeee790416ec7ff"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/casoon/typst-business-templates/releases/download/v#{version}/docgen-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "5a05136214160061d239d041a26fb8f6afb490c26e7392212b1407f8a3ea871f"
    end
    on_intel do
      url "https://github.com/casoon/typst-business-templates/releases/download/v#{version}/docgen-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "e28e01279d70549ca9308a9c1181f1536c4fb8a74af98a601d8f5115f325d4bf"
    end
  end

  depends_on "typst"

  def install
    bin.install "docgen"
  end

  test do
    system "#{bin}/docgen", "--version"
  end
end
