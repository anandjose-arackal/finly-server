class SummaryMailer::Manager::ProcessSummaryNotification < BaseOperation
  attr_accessor :time_slot, :configurations

  def self.call
    self.new.run
  end

  def initialize
    super(nil, nil)
  end

  def validate
    unless current_company.present?
      add_message :error, 'Invalid Action'
    end

    unless current_company.feature_subscription.expense_management
      add_message :error, 'Em not enabled'
    end
  end

  def process
    current_company.users.only_managerseach do |user|
      process_configuration(user)
    end
  end

  protected

  def process_configuration(user)
    manager = user.manager?
    summary = {}
    return unless manager
    summary[:roles] = {manager: manager}
    has_pending_reports = set_report_summary summary, user, manager
    has_pending_requests = set_money_request_summary summary, user, manager
    if has_pending_requests or has_pending_reports
      Event::ESummary::Manager.(user, user: user, summary: summary)
    end
  end

  def set_report_summary(summary, user, manager)
    manager_request_count = 0
    if manager
      manager_reports = Report.awaiting_action_items(user.id)
      manager_request_count = manager_reports.count
      summary[:manager_reports] = {count: manager_request_count, reports: manager_reports}
    end

    # return value determines if the user has pending money requests or not
    manager_request_count  > 0
  end

  def set_money_request_summary(summary, user, manager)
    manager_request_count = 0
    if manager
      manager_money_requests = user.manager_money_requests.awaiting_approval_of_user(user.id, UserRole.id_for(:manager))
      manager_request_count = manager_money_requests.count
      summary[:manager_money_requests] = {count: manager_request_count, money_requests: manager_money_requests}
    end

    manager_request_count > 0
  end

end