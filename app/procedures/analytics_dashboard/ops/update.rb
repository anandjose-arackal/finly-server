class AnalyticsDashboard::Ops::Update < Transactions::API

  step Model(AnalyticsDashboard, :find_by_id)
  step Policy::Pundit(AnalyticsDashboard::Policy, :update?)
  step Contract::Build(constant: AnalyticsDashboard::Contract)
  step Contract::Validate()
  step Contract::Persist()
  step Transactions::Messages::SuccessMessage('Dashboard saved')

end