class OtpVerification::Base < BaseHandler

  def application_key
    Constants::VERIFICATION_API_KEY
  end

end