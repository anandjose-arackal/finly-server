class Navbar::Master::ExpenseManagement::NavConfig < Navbar::Master::Base

  register_app :em
  register_structure(
      :tabs,
      [
          :dashboard,
          :expenses,
          :receipts,
          :trips,
          :reports,
          :money_requests,
          #:travel_request_bookings,
          {approvals: [:money_requests_awaiting_approval, :reports_awaiting_approval, :trips_awaiting_approval]},
          {team: [:team_settlements, :team_users, :team_exports, :divider, :documents_section, :team_money_requests, :team_expenses , :team_reports, :team_trips, :travel_request_bookings]},
          {admin: [:analytics, :company_settlements, :company_users, :company_exports, :divider, :documents_section, :company_money_requests, :company_expenses, :company_reports, :company_trips]},
          {auditor: [:analytics, :company_money_requests, :company_expenses, :company_reports, :company_trips]},
          # :analytics,
          # {expenses: [:your_expenses, :company_expenses]},
          # {money_requests: [:your_money_requests, :money_requests_awaiting_approval, :team_money_requests, :company_money_requests]},
          # {reports: [:your_reports, :reports_awaiting_approval, :team_reports, :company_reports]},
          # {settlements: [:team_settlements, :company_settlements]},
          # :analytics,
          # {export: [:team_exports, :company_exports]},
          {create: [:create_expense, :create_trip, :create_report, :create_money_request]}
      ]
  )

  register_structure(
      :cog_menu, [
      :users,
      :company_statements,
      :personal_statements,
      :organization_account
  ]
  )

  register_structure(
      :cog_modules, [
      :finly_vendor_payments, :finly_disburse, :finly_collect, :finly_insights
  ]
  )


  def self.accept?
    return false unless RequestStoreUtil.current_company&.feature_subscription&.expense_management_enabled
    true
  end

  def dashboard
    {name: 'Dashboard', id: 'dashboard', url: 'dashboard'}
  end

  def expenses
    {name: 'Expenses', id: 'expenses', url: 'expenses/params={"view":"personal"}'}
  end

  def your_expenses
    {name: 'Your Expenses', id: 'expenses', url: 'expenses/params={"view":"personal"}'}
  end

  def company_expenses
    return nil unless user.admin? || user.auditor?
    view = user.admin? ? "admin" : "auditor"
    {name: 'Expenses', id: "#{view}", url: "expenses/params={\"view\":\"#{view}\", \"main_tab\": \"#{view}\"}"}
  end

  def receipts
    {name: 'Receipts', id: 'receipts', url: 'receipts/params={"view":"personal"}'}
  end

  def trips
    return nil unless user.company.feature_subscription.travel_request && user.user_panel_subscription.travel_request
    {name: 'Trips', id: 'trips', url: 'travel_requests/params={"view":"personal"}'}
  end

  def your_trips
    return nil unless user.company.feature_subscription.travel_request && user.user_panel_subscription.travel_request
    {name: 'Your Trips', id: 'trips', url: 'travel_requests/params={"view":"personal"}'}
  end

  def trips_awaiting_approval
    return nil unless user.company.feature_subscription.travel_request && user.user_panel_subscription.travel_request
    return nil unless user.manager? || user.admin?
    {name: 'Trips', id: 'approvals', url: 'travel_requests/params={"view":"manager", "filter_status":"processing", "main_tab": "approvals"}'}
  end

  def team_trips
    return nil unless user.company.feature_subscription.travel_request && user.user_panel_subscription.travel_request
    return nil unless user.manager? || user.finance_manager?
    view = user.finance_manager? ? "finance_manager" : "manager"
    {name: 'Trips', id: 'team', url: "travel_requests/params={\"view\":\"#{view}\", \"main_tab\": \"team\"}"}
  end

  def travel_request_bookings
    return nil unless user.company.feature_subscription.travel_request && user.user_panel_subscription.travel_request
    return nil unless user.is_travel_manager?
    {name: 'Bookings', id: 'trip-bookings', url: 'travel_requests/params={"view":"travel_manager", "filter_status":"booking_pending"}'}
  end

  def company_trips
    return nil unless user.company.feature_subscription.travel_request && user.user_panel_subscription.travel_request
    return nil unless user.admin? || user.auditor?
    view = user.admin? ? "admin" : "auditor"
    {name: 'Trips', id: "#{view}", url: "travel_requests/params={\"view\": \"#{view}\", \"main_tab\": \"#{view}\"}"}
  end

  def reports
    {name: 'Reports', id: 'reports', url: 'reports/params={"view":"personal"}'}
  end

  def your_reports
    {name: 'Your Reports', id: 'reports', url: 'reports/params={"view":"personal"}'}
  end

  def reports_awaiting_approval
    return nil unless user.manager? || user.admin?
    {name: 'Reports', id: 'approvals', url: 'reports/params={"view":"manager", "filter_status":"99", "main_tab": "approvals"}'}
  end

  def team_expenses
    return nil unless user.manager? || user.finance_manager?
    view  = user.finance_manager? ? "finance_manager" : "manager"
    {name: 'Expenses', id: 'expenses', url: "expenses/params={\"view\":\"#{view}\", \"main_tab\": \"team\"}"}
  end

  def team_reports
    return nil unless user.manager? || user.finance_manager?
    view = user.finance_manager? ? "finance_manager" : "manager"
    {name: 'Reports', id: 'team', url: "reports/params={\"view\":\"#{view}\", \"main_tab\": \"team\"}"}
  end

  def company_reports
    return nil unless user.admin? || user.auditor?
    view = user.admin? ? "admin" : "auditor"
    {name: 'Reports', id: "#{view}", url: "reports/params={\"view\": \"#{view}\", \"main_tab\": \"#{view}\"}"}
  end

  def money_requests
    {name: 'Money Requests', id: 'money_requests', url: 'requests/params={"view":"personal"}'}
  end

  def your_money_requests
    {name: 'Your Money Requests', id: 'money_requests', url: 'requests/params={"view":"personal"}'}
  end

  def money_requests_awaiting_approval
    return nil unless user.manager? || user.admin?
    {name: 'Money Requests', id: 'approvals', url: 'requests/params={"view":"manager", "filter_status":"99", "main_tab": "approvals"}'}
  end

  def team_money_requests
    return nil unless user.manager? || user.finance_manager?
    view = user.finance_manager? ? "finance_manager" : "manager"
    {name: 'Money Requests', id: 'team', url: "requests/params={\"view\":\"#{view}\", \"main_tab\": \"team\"}"}
  end

  def company_money_requests
    return nil unless user.admin? || user.auditor?
    view = user.admin? ? "admin" : "auditor"
    {name: 'Money Requests', id: "#{view}", url: "requests/params={\"view\": \"#{view}\", \"main_tab\": \"#{view}\"}"}
  end

  def settlements
    return nil unless user.finance_manager? || user.admin?
    {name: 'Settlements', id: 'settlements', url: 'settlements_dashboard/params={"view":"finance"}'}
  end

  def team_settlements
    return nil unless user.finance_manager?
    {name: 'Settlements', id: 'team', url: 'settlements_dashboard/params={"view":"finance", "main_tab": "team"}'}
  end

  def company_settlements
    return nil unless user.admin?
    {name: 'Settlements', id: 'admin', url: 'settlements_dashboard/params={"view":"admin", "main_tab": "admin"}'}
  end

  def export
    return nil unless user.manager? || user.admin?
    {name: 'Export', id: 'export', url: 'export/params={"view":"manager"}'}
  end

  def team_exports
    return nil unless user.manager? || user.admin? || user.finance_manager?
    {name: 'Export', id: 'team', url: 'export/params={"view":"manager", "main_tab": "team"}'}
  end

  def company_exports
    return nil unless user.admin?
    {name: 'Export', id: 'admin', url: 'export/params={"view":"admin", "main_tab": "admin"}'}
  end

  def team_users
    return nil unless user.manager? || user.finance_manager?
    view = user.finance_manager? ? "finance_manager" : "manager"
    {name: 'Users', id: 'team', url: "employees/params={\"view\":\"#{view}\", \"main_tab\": \"team\"}"}
  end

  def company_users
    return nil unless user.admin?
    {name: 'Users', id: 'admin', url: 'employees/params={"view":"admin", "main_tab": "admin"}'}
  end

  def load_company_balance
    return nil unless user.admin? || user.finance_manager?
    {name: 'Load Company Balance', id: 'load-company-balance', url: '/transfers/register'}
  end

  def company_statements
    return nil unless user.admin? || user.auditor?
    {name: 'Company Statements', id: 'statements', url: '#company_statements/params={"view":"admin"}'}
  end

  def personal_statements
    {name: 'Personal Statements', id: 'personal-statements', url: "#statements/#{user.id}/params={\"view\":\"personal\"}"}
  end

  def create
    {name: 'Create', id: 'create', url: 'create'}
  end

  def create_expense
    {name: 'Create Expense', id: 'create_expense', url: 'expenses/new_expense/params={"view":"personal"}'}
  end

  def create_trip
    {name: 'Create Trip', id: 'create_trip', url: 'travel_requests/params={"view":"personal",  "create": "true"}'}
  end

  def create_report
    {name: 'Create Report', id: 'create_report', url: 'reports/params={"view":"personal", "create": "true"}'}
  end

  def create_money_request
    {name: 'Create Money Request', id: 'create_money_request', url: 'requests/params={"view":"personal", "create": "true"}'}
  end

  def analytics
    return nil unless RequestStoreUtil.current_company&.analytics_system_enabled?
    {name: 'Analytics', id: 'admin', url: 'analytics/params={"main_tab": "admin"}'}
  end

  def approvals
    if user.manager?
      reports_awaiting_approval&.merge({name: 'Approvals'})
    end
  end

  def admin
    return nil unless user.admin?
    RequestStoreUtil.current_company&.analytics_system_enabled? ? analytics&.merge({name: 'Admin'}) : company_settlements&.merge({name: 'Admin'})
  end

  def auditor
    return nil if user.admin? || !user.auditor?
    RequestStoreUtil.current_company&.analytics_system_enabled? ? analytics&.merge({name: 'Auditor'}) : company_money_requests&.merge({name: 'Auditor'})
  end

  # def team
    # return nil unless user.manager? || user.finance_manager?
    # user.finance_manager? ? team_settlements&.merge({name: "Team"}) : team_users&.merge({name: "Team"})

  # end

  def team
    return nil unless user.manager? || user.finance_manager? || user.is_travel_manager? 
    if user.finance_manager?
      team_settlements&.merge({name: "Team"})
    elsif user.manager?
      team_users&.merge({name: "Team"})
    elsif user.is_travel_manager?
      travel_request_bookings&.merge({name: "Team"})
    end   
  end

  def documents_section
    return nil unless user.manager? || user.admin?
    {type: 'section', name: 'Records'}
  end

  def divider
    return nil unless user.manager? || user.admin?
    {type: 'divider'}
  end

  def users
    return nil unless user.admin?
    {name: 'Users', id: 'users', url: '#employees/params={"view":"admin", "main_tab": "admin"}'}
  end

end