class SummaryMailer::Manager::ProcessReports < BaseOperation
  attr_accessor :time_slot, :configurations

  def self.call
    self.new.run
  end

  def initialize
    super(nil, nil)
  end

  def init
    self.configurations = fetch_configurations
    # self.configurations = ManagerSummaryMailConfig.all
  end

  def validate
    if self.configurations.blank?
      add_message :error, 'No user has requested for summary at this time'
      return
    end
  end

  def process
    self.configurations&.each { |config| process_configuration config }
  end

  protected
  def fetch_time_slot(datetime)
    time_slot = datetime.strftime('%H')
    if datetime.minute < 30
      time_slot += ':00'
    else
      time_slot += ':30'
    end
    time_slot
  end

  def fetch_configurations
    datetime = DateTime.now
    day_of_month = datetime.day
    day_of_week = datetime.strftime("%A")
    self.time_slot = fetch_time_slot datetime
    ManagerSummaryMailConfig.configurations_for(day_of_month, day_of_week, self.time_slot).group_by_user
  end

  def process_configuration(configuration)
    user = configuration.user
    manager = user.manager?
    finance_manager = user.finance_manager?
    summary = {}
    return unless manager or finance_manager
    summary[:roles] = {manager: manager, finance_manager: finance_manager}
    has_pending_reports = set_report_summary summary, user, manager, finance_manager
    has_pending_requests = set_money_request_summary summary, user, manager, finance_manager
    if has_pending_requests or has_pending_reports
      Event::ESummary::Manager.(user, user: user, summary: summary)
    end
  end

  def set_report_summary(summary, user, manager, finance_manager)
    manager_request_count = 0
    finance_request_count = 0
    if manager
      manager_reports = Report.awaiting_action_items(user.id)
      manager_request_count = manager_reports.count
      summary[:manager_reports] = {count: manager_request_count, reports: manager_reports}
    end
    if finance_manager
      finance_reports =  Report.finance_associated_items(user).filter_report_status('approved')
      finance_request_count = finance_reports.count
      summary[:finance_reports] = {count: finance_request_count, reports: finance_reports}
    end
    # return value determines if the user has pending money requests or not
    (manager_request_count + finance_request_count) > 0
  end

  def set_money_request_summary(summary, user, manager, finance_manager)
    manager_request_count = 0
    finance_request_count = 0
    if manager
      manager_money_requests = user.manager_money_requests.awaiting_approval_of_user(user.id, UserRole.id_for(:manager))
      manager_request_count = manager_money_requests.count
      summary[:manager_money_requests] = {count: manager_request_count, money_requests: manager_money_requests}
    end
    if finance_manager
      finance_money_requests = user.finance_money_requests.awaiting_approval_of_user(user.id, UserRole.id_for(:finance_manager))
      finance_request_count = finance_money_requests.count
      summary[:finance_money_requests] = {count: finance_request_count, money_requests: finance_money_requests}
    end
    # return value determines if the user has pending money requests or not
    (manager_request_count + finance_request_count) > 0
  end

end