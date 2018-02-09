class SeedPurposes < ActiveRecord::Migration
  def change
    Purpose.seed_data
  end
end