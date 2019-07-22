class Event::EPurchaseOrder::RemindAwaitingApproval < Event::EPurchaseOrder::Base

  attr_accessor :purchase_orders

  def pre_validate
    unless user.present?
      add_message :error, 'User not found'
      return
    end
  end

  def action_name
    "PO's awaiting approval"
  end

  def init
    self.purchase_orders = params[:purchase_orders]
  end

  def send_mailer(user)
    return if user.blank?
    set_presenter_params(user)
    return unless params[:subject].present? && params[:body].present?
    params[:action_name] = action_name
    ProcurementMailer.send_awaiting_approval_mail(Event::EPurchaseOrder::RemindAwaitingApproval::MailerPresenter.new(user, params)).deliver_now
  end

  def validate
    if self.purchase_orders.blank?
      add_message :error, "Purchase order not found"
    end
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
    "PO's awaiting approval"
  end

  def mailer_body(user)
    "These PO's are awaiting your approval"
  end

  class Event::EPurchaseOrder::RemindAwaitingApproval::MailerPresenter < Event::SetNotifier::MailerPresenter

    attr_accessor :user, :body_val, :subject_val, :company, :purchase_orders, :action_name, :action_url, :awaiting_approvals

    def initialize(user, params)
      self.user = user
      self.body_val = params[:body]
      self.subject_val = params[:subject]
      self.company = user.company
      # self.purchase_orders = params[:purchase_orders]
      self.action_name = params[:action_name]
      self.action_url = params[:action_url]
      self.awaiting_approvals = params[:purchase_orders]
    end

    def to
      user.email
    end

    def subject
      self.subject_val
    end

    def body
      self.body_val
    end
  end

end