# submit_pending_columns = Columns in the email template 
class Event::EInvoice::SubmitPending < BaseOperation

  attr_accessor :invoices, :submit_pending_columns

  def pre_validate
    unless user.present?
      add_message :error, 'User not found'
      return
    end
  end

  def action_name
    "Invoices pending submission"
  end

  def init
    self.invoices = params[:invoices]
    [index, invoice.procurement_id, invoice.invoice_number, invoice.due_date, invoice&.balance_due&.value, invoice&.created_by&.name, invoice&.created_at&.to_date]
    self.submit_pending_columns = ["#", "Procurement ID", "Invoice #", "Due Date", "Balance Due", "Created by", "Created at"]
  end

  def send_mailer(user)
    return if user.blank?
    set_presenter_params(user)
    return unless params[:subject].present? && params[:body].present?
    params[:action_name] = action_name
    params[:submit_pending_columns] = submit_pending_columns
    ProcurementMailer.delay.send_awaiting_approval_mail(Event::EInvoice::SubmitPending::MailerPresenter.new(user, params))
  end

  def validate
    if self.invoices.blank?
      add_message :error, "Invoices not found"
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
    "Invoices pending submission"
  end

  def mailer_body(user)
    "These invoices are pending from your end for submission"
  end

  class Event::EInvoice::SubmitPending::MailerPresenter < Event::SetNotifier::MailerPresenter

    attr_accessor :user, :body_val, :subject_val, :company, :invoices, :action_name, :action_url, :pending_submissions, :pending_submission_columns, :pending_submission_column_values

    def initialize(user, params)
      self.user = user
      self.body_val = params[:body]
      self.subject_val = params[:subject]
      self.company = user.company
      self.action_name = params[:action_name]
      self.action_url = params[:action_url]
      self.pending_submissions = params[:invoices]
      self.pending_submission_columns = params[:pending_submission_columns]
      self.pending_submission_column_values = params[:pending_submission_column_values]
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
    self.invoices.each.with_index(1) do |invoice, index|
      column_values << [index, invoice.procurement_id, invoice.invoice_number, invoice.due_date, invoice&.balance_due&.value, invoice&.created_by&.name, invoice&.created_at&.to_date]
    end
    if column_values.present?
      params[:awaiting_approval_column_values] = column_values
    end
  end
end