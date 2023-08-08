class Event::EPurchaseRequest::Base < Event::SetNotifier
  attr_accessor :purchase_request, :workflow_output, :email_approval_needed, :reply_to
  attr_reader :last_trail, :last_action, :last_action_user, :approving_user

  def pre_validate
    unless user.present?
      add_message :error, 'User not found'
      return
    end
    if params.blank? or params[:purchase_request].blank?
      add_message :error, 'Purchase Request not found'
      return
    end
    unless params[:purchase_request].is_a?(::PurchaseRequest)
      add_message :error, 'Error loading purchase order'
    end
  end

  def init
    self.purchase_request = params[:purchase_request]
    self.workflow_output = params[:workflow_output]
    self.email_approval_needed = params[:email_approval_needed]
    self.reply_to = approval_uuid + Constants::EMAIL_APPROVAL_MAIL_ID # EMAIL_APPROVAL_MAIL_ID = '@approval.email.finly.io'
  end

  def last_trail
    @last_trail ||= purchase_request.trails.last
  end

  def last_action
    @last_action ||= last_trail.action
  end

  def last_action_user
    @last_action_user ||= last_trail.action_user
  end

  def approving_user
    return nil if last_action.name == 'submit'

    last_action_user
  end

  def approval_uuid
    purchase_request.email_approvals.last&.approval_uuid&.to_s || ''
  end

  def validate
    unless self.purchase_request.present?
      add_message :error, 'Purchase Request not found'
    end
  end

  def action_name
  end

  def send_mailer(user)
    return if user.blank?

    set_presenter_params(user)
    return unless params[:subject].present? && params[:body].present?

    if (user.id == params[:purchase_request].creator_id && submit_or_reject) || user.id == approving_user&.id
      PurchaseRequestMailer.delay(queue: 'procurements_notification').send_purchase_request_mail(user.id, mail_presenter_params)
      # PurchaseRequestMailer.send_purchase_request_mail(user.id, mail_presenter_params).deliver_later
    else
      PurchaseRequestMailer.delay(queue: 'procurements_notification').send_pr_approval_mail(user.id, mail_presenter_params)
      # PurchaseRequestMailer.send_pr_approval_mail(user.id, mail_presenter_params).deliver_later
    end
  end

  def submit_or_reject
    ['submit', 'reject'].include? last_action.name
  end

  def mailer_subject(user)
  end

  def mailer_body(user)
  end

  def mailer_button_name(user)
  end

  def mail_presenter_params
    {
      bodd: params[:body],
      subject: params[:subject],
      action_name: params[:action_name],
      action_url: params[:action_url],
      purchase_request_id: params[:purchase_request].id,
      email_approval_needed: params[:email_approval_needed]
    }
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

  class Event::EPurchaseRequest::Base::MailerPresenter < Event::SetNotifier::MailerPresenter
    attr_accessor :user, :body_val, :subject_val, :purchase_request, :action_name, :action_url

    def initialize(user, params)
      self.user = user
      self.body_val = params[:body]
      self.subject_val = params[:subject]
      self.purchase_request = params[:purchase_request]
      self.action_name = params[:action_name]
      self.action_url = params[:action_url]
    end

    def to
      user&.email
    end

    def to_name
      user&.name
    end

    def company
      user&.company
    end

    def subject
      subject_val
    end

    def body
      body_val
    end

    def view_url
      Constants::BASE_URL_VP + "purchase_request/#{purchase_request.id}/params={}"
    end

    def reply_to
      approval_uuid + Constants::EMAIL_APPROVAL_MAIL_ID # EMAIL_APPROVAL_MAIL_ID = '@approval.email.finly.io'
    end

    def approval_uuid
      purchase_request.email_approvals.last&.approval_uuid&.to_s || ''
    end
  end
end
