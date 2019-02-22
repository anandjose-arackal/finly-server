class SeedTrailAction3 < ActiveRecord::Migration[4.2]
  def change
    TrailAction.seed_data
  end
end
