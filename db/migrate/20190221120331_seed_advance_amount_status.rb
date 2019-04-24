class SeedAdvanceAmountStatus < ActiveRecord::Migration[5.2]
  def change
  	AdvanceAmountStatus.seed_data
  end
end
