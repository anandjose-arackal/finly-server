class SeedTrailAction3 < ActiveRecord::Migration
  def change
    TrailAction.seed_data
  end
end
