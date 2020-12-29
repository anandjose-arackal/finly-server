class AnalyticsDashboard::Ops::Show < Transactions::API

  step Model(AnalyticsDashboard, :find_by_id)
  step Policy::Pundit(AnalyticsDashboard::Policy, :show?)

end