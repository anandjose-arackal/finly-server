class OtpVerification::Base < BaseHandler

  def application_key
    if type == 'invitation'
      Constants::INVITATION_API_KEY
    elsif type == 'verification'
      Constants::VERIFICATION_API_KEY
    else
      Constants::VERIFICATION_API_KEY
    end
  end

end