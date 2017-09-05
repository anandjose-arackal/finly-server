class Event::EBankPaymentRequest::Base < Event::SetNotifier

  attr_accessor :bank_payment_request

  def pre_validate
    unless user.present?
      add_message :error, 'User not found'
      return
    end
    if params.blank? or params[:bank_payment_request].blank?
      add_message :error, 'Report not found'
      return
    end
    unless params[:bank_payment_request].is_a?(::BankPaymentRequest)
      add_message :error, 'Error loading report'
    end
  end

  def init
    self.bank_payment_request = params[:bank_payment_request]
  end

  def validate
    unless self.bank_payment_request.present?
      add_message :error, "Payment Request not found"
    end
  end

  def send_mailer(user)
    return if user.blank?
    set_presenter_params(user)
    return unless params[:subject].present? && params[:body].present?
    BankPaymentRequestMailer.delay.send_mail(Event::EBankPaymentRequest::Base::PaymentRequestPresenter.new(user, params))
  end

  def mailer_subject

  end

  def mailer_body

  end

  def mailer_button_name

  end

  def set_presenter_params(user)

  end

  class Event::EBankPaymentRequest::Base::PaymentRequestPresenter < Event::SetNotifier::MailerPresenter

    attr_accessor :bank_payment_request


  end

end
