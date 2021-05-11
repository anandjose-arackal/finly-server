class Event::EBankPaymentRequest::CreditOtp < Event::EBankPaymentRequest::Base

  attr_accessor :crediting_user, :otp

  def init
    super
    self.crediting_user = user
    self.otp =params[:otp]
  end


  def validate
    super
    unless self.crediting_user.present?
      add_message :error, 'Crediting user not found'
    end
  end

  def action_name
    "Requested OTP for crediting payment"
  end

  def affected_users
    [crediting_user]
  end

  def event_id
    NotifierType.id_for(:bank_payment_request_credit_confirm)
  end


  def mailer_subject(user)
    return "Requested OTP for crediting payment"
  end

  def mailer_body(user)
    return self.otp
  end

  def send_mailer(user)
    return if user.blank?
    set_presenter_params(user)
    return unless params[:subject].present? && params[:body].present?
    BankPaymentRequestMailer.delay(:queue => 'payments_creation').notify_payment_otp(Event::EBankPaymentRequest::Base::PaymentRequestMailerPresenter.new(user, params))
  end


end