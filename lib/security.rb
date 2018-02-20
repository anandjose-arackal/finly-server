class Security

  def self.generate_hmac_hex(token_1, token_2, digest = 'SHA256')
    return nil unless token_1.present? and token_2.present?
    digest = OpenSSL::Digest.new(digest)

    OpenSSL::HMAC.hexdigest(digest, token_1&.to_s, token_2&.to_s)
  end

end