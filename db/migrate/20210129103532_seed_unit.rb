class SeedUnit < ActiveRecord::Migration[6.0]
  def change
    Unit.seed_data
  end
end
