class Event::EBankPaymentRequest::CreditOtp < Event::EBankPaymentRequest::Base

  attr_accessor :crediting_user, :otp

  def init
    super
    self.crediting_user = self.bank_payment_request.trails.last.action_user
    self.otp =params[:otp]
  end


  def validate
    super
    unless self.crediting_user.present?
      add_message :error, 'Crediting user not found'
    end
  end

  def action_name
    "Payment Order Credit OTP"
  end

  def affected_users
    [crediting_user]
  end

  def event_id
    NotifierType.id_for(:bank_payment_request_credit_confirm)
  end


  def mailer_subject(user)
    return "Credit OTP for your payment order"
  end

  def mailer_body(user)

    return "Requested OTP for the credit of #{bank_payment_request.name} is #{self.otp} "
  end


end