class User::ManagerActivate::SendOtp < User::ManagerActivate::Base

  include MathUtil

  attr_accessor :selected_user, :message, :otp, :otp_request_type_id

  OTP_RESEND_TIMER = Constants::OTP_RESEND_INTERVAL

  def authorized_user_types
    [:manager, :finance_manager, :company_admin]
  end

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid input data"
      return
    end
  end

  def init
    self.selected_user = user.company.users.find_by(id: params[:user_id])
    self.otp_request_type_id = params[:type]
  end

  def authorize

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

  def pre_process
    # generating the random 6 digit OTP for a particular user and storing it in the message
    # if the last OTP was sent less than 15 minutes ago, send the same OTP back
    if selected_user.otp_request_type_id == otp_request_type_id && selected_user.otp_sent_at > 15.minutes.ago
      self.otp = selected_user.otp
    else
      self.otp = MathUtil.generate_random_number(6)
    end
  end

  def process
    response = Sms::UserOtp.(user, otp: self.otp)
    if response.success?
      # have to save it without validation because update_attributes considers validations
      selected_user.assign_attributes(otp_count: (selected_user.otp_count+1), otp_sent_at: DateTime.now)
      # update the new otp and otp_sent_at only if a new otp has actually been sent
      if otp != selected_user.otp
        selected_user.assign_attributes(otp: otp, otp_request_type_id: otp_request_type_id)
      end
      selected_user.save(validate: false)
    else
      messages[:error] = response.messages[:error]
    end
  end


end
