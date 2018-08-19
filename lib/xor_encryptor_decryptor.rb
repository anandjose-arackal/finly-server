class XorEncryptorDecryptor

  def self.encrypt_decrypt(string, key)
    key = key.split("")
    result = ""
    codepoints = string.each_codepoint.to_a
    codepoints.each_index do |i|
      result += (codepoints[i] ^ key[i % key.size].ord).chr
    end
    result
  end
end