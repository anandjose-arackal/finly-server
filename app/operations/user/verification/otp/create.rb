class User::Verification::Otp::Create < User::Verification::Otp::Base

  def pre_validate
    if user.blank?
      messages[:error] << 'User not found'
      return
    end
    if user.mobile_number.blank?
      messages[:error] << 'Mobile number not found'
      return
    end
    unless user.mobile_number.match(Constants::VALID_MOBILE_NUMBER).present?
      messages[:error] << 'Invalid Mobile Number'
    end
    if user.otp.present? and user.otp_sent_at > 30.seconds.ago
      seconds_remaining = ((user.otp_sent_at + 30.seconds) - DateTime.now).to_i
      messages[:error] << "You will have to wait for another #{seconds_remaining} seconds before requesting for another OTP"
    end
  end

  def process
    response = OtpVerification::Create.(user, mobile_number: user.mobile_number)
    if response.success?
      otp = response.otp
      user.update_attributes(otp: otp, otp_sent_at: DateTime.now, otp_count: (user.otp_count+1))
    else
      messages[:error] = response.messages[:error]
    end
  end

  # def success
  #   true
  # end

end