require "formula"

# Documentation: https://github.com/Homebrew/homebrew/wiki/Formula-Cookbook
#                /usr/local/Library/Contributions/example-formula.rb
# PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!

# REMOVE ME: deps: yasm, nspr, nss, xulrunner

class Conkeror < Formula
  homepage "http://www.conkeror.org"

  # There is no official 'current' release, and there are not tarballs, so just grab master
  url "git://repo.or.cz/conkeror.git", :using => :git, :branch => "master"
  version "1.0pre"

  depends_on "xulrunner"

  #resource "icon" do
  #end

  def install
    system "make"
    (prefix/"conkeror.app").mkpath
    (prefix/"conkeror.app/Contents/MacOS").mkpath

    ["conkeror-spawn-helper", "Info.plist", "application.ini", "chrome.manifest", "content-policy.manifest",
     "branding", "chrome", "components", "content", "contrib", "defaults", "help", "locale", "modules",
     "search-engines", "style", "tests"].each do |item|
      prefix.install item => "conkeror.app"
    end

    File.open("conkeror", 'w') {|f| f.write("#!/bin/sh\nxulrunner "+prefix+"/conkeror.app/application.ini $@") }
    bin.install "conkeror"
    system "ln -s "+bin+"/conkeror "+prefix+"/conkeror.app/Contents/MacOS"
  end

  test do
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! It's enough to just replace
    # "false" with the main program this formula installs, but it'd be nice if you
    # were more thorough. Run the test with `brew test conkeror`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system "#{bin}/program", "do", "something"`.
    system "false"
  end
end
