class Event::EDocument::ReportsAwaitingApproval < BaseOperation

  attr_accessor :reports, :reports_awaiting_approval_columns

  def pre_validate
    unless user.present?
      add_message :error, 'User not found'
      return
    end
  end

  def action_name
    "Documents awaiting approval"
  end

  def init
    self.reports = params[:reports]
    self.report_awaiting_approval_columns = ["#", "Report ID", "Created By", "Amount"]
  end

  def send_mailer(user)
    return if user.blank?
    set_presenter_params(user)
    return unless params[:subject].present? && params[:body].present?
    params[:action_name] = action_name

    params[:reports] = self.reports
    params[:report_awaiting_approval_columns] = report_awaiting_approval_columns

    ReportMailer.delay.send_awaiting_approval_mail(Event::EDocument::ReportsAwaitingApproval::MailerPresenter.new(user, params))
  end

  def set_presenter_params(user)
    params[:subject] = self.mailer_subject(user)
    params[:body] = self.mailer_body(user)
  end

  def validate  
  end 

  def process
    # Email is in form of table. Set column values against column names
    set_report_column_values if self.reports.present?

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
    "Documents awaiting your approval"
  end

  def mailer_body(user)
    "These documents are awaiting your approval"
  end

  class Event::EDocument::ReportsAwaitingApproval::MailerPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :user, :body_val, :subject_val, :company, :action_name, :action_url, :report_awaiting_approvals, :report_awaiting_approval_columns, :report_awaiting_approval_column_values

    def initialize(user, params)
      self.user = user
      self.body_val = params[:body]
      self.subject_val = params[:subject]
      self.company = user.company
      self.action_name = params[:action_name]
      self.action_url = params[:action_url]

      setup_report_section(params)
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

    private

    def setup_report_section(params)
      self.report_awaiting_approvals = params[:reports]
      self.report_awaiting_approval_columns = params[:report_awaiting_approval_columns]
      self.report_awaiting_approval_column_values = params[:report_awaiting_approval_column_values]
    end
  end

  private
  def set_report_column_values
    column_values = []
    self.reports.each.with_index(1) do |report, index|
      total_amount = precision_value(report.total_amount || 0)
      column_values << [index, report.id, report.user&.name, "Rs " + total_amount.to_s]
    end
    if column_values.present?
      params[:report_awaiting_approval_column_values] = column_values
    end
  end

end