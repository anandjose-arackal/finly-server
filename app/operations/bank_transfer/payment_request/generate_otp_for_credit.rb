class BankTransfer::PaymentRequest::GenerateOtpForCredit < BankTransfer::PaymentRequest::Base

  include MathUtil

  attr_accessor :otp, :bank_payment_request

  OTP_RESEND_TIMER = 60

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters"
    end
  end

  def init
    id = params[:id] || params[:payment_request_id] || params[:bank_payment_request_id]
    unless id.is_a?(Array)
      id = id.split(",")
    end

    self.bank_payment_request = BankPaymentRequest.where(id: id).first
    # self.bank_payment_request = BankTransfer::PaymentRequest::Index.(user, params).payment_requests.with_id(id).first
  end

  def validate
    unless self.bank_payment_request.can_credit?
      add_message :error, "Payment ticket cannot be credited at this stage"
      return
    end

    if user.otp.present? and user.otp_sent_at > OTP_RESEND_TIMER.seconds.ago
      seconds_remaining = ((user.otp_sent_at + OTP_RESEND_TIMER.seconds) - DateTime.now).to_i
      add_message :error, "You will have to wait for another #{seconds_remaining} seconds before requesting for another OTP"
      return
    end
  end

  def pre_process
    # for now only including mobile OTPs
    if user.otp && user.otp_sent_at > 15.minutes.ago
      self.otp = user.otp
    else
      self.otp = MathUtil.generate_random_number(6)
    end
  end

  def process
    # save the OTP inside the bank payment request that was created
    send_mobile_otp
    self.bank_payment_request.update(otp: self.otp, otp_sent_at: DateUtils.local_date_time, otp_attempts: 0)
    # self.bank_payment_requests.update_all(otp: self.otp, otp_created_at: DateUtils.local_date_time, otp_attempts: 0)
  end

  def post_process
    add_message :success, "OTP sent to your mobile number"
  end

  private

  def send_mobile_otp
    Sms::UserOtp.(user, otp: self.otp)
  end

end