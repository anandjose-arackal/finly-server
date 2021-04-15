class User::Password::SendResetPasswordOtp < BaseOperation

  OTP_RESEND_TIMER = Constants::OTP_RESEND_INTERVAL
    attr_accessor  :user_not_found


  def self.call(params)
    super(nil, params)
  end

  def validate
    if selected_user.blank?
      self.user_not_found = true
      return
    end
    if selected_user.otp.present? and selected_user.otp_sent_at > OTP_RESEND_TIMER.seconds.ago
      seconds_remaining = ((selected_user.otp_sent_at + OTP_RESEND_TIMER.seconds) - DateTime.now).to_i
      messages[:error] << "You will have to wait for another #{seconds_remaining} seconds before requesting for another OTP"
    end
  end

  def process
    unless self.user_not_found
      response = OtpVerification::Create.(selected_user, mobile_number: selected_user.mobile_number)
      if response.success?
        otp = response.otp
        selected_user.update_attributes(otp: otp, otp_sent_at: DateTime.now, otp_count: (selected_user.otp_count+1), otp_attempts: 0)
      else
        messages[:error] = response.messages[:error]
      end
    end
    add_message :success, 'OTP sent successfully'
  end
end