require 'spec_helper'

describe Crypto::SecretBox do
  let (:key) {
  [0x1b,0x27,0x55,0x64,0x73,0xe9,0x85,0xd4,0x62,0xcd,0x51,0x19,0x7a,0x9a,0x46,0xc7,
   0x60,0x09,0x54,0x9e,0xac,0x64,0x74,0xf2,0x06,0xc4,0xee,0x08,0x44,0xf6,0x83,0x89].pack('c*')
  } # from the nacl distribution

  context "new" do
    it "accepts strings" do
      expect { Crypto::SecretBox.new(key) }.to_not raise_error(Exception)
    end

    it "raises on a nil key" do
      expect { Crypto::SecretBox.new(nil) }.to raise_error(ArgumentError, /Must provide a valid key \(#{Crypto::NaCl::SECRETKEYBYTES} bytes\)/)
    end

    it "raises on a short key" do
      expect { Crypto::SecretBox.new("hello") }.to raise_error(ArgumentError, /Must provide a valid key \(#{Crypto::NaCl::SECRETKEYBYTES} bytes\)/)
    end
  end

  include_examples "box" do
    let(:box) { Crypto::SecretBox.new(key) }
  end
end
