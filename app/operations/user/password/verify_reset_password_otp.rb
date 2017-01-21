class User::Password::VerifyResetPasswordOtp < BaseOperation


  def validate
    unless selected_user
      add_message :error, "User not found. Please enter your registered mobile number"
      return
    end
    unless selected_user.mobile_number == params[:mobile_number]
      add_message :error, "Mobile number does not match"
      return
    end
    unless selected_user.otp == params[:otp]
      add_message :error, "OTP entered does not match. Please enter the OTP sent to your mobile number"
    end
  end

  def process
    selected_user.update_attributes(otp: nil, otp_verified_at: DateTime.now, otp_verified: true)
  end

end