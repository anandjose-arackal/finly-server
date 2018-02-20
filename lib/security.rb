class Security

  def self.generate_hmac_hex(token_1, token_2, digest = 'SHA256')
    digest = OpenSSL::Digest.new(digest)

    OpenSSL::HMAC.hexdigest(digest, token_1, token_2)
  end

end