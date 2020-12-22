class AnalyticsDashboard::Ops::Export < Transactions::API

  schema do
    params do
      required(:query).filled
    end
  end

  step Model(AnalyticsDashboard, :find_by_id)
  step Policy::Pundit(AnalyticsDashboard::Policy, :export?)
  step :initiate_export
  step Transactions::Messages::SuccessMessage('Successfully initiated the export')

  def initiate_export(context, current_user:, params:, **)
    # Todo actual export logic

    true
  end

end