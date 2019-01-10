class SeedPurposeIdForCollect < ActiveRecord::Migration[4.2]
  def change
    Purpose.seed_data
  end
end
