class Event::EBankPaymentRequest::EPayment::Base < Event::EBankPaymentRequest::Base


  class Event::EBankPaymentRequest::EPayment::Base::PaymentMailerPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :action_name, :body_val, :subject_val, :payment,
                  :company_id, :company

    def init
      self.action_name = params[:action_name]
      self.subject_val = params[:subject]
      self.body_val = params[:body]
      self.payment = params[:payment]
      self.company_id = self.payment.payment_order.company_id
      self.company = self.payment.payment_order.company
    end

    def validate
      self.user.present? && self.payment.present?
    end

    def recipient
      self.payment.receiving_user.email
    end

    def subject
      self.subject_val
    end

    def body
      self.body_val
    end
  end


  def send_mailer(user)
    return if user.blank?
    set_presenter_params(user)
    return unless params[:subject].present? && params[:body].present?
    PaymentMailer.delay.send_mail(Event::EBankPaymentRequest::Base::PaymentRequestMailerPresenter.new(user, params))
    # todo - temporary, for testing. Will be moved to delay before production
    # PaymentMailer.send_mail(Event::EBankPaymentRequest::EPayment::Base::PaymentMailerPresenter.new(user, params)).deliver_now
  end

end
