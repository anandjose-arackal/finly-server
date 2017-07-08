class User::Verification::Otp::Create < User::Verification::Otp::Base

  include MathUtil

  attr_accessor :selected_user, :message, :otp, :otp_request_type_id

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
    self.otp_request_type_id = params[:type]
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

  def pre_process
    # generating the random 6 digit OTP for a particular user and storing it in the message
    # if the last OTP was sent less than 30 minutes ago, send the same OTP back

    if selected_user.otp && selected_user.otp_request_type_id == otp_request_type_id && selected_user.otp_sent_at > 15.minutes.ago
      self.otp = selected_user.otp
    else
      self.otp = MathUtil.generate_random_number(6)
    end
  end

  def process
    response = Sms::UserOtp.(user, otp: self.otp)
    if response.success?
      selected_user.update_attributes(otp_count: (selected_user.otp_count+1))
      # further update the otp and sent_at only if a new type of otp has been requested
      if selected_user.otp != otp
        selected_user.update_attributes(otp: otp, otp_sent_at: DateTime.now, otp_request_type_id: otp_request_type_id)
      end
    else
      messages[:error] = response.messages[:error]
    end
  end

end