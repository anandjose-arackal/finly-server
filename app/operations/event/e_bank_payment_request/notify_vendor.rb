class Event::EBankPaymentRequest::NotifyVendor < Event::EBankPaymentRequest::Base

  attr_accessor :recipient_email, :payment, :crediting_user, :document_details
  def pre_validate
    unless user.present?
      add_message :error, 'User not found'
      return
    end
  end

  def action_name
    "Payment Credited"
  end

  def init
    self.payment = params[:payment]
    self.crediting_user = payment.payment_order.bank_payment_request.trails.last.action_user
  end

  def validate
    # super
    unless self.crediting_user.present?
      add_message :error, 'User not found'
    end
  end

  def pre_process
    self.document_details = {}
    vendor_details
  end

  def process
    send_mailer(user)
  end

  def send_mailer(user)
    self.recipient_email = self.document_details[:email]
    return if user.blank? || recipient_email.blank?

    set_presenter_params(user)
    return unless params[:subject].present? && params[:body].present?

    params[:action_name] = action_name
    params[:recipient_email] = recipient_email
    BankPaymentRequestMailer.delay.notify_vendor(Event::EBankPaymentRequest::NotifyVendor::MailerPresenter.new(user, params))
  end

  def event_id
    nil
  end

  def affected_users
  end

  def notification_affected_users
  end

  def set_notification(user)
  end

  def mailer_subject(user)
    "Congratulations! Your #{self.document_details[:document_name]} #{self.document_details[:document_id]} has been credited"
  end

  def mailer_body(user)
    "Payment of &#8377;#{payment.amount.value} has been processed by \"#{crediting_user.name}\" from company \"#{crediting_user.company.name}\" against your #{self.document_details[:document_name].downcase} #{self.document_details[:document_id]}."
  end

  class Event::EBankPaymentRequest::NotifyVendor::MailerPresenter < Event::SetNotifier::MailerPresenter

    attr_accessor :user, :body_val, :subject_val, :button_val, :company, :payment, :action_name, :action_url, :recipient_email

    def initialize(user, params)
      self.user = user
      self.body_val = params[:body]
      self.subject_val = params[:subject]
      self.company = user.company
      self.payment = params[:payment]
      self.action_name = params[:action_name]
      self.action_url = params[:action_url]
      self.recipient_email = params[:recipient_email]
    end

    # def validate
    #   self.invoice.vendor.email.present? rescue false
    # end

    def to
      self.recipient_email
    end

    def subject
      self.subject_val
    end

    def body
      self.body_val
    end
  end

  private

  def vendor_details
    case self.payment.parent_type
    when 'Invoice'
      self.document_details[:email] = self.payment.parent.gstin_location&.poc_email
      self.document_details[:document_name] = self.payment.parent_type.titleize
      self.document_details[:document_id] = self.payment.parent&.invoice_number
    when 'PurchaseOrder'
      self.document_details[:email] = self.payment.parent.gstin_location&.poc_email
      self.document_details[:document_name] = self.payment.parent_type.titleize
      self.document_details[:document_id] = self.payment.parent&.po_number
    when 'BeneficiaryPayment'
      self.document_details[:email] = self.payment.receiving_user.gstin_locations.pluck(:poc_email).reject{|email| email.empty? }.first
      self.document_details[:document_name] = self.payment.parent_type.titleize
      self.document_details[:document_id] = ""
    end
  end

end