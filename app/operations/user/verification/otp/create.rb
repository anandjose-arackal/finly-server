class User::Verification::Otp::Create < User::Verification::Otp::Base
  include MathUtil

  attr_accessor :user, :message, :otp, :otp_request_type_id, :mobile_otp, :email_otp

  OTP_RESEND_TIMER = 60

  def pre_validate
    user_present? and params_present?
    return if has_errors?

    unless params[:mobile] or params[:email]
      add_message :error, 'Error in request'
      return
    end

    if params[:email] and user.email.blank?
      add_message :error, 'Email has not been configured for your account'
      return
    end

    if params[:mobile] and user.mobile_number.blank?
      add_message :error, 'Mobile number has not been configured for your account'
      return
    end
  end

  def init
    self.mobile_otp = !!params[:mobile_otp]
    self.email_otp = !!params[:email_otp]
    self.otp_request_type_id = params[:type]
  end

  def validate
    if self.mobile_otp
      unless user.mobile_number.match(Constants::VALID_MOBILE_NUMBER).present?
        add_message :error, 'Invalid Mobile Number'
        return
      end
    end
    if user.otp.present? and user.otp_sent_at > OTP_RESEND_TIMER.seconds.ago
      seconds_remaining = ((user.otp_sent_at + OTP_RESEND_TIMER.seconds) - DateTime.now).to_i
      add_message :error, "You will have to wait for another #{seconds_remaining} seconds before requesting for another OTP"
      return
    end
  end

  def pre_process
    # generating the random 6 digit OTP for a particular user and storing it in the message
    # if the last OTP was sent less than 15 minutes ago, send the same OTP back

    if user.otp && user.otp_request_type_id == otp_request_type_id && user.otp_sent_at > 15.minutes.ago
      self.otp = user.otp
    else
      self.otp = MathUtil.generate_random_number(6)
    end
  end

  def process
    send_mobile_otp if self.mobile
    send_email_otp if self.email

    user.update_attributes(otp_count: (user.otp_count + 1), otp_attempts: 0)

    # further update the otp and sent_at only if a new type of otp has been requested
    if user.otp != otp
      user.update_attributes(otp: otp, otp_sent_at: DateTime.now, otp_request_type_id: otp_request_type_id, otp_attempts: 0)
    end
  end

  def send_mobile_otp
    Sms::UserOtp.(user, otp: self.otp)
  end

  def send_email_otp
    Event::EUserOtp::Verification.(user, {
        user_id: user.id,
        otp: self.otp,
        user_agent: RequestStoreUtil.current_request.user_agent,
        ip: RequestStoreUtil.current_request.remote_ip,
        timestamp: DateTime.now.strftime("%I:%M %p, %d %b %Y")
    })
  end

end