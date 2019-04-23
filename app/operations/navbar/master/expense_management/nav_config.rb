class Navbar::Master::ExpenseManagement::NavConfig < Navbar::Master::Base

  register_app :em
  register_structure(
      :tabs,
      [
          :dashboard,
          {expenses: [:your_expenses, :team_expenses, :policy_expenses, :company_expenses]},
          {trips: [:your_trips, :team_trips, :policy_trips, :company_trips]},
          {reports: [:your_reports, :team_reports, :policy_reports, :company_reports]},
          {money_requests: [:your_money_requests, :team_money_requests, :policy_money_requests, :company_money_requests]},
          {users: [:team_users, :company_users]},
          {settlements: [:team_settlements, :company_settlements]},
          :analytics,
          {export: [:your_exports, :team_exports, :policy_exports, :company_exports]},
          {create: [:create_expense, :create_trip, :create_report, :create_money_request]}
      ]
  )

  def dashboard
    {name: 'Dashboard', id: 'dashboard', url: 'dashboard'}
  end

  def expenses
    {name: 'Expenses', id: 'expenses', url: 'expenses'}
  end

  def trips
    {name: 'Trips', id: 'trips', url: 'trips'}
  end

  def your_trips
    {name: 'Your Trips', id: 'trips', url: 'trips?view=personal'}
  end

  def team_trips
    {name: 'Team - Trips', id: 'trips', url: 'trips?view=manager'}
  end

  def policy_trips
    {name: 'Policy - Trips', id: 'trips', url: 'trips?view=personal'}
  end

  def reports
    {name: 'Reports', id: 'reports', url: 'reports'}
  end

  def money_requests
    {name: 'Money_requests', id: 'money_requests', url: 'money_requests'}
  end

  def users
    {name: 'Users', id: 'users', url: 'users'}
  end

  def settlements
    {name: 'Settlements', id: 'settlements', url: 'settlements'}
  end

  def export
    {name: 'Export', id: 'export', url: 'export'}
  end

  def create
    {name: 'Create', id: 'create', url: 'create'}
  end


end