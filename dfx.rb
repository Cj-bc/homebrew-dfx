class Dfx < Formula
  homepage "https://dfinity.org/developers"
  version "0.8.1"
  url "https://sdk.dfinity.org/install.sh", :using => :nounzip
  desc "Unofficial formula for Dfinity's SDK"
  sha256 "880cc21dc48df2c5c3139e86870c09bb170e5cef8018e8805dc20b5b85c87273"

  option "with-curl", "You'll need either curl or wget to download SDK"
  depends_on "curl" => :recommended

  option "with-wget", "You'll need either curl or wget to download SDK"
  depends_on "wget" => :optional

  option "without-gzip", "if you want to use gzip from other than homebrew"
  depends_on "gzip" => :recommended

  def install

    # I want to install uninstaller script into sbin
    inreplace "install.sh" do |s|
      s.gsub! "~/.cache/dfinity", sbin
      s.gsub! "${HOME}/.cache/dfinity", sbin
    end
    ENV["DFX_VERSION"] = version
    ENV["DFX_INSTALL_ROOT"] = prefix

    ohai "Start official install script."

    require "open3"
    Open3.popen3("sh", "-i", "#{buildpath}/install.sh") do |stdin, stdout, stderr, t|
      stdout.each(chomp: false) do |l|
        odie l if l.match?("Please accept the license to continue.")

        ohai l

        if l.match?(/\[y\/N\]/)
          opoo "Please read above and answer with y/N..."
          stdin << $stdin.gets
          stdin.close
        end
      end

      stdout.each(chomp: false) {|l| ohai l}

      t.join
    end

    bin.install "#{prefix}/dfx"
  end
end
