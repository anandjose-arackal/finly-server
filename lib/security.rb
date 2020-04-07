class Security

  def self.generate_hmac_hex(token_1, token_2, digest = 'SHA256')
    return nil unless token_1.present? and token_2.present?
    digest = OpenSSL::Digest.new(digest)

    OpenSSL::HMAC.hexdigest(digest, token_1&.to_s, token_2&.to_s)
  end

  def self.generate_default_password
    char_array = [("a".."z").to_a,
                  ("A".."Z").to_a,
                  ("0".."9").to_a,
                  %q(#?!@$%^&*-).chars]
    all_values  = char_array.flatten
    arr=[]
    6.times.map do
      arr = char_array.map(&:sample)
      (5 - char_array.size).times{ arr << all_values.sample}
      arr.shuffle.join
    end
    "#{arr.join()}#{SecureRandom.base64(10)}"
  end

end