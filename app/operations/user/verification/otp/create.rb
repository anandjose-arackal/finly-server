class User::Verification::Otp::Create < User::Verification::Otp::Base

  attr_accessor :selected_user

  OTP_RESEND_TIMER = 60

  def pre_validate
    if user.blank?
      messages[:error] << 'User not found'
      return
    end
  end

  def init
    if params[:user_id].present?
      self.selected_user = user.company.users.find_by(id: params[:user_id])
    else
      self.selected_user = user
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
      seconds_remaining = ((selected_user.otp_sent_at + OTP_RESEND_TIMER.seconds) - DateTime.now).to_i
      messages[:error] << "You will have to wait for another #{seconds_remaining} seconds before requesting for another OTP"
    end
  end

  def process
    response = OtpVerification::Create.(selected_user, mobile_number: selected_user.mobile_number)
    if response.success?
      otp = response.otp
      selected_user.update_attributes(otp: otp, otp_sent_at: DateTime.now, otp_count: (selected_user.otp_count+1))
    else
      messages[:error] = response.messages[:error]
    end
  end

  # def success
  #   true
  # end

end