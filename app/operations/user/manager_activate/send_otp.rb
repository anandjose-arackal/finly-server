class User::ManagerActivate::SendOtp < User::ManagerActivate::Base

  attr_accessor :selected_user

  OTP_RESEND_TIMER = Constants::OTP_RESEND_INTERVAL

  # def authorized_user_types
  #   [:manager, :company_admin]
  # end

  def pre_validate
    if params.blank?
      add_message :error, "Invalid input data"
      return
    end
    if param[:user_id].blank? && user.blank?
      add_message :error, "You do not have permission to perform this action"
      return
    end
    if params[:user_id].blank? && params[:mobile_number].blank?
      add_message :error, "Invalid parameters, trye again"
    end
  end

  def init
    if params[:user_id]
      self.selected_user = user.company.users.find_by(id: params[:user_id])
    elsif params[:mobile_number]
      self.selected_user = user.company.users.find_by(id: params[:user_id])
    end
  end

  def authorize
    if params[:user_id]
      unless user.manager? || user.finance_manager? || user.company_admin?
        raise_unauthorized_exception
      end
    end
  end

  def validate
    if selected_user.mobile_number.blank?
      messages[:error] << 'Mobile number not found'
      return
    end
    unless selected_user.mobile_number.match(Constants::VALID_MOBILE_NUMBER).present?
      messages[:error] << 'Invalid Mobile Number'
    end
    if selected_user.otp.present? and selected_user.otp_sent_at > OTP_RESEND_TIMER.seconds.ago
      # i.e. if the otp was sent < 60 seconds ago, don't resend it again
      seconds_remaining = ((selected_user.otp_sent_at + OTP_RESEND_TIMER.seconds) - DateTime.now).to_i
      messages[:error] << "You will have to wait for another #{seconds_remaining} seconds before requesting for another OTP"
    end
  end

  def process
    response = OtpVerification::Create.(selected_user, mobile_number: selected_user.mobile_number)
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
