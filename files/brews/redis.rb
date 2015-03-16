require 'formula'

class Redis < Formula
  homepage 'http://redis.io/'
  url 'http://download.redis.io/releases/redis-2.8.19.tar.gz'
  sha1 "3e362f4770ac2fdbdce58a5aa951c1967e0facc8"

  bottle do
    sha1 "ba238ce5e71f5c0c3cb997ebda0cf594f75e8069" => :yosemite
    sha1 "0902233ed41683e22a1ecd8010f2875c9b0b9dba" => :mavericks
    sha1 "4b8100b40edd0e6ef695e28bf4fd30360939c3f3" => :mountain_lion
  end

  head "https://github.com/antirez/redis.git", :branch => "unstable"

  version '2.8.19-boxen1'

  fails_with :llvm do
    build 2334
    cause 'Fails with "reference out of range from _linenoise"'
  end

  def install
    # Architecture isn't detected correctly on 32bit Snow Leopard without help
    ENV["OBJARCH"] = "-arch #{MacOS.preferred_arch}"

    system "make", "install", "PREFIX=#{prefix}", "CC=#{ENV.cc}"

    %w[run db/redis log].each { |p| (var+p).mkpath }

    # Fix up default conf file to match our paths
    inreplace "redis.conf" do |s|
      s.gsub! "/var/run/redis.pid", "#{var}/run/redis.pid"
      s.gsub! "dir ./", "dir #{var}/db/redis/"
      s.gsub! "\# bind 127.0.0.1", "bind 127.0.0.1"
    end


    # Fix redis upgrade from 2.4 to 2.6.
    if File.exists?(etc/'redis.conf') && !File.readlines(etc/'redis.conf').grep(/^vm-enabled/).empty?
      mv etc/'redis.conf', etc/'redis.conf.old'
      ohai "Your redis.conf will not work with 2.8; moved it to redis.conf.old"
    end

    etc.install 'redis.conf' unless (etc/'redis.conf').exist?
  end
end
