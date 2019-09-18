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

    # adding validation to check if the OTP has been checked more than 3 times since being sent
    if selected_user.otp_attempts >= 6
      selected_user.update(otp: nil)
      add_message :error, "You have reached the maximum number of attempts for OTP Verification. Please reset the OTP and try again"
      return
    end

    unless selected_user.otp == params[:otp]
      add_message :error, "Wrong OTP"
      selected_user.update_attribute(:otp_attempts, (selected_user.otp_attempts + 1))
      return
    end

  end

  def process
    selected_user.update_attributes(otp: nil, otp_verified_at: DateTime.now, otp_verified: true, otp_attempts: 0)
  end

end