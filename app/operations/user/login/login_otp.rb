class User::Login::LoginOtp < BaseOperation

  OTP_RESEND_TIMER = Constants::OTP_RESEND_INTERVAL

  def self.call(params)
    super(nil, params)
  end

  def pre_validate
    if params.blank?
      add_message :error, "Please enter a mobile number"
    end
  end

  def init
    self.selected_user = User.find_by(mobile_number: params[:mobile_number])
  end

  def validate
    unless selected_user
      add_message :error, "This mobile number does not exist in our database"
      return
    end

    unless params[:mobile_number] =~ Constants::VALID_MOBILE_NUMBER
      add_message :error, "Please enter a valid mobile number"
      return
    end

    # ensuring the user cannot send an OTP before 60 seconds
    if selected_user.otp.present? and selected_user.otp_sent_at > OTP_RESEND_TIMER.seconds.ago
      # i.e. if the otp was sent < 60 seconds ago, don't resend it again
      seconds_remaining = ((selected_user.otp_sent_at + OTP_RESEND_TIMER.seconds) - DateTime.now).to_i
      messages[:error] << "You will have to wait for another #{seconds_remaining} seconds before requesting for another OTP"
    end
  end

  def process
    response = OtpVerification::Create.(user, mobile_number: selected_user.mobile_number)
    if response.success?
      otp = response.otp
      # have to save it without validation because update_attributes considers validations
      selected_user.assign_attributes(otp: otp, otp_sent_at: DateTime.now, otp_count: (selected_user.otp_count+1))
      selected_user.save(validate: false)
    else
      messages[:error] = response.messages[:error]
    end
  end

end