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
    if params[:verification_code].length < 6 or params[:verification_code].length > 6 or user.otp != params[:verification_code]
      messages[:error] << 'Invalid verification code'
    end
  end

  def init
    if params[:user_id]
      self.selected_user = user.company.users.find_by(id: params[:user_id])
    else
      self.selected_user = user
    end
  end

  def process
    selected_user.update_attributes(otp: nil, otp_verified_at: DateTime.now, otp_verified: true)
  end

end