class Event::EInvoice::VendorMail < Event::EInvoice::Base

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
    vendor_email = self.invoice.vendor.email rescue nil
    return if user.blank? || vendor_email.blank?
    set_presenter_params(user)
    return unless params[:subject].present? && params[:body].present?
    params[:action_name] = action_name
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
    "Your invoice has been generated"
  end

  class Event::EInvoice::VendorMail::MailerPresenter < Event::SetNotifier::MailerPresenter

    attr_accessor :user, :body_val, :subject_val, :button_val, :company, :invoice, :action_name, :action_url

    def initialize(user, params)
      self.user = user
      self.body_val = params[:body]
      self.subject_val = params[:subject]
      self.company = user.company
      self.invoice = params[:invoice]
      self.action_name = params[:action_name]
      self.action_url = params[:action_url]
    end

    def validate
      self.invoice.vendor.email.present? rescue false
    end

    def to
      self.invoice.vendor.email
    end

    def subject
      self.subject_val
    end

    def body
      self.body_val
    end
  end

end