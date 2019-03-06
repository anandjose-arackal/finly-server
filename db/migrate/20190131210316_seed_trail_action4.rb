class SeedTrailAction4 < ActiveRecord::Migration[5.2]
  def change
    TrailAction.seed_data
  end
end
