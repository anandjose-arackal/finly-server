class Event::EPurchaseOrder::Base < Event::SetNotifier
  attr_accessor :purchase_order, :controlling_users, :workflow_output, :role_id, :include_attachments, :purchase_request_creator

  def pre_validate
    unless user.present?
      add_message :error, 'User not found'
      return
    end
    if params.blank? or params[:purchase_order].blank?
      add_message :error, 'Purchase Order not found'
      return
    end
    unless params[:purchase_order].is_a?(::PurchaseOrder)
      add_message :error, 'Error loading purchase order'
    end
  end

  def action_name
  end

  def init
    self.purchase_order = params[:purchase_order]
    self.workflow_output = params[:workflow_output]
    self.controlling_users = []
    self.role_id = params[:role_id]
    self.include_attachments = self.purchase_order&.approved?
    if self.purchase_order.present? && self.purchase_order.purchase_request_items.present?
      purchase_request_creator_ids = self.purchase_order.purchase_request_items.joins(:purchase_request).pluck('purchase_requests.creator_id')
      self.purchase_request_creator = user.company.users.where(id: purchase_request_creator_ids)
    end
  end

  def validate
    unless self.purchase_order.present?
      add_message :error, 'Purchase Order not found'
    end
  end

  def last_trail
    @last_trail ||= purchase_order.trails.last
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

  def approval_uuid
    purchase_order.email_approvals.last&.approval_uuid&.to_s || ''
  end

  def send_mailer(user)
    return if user.blank?

    set_presenter_params(user)
    return unless params[:subject].present? && params[:body].present?

    if last_action_name == 'submit'
      send_submit_mails(user)
    elsif last_action_name == 'retract'
      send_retract_mails(user)
    elsif last_action_name == 'approve'
      send_approval_mails(user)
    elsif last_action_name == 'reject'
      send_reject_mails(user)
    elsif last_action_name == 'take_control'
      send_take_control_mails(user)
    else
      send_mails(user)
    end
  end

  def send_mails(user)
    if user.id == purchase_order.created_by_id || user.id == approving_user&.id
      PurchaseOrderMailer.delay(queue: 'default').send_purchase_order_mail(user.id, mail_presenter_params)
      PurchaseOrderMailer.send_purchase_order_mail(user.id, mail_presenter_params).deliver_later
    else
      PurchaseOrderMailer.delay(queue: 'default').send_po_approval_mail(user.id, mail_presenter_params)
      PurchaseOrderMailer.send_po_approval_mail(user.id, mail_presenter_params).deliver_later
    end
  end

  def send_take_control_mails(user)
    if user.id == purchase_order.created_by_id || user.id == approving_user&.id
      PurchaseOrderMailer.delay(queue: 'default').send_purchase_order_mail(user.id, mail_presenter_params)
      PurchaseOrderMailer.send_po_approval_mail(user.id, mail_presenter_params).deliver_later
    else
      PurchaseOrderMailer.delay(queue: 'default').send_po_approval_mail(user.id, mail_presenter_params)
      PurchaseOrderMailer.send_purchase_order_mail(user.id, mail_presenter_params).deliver_later
    end
  end

  def send_submit_mails(user)
    if user.id == purchase_order.created_by_id
      PurchaseOrderMailer.delay(queue: 'default').send_purchase_order_mail(user.id, mail_presenter_params)
      PurchaseOrderMailer.send_purchase_order_mail(user.id, mail_presenter_params).deliver_later
    else
      PurchaseOrderMailer.delay(queue: 'default').send_po_approval_mail(user.id, mail_presenter_params)
      PurchaseOrderMailer.send_po_approval_mail(user.id, mail_presenter_params).deliver_later
    end
  end

  def send_retract_mails(user)
    PurchaseOrderMailer.delay(queue: 'default').send_purchase_order_mail(user.id, mail_presenter_params)
    PurchaseOrderMailer.send_purchase_order_mail(user.id, mail_presenter_params).deliver_later
  end

  def send_approval_mails(user)
    if user.id == purchase_order.created_by_id || user.id == approving_user&.id
      PurchaseOrderMailer.delay(queue: 'default').send_purchase_order_mail(user.id, mail_presenter_params)
      PurchaseOrderMailer.send_purchase_order_mail(user.id, mail_presenter_params).deliver_later
    else
      PurchaseOrderMailer.delay(queue: 'default').send_po_approval_mail(user.id, mail_presenter_params)
      PurchaseOrderMailer.send_po_approval_mail(user.id, mail_presenter_params).deliver_later
    end
  end

  def send_reject_mails(user)
    PurchaseOrderMailer.delay(queue: 'default').send_purchase_order_mail(user.id, mail_presenter_params)
    PurchaseOrderMailer.send_purchase_order_mail(user.id, mail_presenter_params).deliver_later
  end

  def in_creator_actions?
    ['submit', 'reject', 'retract'].include? last_action.name
  end

  def mailer_subject(user)
  end

  def mailer_body(user)
  end

  def mailer_button_name(user)
    'View Purchase Order'
  end

  def mail_presenter_params
    {
      body: params[:body],
      subject: params[:subject],
      action_name: params[:action_name],
      action_url: params[:action_url],
      purchase_order_id: params[:purchase_order].id,
      email_approval_needed: params[:email_approval_needed]
    }
  end

  def set_presenter_params(user)
    params[:subject] = mailer_subject(user)
    params[:body] = mailer_body(user)
    params[:button_name] = mailer_button_name(user)
    params[:event_id] = event_id
    params[:action_name] = action_name
    params[:include_attachments] = include_attachments
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

  class Event::EPurchaseOrder::Base::MailerPresenter < Event::SetNotifier::MailerPresenter
    attr_accessor :purchase_order, :user, :body_val, :subject_val, :button_val, :event_id,
                  :action_name, :comment_body, :view_url, :company, :action_url_token, :action_url, :include_attachments

    def initialize(user, params)
      self.purchase_order = params[:purchase_order]
      self.user = user
      self.body_val = params[:body]
      self.subject_val = params[:subject]
      self.button_val = params[:button_name]
      self.event_id = params[:event_id]
      self.action_name = params[:action_name]
      self.comment_body = params[:comment_body]
      self.view_url = generate_url.html_safe
      self.company = user.company
      self.include_attachments = params[:include_attachments]
    end

    def generate_url
      suffix = URI.escape('{"show":"purchase_order"}')
      path = "procurements/#{purchase_order.procurement.id}/params="
      url = Constants::BASE_URL_VP + path + suffix
    end

    def validate
      user.present? and purchase_order.present?
    end

    def to
      user.email
    end

    def to_name
      user&.name
    end

    def subject
      subject_val
    end

    def body
      body_val
    end

    def button_name
      button_val
    end

    def reply_to
      approval_uuid + Constants::EMAIL_APPROVAL_MAIL_ID # EMAIL_APPROVAL_MAIL_ID = '@approval.email.finly.io'
    end

    def approval_uuid
      purchase_order.email_approvals.last&.approval_uuid&.to_s || ''
    end
  end
end
