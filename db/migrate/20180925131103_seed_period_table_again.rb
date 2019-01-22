class SeedPeriodTableAgain < ActiveRecord::Migration[4.2]
  def change
    Period.seed_data
  end
end
