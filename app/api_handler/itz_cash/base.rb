class ItzCash::Base < BaseHandler
  attr_accessor :response_code

  def base_url
    url = super
    (url or 'https://staging.itzcash.com')
  end

  def parse
    super
    self.response_code = parsed_response[0]
  end

  def success?
    super and self.response_code >= 200 and self.response_code <= 200
  end

end