class SeedDataToNotifierAndCommentActionModels < ActiveRecord::Migration[5.2]
  def change
    NotifierType.seed_data
    TravelRequestCommentAction.seed_data
  end
end
