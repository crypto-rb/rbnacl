# encoding: binary
require 'rake'
require 'rake/clean'
require 'digest/sha2'

LIBSODIUM_VERSION = "0.4.4"
LIBSODIUM_DIGEST  = "3acb9ed90beecccf2de32c066b9c131a6214f7cd0c6f64cd6759c0ef098d653e"

def sh_hidden(command)
  STDERR.puts("*** Executing: #{command}")
  output = `#{command}`

  if !$?.success?
    STDERR.puts "!!! Error executing: #{command}"
    STDERR.puts output
    exit 1
  end
end

libsodium_tarball = "libsodium-#{LIBSODIUM_VERSION}.tar.gz"

file libsodium_tarball do
  sh "curl -L -O https://github.com/jedisct1/libsodium/releases/download/#{LIBSODIUM_VERSION}/#{libsodium_tarball}"

  digest = Digest::SHA256.hexdigest(File.read(libsodium_tarball))
  if digest != LIBSODIUM_DIGEST
    rm libsodium_tarball
    raise "#{libsodium_tarball} failed checksum! Got #{digest}"
  end
end

file "libsodium" => libsodium_tarball do
  sh "tar -zxf #{libsodium_tarball}"
  mv "libsodium-#{LIBSODIUM_VERSION}", "libsodium"
end

file "libsodium/Makefile" => "libsodium" do
  sh_hidden "cd libsodium && ./configure"
end

file "libsodium/src/libsodium/.libs/libsodium.a" => "libsodium/Makefile" do
  sh_hidden "cd libsodium && make"
end

if `uname` == 'Darwin'
  libsodium_lib = "libsodium.bundle"
else
  libsodium_lib = "libsodium.so"
end

file "libsodium/src/libsodium/.libs/#{libsodium_lib}" => "libsodium/src/libsodium/.libs/libsodium.a"

task :build_libsodium => "libsodium/src/libsodium/.libs/#{libsodium_lib}" do
  $LIBSODIUM_PATH = "libsodium/src/libsodium/.libs/#{libsodium_lib}"
end

CLEAN.add "libsodium", "libsodium-*.tar.gz"
