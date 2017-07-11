class Sms::UserOtp < Sms::Send

  def pre_validate
    if params&.dig(:otp).blank?
      add_message :error, 'OTP cannot be blank'
      return
    end
  end

  def message
    "#{params[:otp]} is your OTP verification code"
  end

 end