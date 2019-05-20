class User::Verification::Otp::Verify < User::Verification::Otp::Base

  attr_accessor :selected_user, :set_password_token

  class User::Verification::Otp::Verify::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :set_password_token

    def init
      self.set_password_token = params[:set_password_token]
    end

  end

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
      selected_user.update(otp: nil)
      add_message :error, 'You have reached the maximum number of attempts for OTP Verification. Please reset the OTP and try again'
      return
    end

    unless selected_user.otp == params[:verification_code]
      add_message :error, 'Wrong OTP'
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
    RequestStoreUtil.current_session.verify(:otp)
  end

  def post_process
    if selected_user.expired?
      raw, enc = Devise.token_generator.generate(User, :reset_password_token)
      self.set_password_token = raw
      selected_user.update_attribute(:reset_password_token, enc)
      selected_user.update_attribute(:reset_password_sent_at, DateUtils.local_date_time)
    end
  end

  def success
    User::Verification::Otp::Verify::SuccessPresenter.new(user, {set_password_token: self.set_password_token}, messages)
  end

end