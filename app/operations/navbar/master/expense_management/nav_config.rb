class Navbar::Master::ExpenseManagement::NavConfig < Navbar::Master::Base

  register_app :em
  register_structure(
      :tabs,
      [
          :dashboard,
          :receipts,
          {expenses: [:your_expenses, :company_expenses]},
          {money_requests: [:your_money_requests, :money_requests_awaiting_approval, :team_money_requests, :company_money_requests]},
          {reports: [:your_reports, :reports_awaiting_approval, :team_reports, :company_reports]},
          {trips: [:your_trips, :trips_awaiting_approval, :team_trips, :travel_manager_trips, :company_trips]},
          {settlements: [:team_settlements, :company_settlements]},
          # :analytics,
          {export: [:team_exports, :company_exports]},
          {create: [:create_expense, :create_trip, :create_report, :create_money_request]}
      ]
  )

  register_structure(
      :cog, [
      :users,
      :load_company_balance, :statements,
      :organization_account,
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

  def analytics
    {name: 'Analytics', id: 'analytics', url: 'analytics'}
  end

  def expenses
    {name: 'Expenses', id: 'expenses', url: 'expenses/params={"view":"personal"}'}
  end

  def your_expenses
    {name: 'Your Expenses', id: 'expenses', url: 'expenses/params={"view":"personal"}'}
  end

  def company_expenses
    {name: 'Company Expenses', id: 'expenses', url: 'expenses/params={"view":"admin"}'}
  end

  def receipts
    {name: 'Receipts', id: 'receipts', url: 'receipts/params={"view":"personal"}'}
  end

  def trips
    {name: 'Trips', id: 'trips', url: 'trips/params={"view":"personal"}'}
  end

  def your_trips
    {name: 'Your Trips', id: 'trips', url: 'trips/params={"view":"personal"}'}
  end

  def trips_awaiting_approval
    {name: 'Awaiting Approval', id: 'trips', url: 'trips/params={"view":"manager"}'}
  end

  def team_trips
    {name: 'Team Trips', id: 'trips', url: 'trips/params={"view":"manager"}'}
  end

  def travel_manager_trips
    {name: 'Travel Manager Trips', id: 'trips', url: 'trips/params={"view":"travel_manager"}'}
  end

  def company_trips
    {name: 'Company Trips', id: 'trips', url: 'trips/params={"view":"admin"}'}
  end

  def reports
    {name: 'Reports', id: 'reports', url: 'reports/params={"view":"personal"}'}
  end

  def your_reports
    {name: 'Your Reports', id: 'reports', url: 'reports/params={"view":"personal"}'}
  end

  def reports_awaiting_approval
    {name: 'Awaiting Approval', id: 'reports', url: 'reports/params={"view":"manager"}'}
  end

  def team_reports
    {name: 'Team Reports', id: 'reports', url: 'reports/params={"view":"manager"}'}
  end

  def company_reports
    {name: 'Company Reports', id: 'reports', url: 'reports/params={"view":"admin"}'}
  end

  def money_requests
    {name: 'Money Requests', id: 'money_requests', url: 'money_requests/params={"view":"personal"}'}
  end

  def your_money_requests
    {name: 'Your Money Requests', id: 'money_requests', url: 'money_requests/params={"view":"personal"}'}
  end

  def money_requests_awaiting_approval
    {name: 'Awaiting Approval', id: 'money_requests', url: 'money_requests/params={"view":"manager"}'}
  end

  def team_money_requests
    {name: 'Team Money Requests', id: 'money_requests', url: 'money_requests/params={"view":"manager"}'}
  end

  def company_money_requests
    {name: 'Company Money Requests', id: 'money_requests', url: 'money_requests/params={"view":"admin"}'}
  end

  def team_users
    {name: 'Team Users', id: 'users', url: 'users/params={"view":"manager"}'}
  end

  def company_users
    {name: 'Company Users', id: 'users', url: 'users/params={"view":"admin"}'}
  end

  def settlements
    {name: 'Team Settlements', id: 'settlements', url: 'settlements/params={"view":"finance"}'}
  end

  def team_settlements
    {name: 'Team Settlements', id: 'settlements', url: 'settlements/params={"view":"finance"}'}
  end

  def company_settlements
    {name: 'Company Settlements', id: 'settlements', url: 'settlements/params={"view":"admin"}'}
  end

  def export
    {name: 'Team Export', id: 'export', url: 'export/params={"view":"manager"}'}
  end

  def team_exports
    {name: 'Team Export', id: 'export', url: 'export/params={"view":"manager"}'}
  end

  def company_exports
    {name: 'Company Export', id: 'export', url: 'export/params={"view":"admin"}'}
  end

  def users
    {name: 'Users', id: 'users', url: '#users/params={"view":"admin"}'}
  end

  def load_company_balance
    {name: 'Load Company Balance', id: 'load-company-balance', url: '/transfers/register'}
  end

  def statements
    {name: 'Statements', id: 'statements', url: '#company_statements/params={"view":"admin"}'}
  end

  def create
    {name: 'Create', id: 'create', url: 'create'}
  end

  def create_expense
    {name: 'Create Expense', id: 'create_expense', url: 'expenses/new_expense/params={"view":"personal"}'}
  end

  def create_trip
    {name: 'Create Trip', id: 'create_trip', url: 'trips/params={"view":"personal",  "create": "true"}'}
  end

  def create_report
    {name: 'Create Report', id: 'create_report', url: 'reports/params={"view":"personal", "create": "true"}'}
  end

  def create_money_request
    {name: 'Create Money Request', id: 'create_money_request', url: 'money_requests/params={"view":"personal", "create": "true"}'}
  end

end