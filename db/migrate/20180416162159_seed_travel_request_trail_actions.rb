class SeedTravelRequestTrailActions < ActiveRecord::Migration
  def change
    TravelRequestTrailAction.seed_data
  end
end
