class SummaryMailer::Manager::ProcessSummaryNotification < BaseOperation
  attr_accessor :time_slot, :configurations

  def init
    if self.user.present?
      self.company = self.user.company
    end
  end

  def validate
    unless company.present?
      add_message :error, 'Invalid Action'
      return
    end

    unless company.feature_subscription.expense_management_enabled
      add_message :error, 'Em not enabled'
    end
  end

  def process
    company.users.active.only_managers.each do |user_manager|
      process_configuration(user_manager)
    end
  end

  protected

  def process_configuration(user_manager)
    manager = user_manager.manager?
    summary = {}
    return unless manager
    summary[:roles] = {manager: manager}
    has_pending_reports = set_report_summary summary, user_manager, manager
    has_pending_requests = set_money_request_summary summary, user_manager, manager
    if has_pending_requests or has_pending_reports
      Event::ESummary::Manager.(user_manager, user: user_manager, summary: summary)
    end
  end

  def set_report_summary(summary, user_manager, manager)
    manager_request_count = 0
    if manager
      manager_reports = Report.awaiting_action_items(user_manager.id)
      manager_request_count = manager_reports.count
      summary[:manager_reports] = {count: manager_request_count, reports: manager_reports}
    end

    # return value determines if the user has pending money requests or not
    manager_request_count  > 0
  end

  def set_money_request_summary(summary, user_manager, manager)
    manager_request_count = 0
    if manager
      manager_money_requests = MoneyRequest.awaiting_action_items(user_manager.id)
      manager_request_count = manager_money_requests.count
      summary[:manager_money_requests] = {count: manager_request_count, money_requests: manager_money_requests}
    end

    manager_request_count > 0
  end

end