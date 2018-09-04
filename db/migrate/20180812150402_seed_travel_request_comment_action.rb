class SeedTravelRequestCommentAction < ActiveRecord::Migration
  def change
    TravelRequestCommentAction.seed_data
  end
end
