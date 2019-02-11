class SeedTravelRequestTrailActions < ActiveRecord::Migration[4.2]
  def change
    TravelRequestTrailAction.seed_data
  end
end
