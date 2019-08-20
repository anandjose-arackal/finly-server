# awaiting_approval_columns = Columns in the email template 
class Event::EPurchaseRequest::RemindAwaitingApproval < Event::EPurchaseRequest::Base

  attr_accessor :purchase_requests, :awaiting_approval_columns

  def pre_validate
    unless user.present?
      add_message :error, 'User not found'
      return
    end
  end

  def action_name
    "PR's awaiting approval"
  end

  def init
    self.purchase_requests = params[:purchase_requests]
    self.awaiting_approval_columns = ["#", "PR #", "Created By", "Location", "Amount"]
  end

  def send_mailer(user)
    return if user.blank?
    set_presenter_params(user)
    return unless params[:subject].present? && params[:body].present?
    params[:action_name] = action_name
    params[:awaiting_approval_columns] = awaiting_approval_columns
    ProcurementMailer.delay.send_awaiting_approval_mail(Event::EPurchaseRequest::RemindAwaitingApproval::MailerPresenter.new(user, params))
  end

  def validate
    if self.purchase_requests.blank?
      add_message :error, "Purchase request not found"
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
    "PR's awaiting approval"
  end

  def mailer_body(user)
    "These Purchase Requests are awaiting your approval"
  end

  class Event::EPurchaseRequest::RemindAwaitingApproval::MailerPresenter < Event::SetNotifier::MailerPresenter

    attr_accessor :user, :body_val, :subject_val, :company, :purchase_requests, :action_name, :action_url, :awaiting_approvals, :awaiting_approval_columns, :awaiting_approval_column_values

    def initialize(user, params)
      self.user = user
      self.body_val = params[:body]
      self.subject_val = params[:subject]
      self.company = user.company
      # self.purchase_requests = params[:purchase_requests]
      self.action_name = params[:action_name]
      self.action_url = params[:action_url]
      self.awaiting_approvals = params[:purchase_requests]
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
    self.purchase_requests.each.with_index(1) do |purchase_request, index|
      total_amount = precision_value(purchase_request.total_amount&.value || 0)
      column_values << [index, purchase_request.order_number, purchase_request.creator&.name, purchase_request&.location&.name, "Rs " + total_amount.to_s]
    end
    if column_values.present?
      params[:awaiting_approval_column_values] = column_values
    end
  end
end