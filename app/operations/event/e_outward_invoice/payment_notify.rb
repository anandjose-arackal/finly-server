class Event::EOutwardInvoice::PaymentNotify < Event::SetNotifier
  attr_accessor :target_users, :invoice_data, :outward_invoice, :amount_credited

  def pre_validate
    if params.blank? or params[:invoice_data].blank?
      add_message :error, 'No data found'
    end
    unless params[:invoice_data][:invoice].is_a?(::OutwardInvoice)
      add_message :error, 'Error loading invoice'
    end
  end

  def init
    self.outward_invoice = params[:invoice_data][:invoice]
    self.amount_credited = params[:invoice_data][:amount]
  end

  def validate
    if outward_invoice.incomplete?
      add_message :error, "Incompete invoice cannot be sent to customers."
    end
  end

  def event_id
    NotifierType.id_for(:outward_invoice_payment)
  end

  def send_mailer(user)
    return if user.blank?
    set_presenter_params(user)
    return unless params[:subject].present? && params[:body].present?

    InvoiceMailer.delay.payment_notify(Event::EOutwardInvoice::PaymentNotify::PaymentNotifyMailerPresenter.new(user, params))
  end


  def send_sms(user)
    return if user.blank? || user.mobile_number.blank?
    message = sms_message(user)
    # now trigger the API used for sending SMSes
    op = Sms::Send.(user, {message: message, mobile_number: user.mobile_number})
  end

  def affected_users
    customer_emails = outward_invoice.email.split(",").map {|email| email.strip}
    affected_users = []
    for customer_email in customer_emails
      customer = Event::EOutwardInvoice::PaymentNotify::Customer.new({email: customer_email})
      affected_users << customer
    end

    affected_users << outward_invoice.user
  end

  def sms_affected_users
    customer_mobile = outward_invoice.mobile_number
    affected_users = []
    customer = Event::EOutwardInvoice::PaymentNotify::Customer.new({mobile_number: customer_mobile})
    affected_users << customer
    affected_users << outward_invoice.user
  end

  def set_presenter_params(user)
    params[:subject] = self.mailer_subject(user)
    params[:body] = self.mailer_body(user)
    params[:outward_invoice] = self.outward_invoice
    params[:event_id] = event_id
  end

  def mailer_subject(user)
    subject = "Payment for invoice #{outward_invoice.invoice_number}"
    if user.is_a?(User)
      subject = "Payment received for invoice #{outward_invoice.invoice_number}"
    elsif user.is_a?(Event::EOutwardInvoice::PaymentNotify::Customer)
      subject = "Successfully paid for invoice #{outward_invoice.invoice_number}"
    end
  end

  def mailer_body(user)
    body = "Payment for invoice #{outward_invoice.invoice_number}"
    if user.is_a?(User)
      body = "Received payment of #{amount_credited} for invoice #{outward_invoice.invoice_number}"
    elsif user.is_a?(Event::EOutwardInvoice::PaymentNotify::Customer)
      body = "Payment of #{amount_credited} successful for invoice #{outward_invoice.invoice_number}"
    end
  end

  def sms_message(user)
    message = "Finly : Payment for invoice #{outward_invoice.invoice_number}"
    if user.is_a?(User)
      message = "Finly : Received payment of #{amount_credited} for invoice #{outward_invoice.invoice_number}"
    elsif user.is_a?(Event::EOutwardInvoice::PaymentNotify::Customer)
      message = "Payment of #{amount_credited} successful for invoice #{outward_invoice.invoice_number}"
    end
  end

  class Event::EOutwardInvoice::PaymentNotify::Customer
    attr_accessor :email, :mobile_number

    def initialize(data = {})
      self.email = data[:email]
      self.mobile_number = data[:mobile_number]
    end
  end


  class Event::EOutwardInvoice::PaymentNotify::PaymentNotifyMailerPresenter < Event::SetNotifier::MailerPresenter
    attr_accessor :subject_val, :body_val, :outward_invoice
                  :company

    def init
      self.subject_val = params[:subject]
      self.body_val = params[:body]
      self.outward_invoice = params[:outward_invoice]
      # self.company = user.company
    end

    def email_to
      self.user.email
    end

    def email_subject
      self.subject_val
    end

    def email_body
      self.body_val
    end

  end

end
