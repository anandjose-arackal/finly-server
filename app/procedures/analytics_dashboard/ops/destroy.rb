class AnalyticsDashboard::Ops::Destroy < Transactions::API

  step Model(AnalyticsDashboard, :find_by_id)
  step Policy::Pundit(AnalyticsDashboard::Policy, :destroy?)
  pass :destroy_record
  step Transactions::Messages::SuccessMessage('Dashboard deleted')

  def destroy_record(context, model:, **)
    model.destroy
  end

end