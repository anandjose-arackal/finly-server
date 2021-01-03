class AnalyticsDashboard::Ops::Update < Transactions::API

  step Model(AnalyticsDashboard, :find_by_id)
  step Policy::Pundit(AnalyticsDashboard::Policy, :update?)
  pass :create_if_system_dashboard
  step Contract::Build(constant: AnalyticsDashboard::Contracts::Record)
  step Contract::Validate()
  step Contract::Persist()
  step Transactions::Messages::SuccessMessage('Dashboard saved')

  # Check if the analytics dashboard is a system defined dashboard, if so,
  # then treat it like a new analytics dashboard is being created while linking the system_dashboard to the new record
  def create_if_system_dashboard(context, model:, current_user:, **)
    if model.is_system_dashboard
      context[:model] = model.dup
      context[:model].company = current_user.company
      context[:model].created_by = current_user
      context[:model].system_dashboard_id = model.id
    end
  end

end