class BankTransfer::PaymentRequest::GenerateOtpForCredit < BankTransfer::PaymentRequest::Base

  include MathUtil

  attr_accessor :otp, :bank_payment_request, :bank_payment_requests

  OTP_RESEND_TIMER = 60

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters"
    end
  end

  def init
    id = params[:id] || params[:payment_request_id] || params[:bank_payment_request_id]
    if id.blank?
      add_message :error, "Unprocessable payment ticket. Please review the errors in the summary."
      return
    end
    unless id.is_a?(Array)
      id = id.split(",")
    end

    # self.bank_payment_request = BankPaymentRequest.where(id: id).first
    bprs = BankTransfer::PaymentRequest::Index.(user, params).payment_requests.with_id(id) rescue nil

    # Extracting BPRs with Ids from index operation as Mysql update statement cannot have a select statement using the target table
    # https://dev.mysql.com/doc/refman/5.6/en/update.html
    # ERROR 1093 (HY000): You can't specify target table 'items' for update in FROM clause

    self.bank_payment_requests = BankPaymentRequest.with_id(bprs&.pluck(:id))
  end

  def validate
    if bank_payment_requests.empty?
      add_message :error, "Payment orders not found"
    end

    self.bank_payment_requests.each do |bpr|
      unless bpr.can_credit?
        add_message :error, "Payment ticket ID #{bpr.id} cannot be credited at this stage"
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
    self.bank_payment_requests.update_all(otp: self.otp, otp_sent_at: DateUtils.local_date_time, otp_attempts: 0)
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