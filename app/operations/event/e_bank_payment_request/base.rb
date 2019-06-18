class Event::EBankPaymentRequest::Base < Event::SetNotifier

  attr_accessor :bank_payment_request, :role_id

  def pre_validate
    unless user.present?
      add_message :error, 'User not found'
      return
    end
    if params.blank? or (params[:bank_payment_request].blank? && params[:payment].blank?)
      add_message :error, 'Payment Order not found'
      return
    end
    unless params[:bank_payment_request].is_a?(::BankPaymentRequest)
      add_message :error, 'Error loading Payment Order'
    end
  end

  def init
    self.bank_payment_request = params[:bank_payment_request]
    self.role_id = params[:role_id]
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
    BankPaymentRequestMailer.delay.send_mail(Event::EBankPaymentRequest::Base::PaymentRequestMailerPresenter.new(user, params))
    # # todo - temporary, for testing. Will be moved to delay before production
    # BankPaymentRequestMailer.send_mail(Event::EBankPaymentRequest::Base::PaymentRequestMailerPresenter.new(user, params)).deliver_now
  end

  def send_sms(user)
    return if user.blank? || user.mobile_number.blank?
    message = sms_message
    # now trigger the API used for sending SMSes
    op = Sms::Send.(user, {message: message, mobile_number: user.mobile_number})
  end

  def mailer_subject(user)

  end

  def mailer_body(user)

  end

  def mailer_button_name

  end

  def sms_message

  end

  def bank_payment_request_view_role(user)

  end

  def set_presenter_params(user)
    params[:subject] = self.mailer_subject(user)
    params[:body] = self.mailer_body(user)
    params[:event_id] = event_id
    params[:action_name] = action_name
    params[:role_id] = bank_payment_request_view_role user
    if self.bank_payment_request.present? && self.bank_payment_request.credited?
      params[:cc_emails] = cc_emails_from_beneficiary_payments unless cc_emails_from_beneficiary_payments.blank?
    end
  end

  class Event::EBankPaymentRequest::Base::PaymentRequestMailerPresenter < Event::SetNotifier::MailerPresenter

    attr_accessor :bank_payment_request, :action_name, :subject_val, :body_val,
                  :event_id, :company, :view_role_id, :view_url, :payment, :cc_emails

    def init
      self.bank_payment_request = params[:bank_payment_request]
      self.payment = params[:payment]
      self.action_name = params[:action_name]
      self.subject_val = params[:subject]
      self.body_val = params[:body]
      self.event_id = params[:event_id]
      self.company = user.company
      self.view_role_id = params[:role_id]
      self.view_url = generate_view_url
      self.cc_emails = params[:cc_emails]
    end

    def validate
      self.user.present? && (self.bank_payment_request.present?)
    end

    def recipient
      self.user.email
    end

    def subject
      self.subject_val
    end

    def body
      self.body_val
    end

    def generate_view_url
      return if self.bank_payment_request.blank?
      view = ""
      case view_role_id
        when 4, '4' # i.e. initiator
          view = "initiator"
        when 3, '3' # i.e. reviewer
          view = "reviewer"
        when 2, '2' # i.e. creditor
          view = "creditor"
        when 1, '1' # i.e. admin
          view = "admin"
        else
          view = "initiator"
      end
      suffix = URI.escape("{}")
      url = "#{Constants::BASE_URL_VP}orders/#{bank_payment_request.id}/params=" + suffix
    end

  end

  private
  def cc_emails_from_beneficiary_payments
    emails = []
    beneficiary_payment_ids = self.bank_payment_request.payment_order.payments.pluck(:beneficiary_payment_id) rescue nil
    if beneficiary_payment_ids.present?
      begin
        user.company.beneficiary_payments.where(id: beneficiary_payment_ids).pluck(:payment_notification_users).each{|cc_emails| emails << cc_emails["cc_emails"]}
      rescue
        return nil
      end
      return emails.flatten.compact
    end

    nil
  end

end
