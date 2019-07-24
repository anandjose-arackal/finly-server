class Event::EBankPaymentRequest::RemindAwaitingApproval < Event::EBankPaymentRequest::Base
  attr_accessor :bank_payment_requests, :awaiting_approval_columns

  def pre_validate
    unless user.present?
      add_message :error, 'User not found'
      return
    end
  end

  def action_name
    "Payment Tickets's awaiting approval"
  end

  def init
    self.bank_payment_requests = params[:bank_payment_requests]
    self.awaiting_approval_columns = ["#", "PT #", "Initiating User", "Scheduled Date", "Requested Amount"]
  end

  def send_mailer(user)
    return if user.blank?
    set_presenter_params(user)
    return unless params[:subject].present? && params[:body].present?
    params[:action_name] = action_name
    params[:awaiting_approval_columns] = awaiting_approval_columns
    ProcurementMailer.delay.send_awaiting_approval_mail(Event::EBankPaymentRequest::RemindAwaitingApproval::MailerPresenter.new(user, params))
  end

  def validate
    if self.bank_payment_requests.blank?
      add_message :error, "Payment Ticket not found"
    end
  end 

  def process
    # Email is in form of table. Set column values against column names
    set_column_values
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
    "Payment ticket's awaiting approval"
  end

  def mailer_body(user)
    "These payment tickets are awaiting your approval"
  end

  class Event::EBankPaymentRequest::RemindAwaitingApproval::MailerPresenter < Event::SetNotifier::MailerPresenter

    attr_accessor :user, :body_val, :subject_val, :company, :bank_payment_requests, :action_name, :action_url, :awaiting_approvals, :awaiting_approval_columns, :awaiting_approval_column_values

    def initialize(user, params)
      self.user = user
      self.body_val = params[:body]
      self.subject_val = params[:subject]
      self.company = user.company
      # self.bank_payment_requests = params[:bank_payment_requests]
      self.action_name = params[:action_name]
      self.action_url = params[:action_url]
      self.awaiting_approvals = params[:bank_payment_requests]
      self.awaiting_approval_columns = params[:awaiting_approval_columns]
      self.awaiting_approval_column_values = params[:awaiting_approval_column_values]
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

  private
  def set_column_values
    column_values = []
    self.bank_payment_requests.each.with_index(1) do |payment_request, index|
      requested_amount = precision_value(payment_request.payment_order.amount_requested&.value || 0)
      scheduled_at = payment_request.payment_order.scheduled_at.strftime('%d %b %Y') rescue nil
      column_values << [index, payment_request.id, payment_request&.payment_order&.initiating_user&.name, scheduled_at, "Rs " + requested_amount.to_s]
    end
    if column_values.present?
      params[:awaiting_approval_column_values] = column_values
    end
  end
end