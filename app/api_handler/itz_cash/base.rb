class ItzCash::Base < BaseHandler
  attr_accessor :response_code

  def base_url
    url = super
    (url or 'https://staging.itzcash.com')
  end

  def parse
    super
    self.response_code = parsed_response[0] if self.parsed_response.present?
  end

  def success?
    super and self.response_code.present? and self.response_code.to_f >= 200 and self.response_code.to_f <= 200
  end

  def failure
    add_message :error, self.parsed_response.last if self.parsed_response.present?
    super
  end

end