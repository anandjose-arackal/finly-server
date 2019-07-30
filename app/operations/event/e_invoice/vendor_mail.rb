class Event::EInvoice::VendorMail < Event::EInvoice::Base

  attr_accessor :recipient_email
  def pre_validate
    unless user.present?
      add_message :error, 'User not found'
      return
    end
  end

  def action_name
    "Invoice generated"
  end

  def init
    self.invoice = params[:invoice]
  end

  def send_mailer(user)
    preferred_vendor_email = self.invoice.gstin_location.poc_email rescue nil
    fallback_vendor_email =  self.invoice.vendor.gstin_locations.pluck(:poc_email).reject{|email| email.empty? }.first rescue nil
    self.recipient_email = preferred_vendor_email.present? ? preferred_vendor_email : fallback_vendor_email
    return if user.blank? || recipient_email.blank?
    set_presenter_params(user)
    return unless params[:subject].present? && params[:body].present?
    params[:action_name] = action_name
    params[:recipient_email] = recipient_email
    ProcurementMailer.delay.notify_vendor(Event::EInvoice::VendorMail::MailerPresenter.new(user, params))
  end 

  def process
    send_mailer(user)
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
    "Invoice generated"
  end

  def mailer_body(user)
    "Your following invoice has been generated : #{self.invoice.invoice_number} (Invoice ID: #{self.invoice.invoice_id})"
  end

  class Event::EInvoice::VendorMail::MailerPresenter < Event::SetNotifier::MailerPresenter

    attr_accessor :user, :body_val, :subject_val, :button_val, :company, :invoice, :action_name, :action_url, :recipient_email

    def initialize(user, params)
      self.user = user
      self.body_val = params[:body]
      self.subject_val = params[:subject]
      self.company = user.company
      self.invoice = params[:invoice]
      self.action_name = params[:action_name]
      self.action_url = params[:action_url]
      self.recipient_email = params[:recipient_email]
    end

    def validate
      self.invoice.vendor.email.present? rescue false
    end

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

end