class SeedCommentActionDataToCommentActionModels < ActiveRecord::Migration
  def change
    ReportCommentAction.seed_data
    TravelRequestCommentAction.seed_data
    MoneyRequestCommentAction.seed_data
  end
end
