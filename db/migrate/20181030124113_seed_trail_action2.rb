class SeedTrailAction2 < ActiveRecord::Migration
  def change
    TrailAction.seed_data
  end
end
