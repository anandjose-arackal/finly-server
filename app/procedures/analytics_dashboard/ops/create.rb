class AnalyticsDashboard::Ops::Create < Transactions::API

  step Model(AnalyticsDashboard, :new)
  step Policy::Pundit(AnalyticsDashboard::Policy, :create?)
  step AssignModelUser(key: :created_by)
  step :assign_app
  step Contract::Build(constant: AnalyticsDashboard::Contracts::Record)
  step Contract::Validate()
  step Contract::Persist()
  step Transactions::Messages::SuccessMessage('Dashboard saved')

  def assign_app(context, model: ,**)
    model.app = RequestStoreUtil.current_app
  end

end