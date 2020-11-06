module CubeJs

  DEFAULT_EXPIRES_IN = 3.hours

  def self.base_url
    Rails.configuration.cube_js.base_url
  end

  def self.api_key
    Rails.configuration.cube_js.api_key
  end

  def self.generate_token(user, expiry: nil)
    expiry ||= DEFAULT_EXPIRES_IN.from_now.to_i
    JWT.encode(
        {u: {id: user.id, company_id: user.company_id},
         exp: expiry},
        api_key
    )
  end

end