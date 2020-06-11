class SeedBbpsBillStatus < ActiveRecord::Migration[5.2]
  def change
    BbpsBillStatus.seed_data
  end
end
