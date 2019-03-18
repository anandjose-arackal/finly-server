class User::Verification::Otp::Verify < User::Verification::Otp::Base

  attr_accessor :selected_user

  def pre_validate
    if user.blank?
      messages[:error] << 'User not found'
      return
    end
    if params.blank? or params[:verification_code].blank?
      messages[:error] << 'Verification cannot be blank'
      return
    end
  end

  def init
    if params[:user_id]
      self.selected_user = user.company.users.find_by(id: params[:user_id])
    else
      self.selected_user = user
    end
  end

  def validate
    if selected_user.otp_attempts >= 6
      add_message :error, "You have reached the maximum number of attempts for OTP Verification. Please reset the OTP and try again"
      return
    end

    unless selected_user.otp == params[:verification_code]
      add_message :error, "OTP entered does not match. Please enter the OTP sent to your mobile number"
      selected_user.update_attribute(:otp_attempts, (selected_user.otp_attempts + 1))
      return
    end

    if params[:verification_code].length < 6 or params[:verification_code].length > 6 or selected_user.otp != params[:verification_code]
      messages[:error] << 'Invalid verification code'
      return
    end
  end

  def process
    # skipping validations because users from the mobile number invite flow won't have their details filled in yet
    selected_user.assign_attributes(otp: nil, otp_verified_at: DateTime.now, otp_verified: true)
    selected_user.save(validate: false)
    RequestStoreUtil.current_session.verify
  end

end