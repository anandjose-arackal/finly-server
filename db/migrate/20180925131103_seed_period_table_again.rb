class SeedPeriodTableAgain < ActiveRecord::Migration
  def change
    Period.seed_data
  end
end
