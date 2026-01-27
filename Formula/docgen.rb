# typed: false
# frozen_string_literal: true

# Homebrew formula for docgen CLI
# This file should be copied to your homebrew-tap repository
class Docgen < Formula
  desc "CLI tool for generating professional business documents with Typst"
  homepage "https://github.com/casoon/typst-business-templates"
  version "0.6.8"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/casoon/typst-business-templates/releases/download/v#{version}/docgen-aarch64-apple-darwin.tar.gz"
      sha256 "12b814cee7c67646e3b95cf2cb77e0ce68da3c72d16379dc323dfb817e86d486"
    end
    on_intel do
      url "https://github.com/casoon/typst-business-templates/releases/download/v#{version}/docgen-x86_64-apple-darwin.tar.gz"
      sha256 "3f9ee67b3deb2960571a19800cb0f8e11d9b7715383f860ab2e8dd18ca67a642"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/casoon/typst-business-templates/releases/download/v#{version}/docgen-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "ab51037c8d574374cfd3a1a9c4dec628f14d7004de126bee61c0da84886fa6cb"
    end
    on_intel do
      url "https://github.com/casoon/typst-business-templates/releases/download/v#{version}/docgen-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "e976ef7000b52ff37837135d67d2a3573b1778dbcbb7129e704f50c90b49d667"
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
