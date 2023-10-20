class Event::EInvoice::Base < Event::SetNotifier
  attr_accessor :invoice, :controlling_users, :workflow_output, :role_id, :email_approval_mail

  def pre_validate
    unless user.present?
      add_message :error, 'User not found'
      return
    end
    if params.blank? || params[:invoice].blank?
      add_message :error, 'Invoice not found'
      return
    end
    unless params[:invoice].is_a?(::Invoice)
      add_message :error, 'Error loading invoice'
    end
  end

  def action_name
  end

  def init
    self.invoice = params[:invoice]
    self.workflow_output = params[:workflow_output]
    self.controlling_users = []
    self.role_id = params[:role_id]
    self.email_approval_mail = params[:email_based_approval]
  end

  def validate
    unless self.invoice.present?
      add_message :error, 'Invoice not found'
    end
  end

  def last_trail
    @last_trail ||= invoice.trails.last
  end

  def last_action
    @last_action ||= last_trail.action
  end

  def last_action_name
    @last_action_name ||= last_action.name
  end

  def last_action_user
    @last_action_user ||= last_trail.action_user
  end

  def approving_user
    return nil if last_action.name == 'submit'

    last_action_user
  end

  def is_approver?(user)
    user.id == approving_user&.id
  end

  def is_creator?(user)
    user.id == invoice.created_by_id
  end

  def approved?
    invoice.approved?
  end

  def new_ui_enabled?(user)
    return NonPoInvoiceToggle.new(user).enabled? if invoice.invoice_type.id == InwardInvoiceType.id_for('non_po_invoice')
    return PoInvoiceToggle.new(user).enabled? if invoice.invoice_type.id == InwardInvoiceType.id_for('tax_invoice')
  end

  def send_submit_mails(user)
    if is_creator?(user) || !new_ui_enabled?(user)
      params[:email_based_approval] = false
    else
      params[:email_based_approval] = true
    end
    ProcurementMailer.delay(queue: 'procurements_notification').send_invoice_mail(user.id, mail_presenter_params)
    # ProcurementMailer.send_invoice_mail(user.id, mail_presenter_params).deliver_later
  end

  def send_retract_mails(user)
    params[:email_based_approval] = false
    ProcurementMailer.delay(queue: 'procurements_notification').send_invoice_mail(user.id, mail_presenter_params)
    # ProcurementMailer.send_invoice_mail(user.id, mail_presenter_params).deliver_later
  end

  def send_take_control_mails(user)
    if (is_creator?(user) || is_approver?(user)) && new_ui_enabled?(user)
      params[:email_based_approval] = true
    else
      params[:email_based_approval] = false
    end
    ProcurementMailer.delay(queue: 'procurements_notification').send_invoice_mail(user.id, mail_presenter_params)
    # ProcurementMailer.send_invoice_mail(user.id, mail_presenter_params).deliver_later
  end

  def send_reject_mails(user)
    params[:email_based_approval] = false
    ProcurementMailer.delay(queue: 'procurements_notification').send_invoice_mail(user.id, mail_presenter_params)
    # ProcurementMailer.send_invoice_mail(user.id, mail_presenter_params).deliver_later
  end

  def send_approval_mails(user)
    send_mails(user)
  end

  def send_mails(user)
    if is_approver?(user) || is_creator?(user) || !new_ui_enabled?(user)
      params[:email_based_approval] = false
    else
      params[:email_based_approval] = true
    end
    ProcurementMailer.delay(queue: 'procurements_notification').send_invoice_mail(user.id, mail_presenter_params)
    # ProcurementMailer.send_invoice_mail(user.id, mail_presenter_params).deliver_later
  end

  def mail_presenter_params
    {
      invoice_id: params[:invoice].id,
      body: params[:body],
      subject: params[:subject],
      button_name: params[:button_name],
      event_id: params[:event_id],
      action_name: params[:action_name],
      comment_body: params[:comment_body],
      email_based_approval: params[:email_based_approval]
    }
  end

  def mailer_subject(user)
  end

  def mailer_body(user)
  end

  def mailer_button_name(user)
    'View Invoice'
  end

  def set_presenter_params(user)
    params[:subject] = self.mailer_subject(user)
    params[:body] = self.mailer_body(user)
    params[:button_name] = self.mailer_button_name(user)
    params[:event_id] = event_id
    params[:action_name] = action_name
  end

  def allow_mailer(user, configuration)
    true
  end

  def process
    send_mails_to_users
    send_notifications_to_users
  end

  def send_mails_to_users
    (mailer_affected_users || []).each do |user|
      next if user.blank?

      send_mailer(user) if user.email.present?
    end
  end

  def send_notifications_to_users
    (notification_affected_users || []).each do |user|
      next if user.blank?

      set_notification(user)
    end
  end

  class Event::EInvoice::Base::MailerPresenter < Event::SetNotifier::MailerPresenter
    attr_accessor :payment, :invoice, :user, :body_val, :subject_val, :button_val, :event_id,
                  :action_name, :comment_body, :view_url, :company, :action_url_token, :action_url, :to_name, :reply_to, :email_approval_mail

    def initialize(user, params)
      self.payment = params[:payment]
      self.invoice = params[:invoice]
      self.user = user
      self.body_val = params[:body]
      self.subject_val = params[:subject]
      self.button_val = params[:button_name]
      self.event_id = params[:event_id]
      self.action_name = params[:action_name]
      self.comment_body = params[:comment_body]
      self.view_url = generate_url
      self.company = user.company
      self.to_name = user.name
      self.email_approval_mail = params[:email_based_approval]
      self.reply_to = (self.invoice.email_approvals.last&.approval_uuid&.to_s || '') + Constants::EMAIL_APPROVAL_MAIL_ID # EMAIL_APPROVAL_MAIL_ID = '@approval.email.finly.io'
      # if params[:action_url_token]
      #   self.action_url_token = params[:action_url_token]
      #   action_url = generate_action_url(user, role_id)
      #   self.action_url = action_url.html_safe if action_url.present?
      #   # self.action_url = generate_action_url(user, role_id).html_safe
      # end
    end

    def generate_url
      # Determine view - Temporary, as views will be eliminated

      # view = invoice.created_by_id == user.id ? 'initiator' : 'reviewer'
      if invoice.invoice_type.id == InwardInvoiceType.id_for('non_po_invoice')
        non_po_invoice_url
      else
        po_invoice_url
      end
    end

    def non_po_invoice_url
      if NonPoInvoiceToggle.new(user).enabled?
        suffix = URI.escape("\"procurement_id\":\"#{invoice.procurement.id}\",\"procurement_type\":\"non_po_invoice\"")
        path = "procure_invoices/#{invoice.id}/params={"
        "#{Constants::BASE_URL_VP}#{path}#{suffix}}"
      else
        suffix = URI.escape("{\"document_type\":\"invoice\",\"document_id\":#{invoice.id}}")
        # path = "reports/#{report.id}"
        path = "procurements/#{invoice.procurement.id}/params="
        Constants::BASE_URL_VP + path + suffix
      end
    end

    def po_invoice_url
      suffix = URI.escape("{\"procurement_id\":\"#{invoice.procurement.id}\",\"procurement_type\":\"tax_invoice\",\"forms_enabled\":\"true\"}")
      path = "procure_invoices/#{invoice.id}/params="
      Constants::BASE_URL_VP + path + suffix
    end

    def validate
      self.user.present? and self.invoice.present?
    end

    def to
      self.user.email
    end

    def subject
      self.subject_val
    end

    def set_email_approval_mail
      self.email_approval_mail && invoice.status.processing? && self.body_val.include?('awaiting your approval') && invoice.invoice_type.id == InwardInvoiceType.id_for('non_po_invoice') && NonPoInvoiceToggle.new(user).enabled?
    end

    def body
      self.body_val
    end

    def button_name
      self.button_val
    end
  end
end
