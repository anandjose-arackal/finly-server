class ItzCash::Base < BaseHandler

  def base_url
    url = super
    (url or 'https://staging.itzcash.com')
  end

end