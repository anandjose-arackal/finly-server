class SeedPurposeForPo < ActiveRecord::Migration[5.2]
  def change
    Purpose.seed_data
  end
end
