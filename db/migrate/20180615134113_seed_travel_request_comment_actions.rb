class SeedTravelRequestCommentActions < ActiveRecord::Migration[4.2]
  def change
    TravelRequestCommentAction.seed_data
  end
end
