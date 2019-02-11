class SeedCommentActionDataToCommentActionModels < ActiveRecord::Migration[4.2]
  def change
    ReportCommentAction.seed_data
    TravelRequestCommentAction.seed_data
    MoneyRequestCommentAction.seed_data
  end
end
