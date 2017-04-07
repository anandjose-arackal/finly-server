class AddPrecisionToAllDecimalFields < ActiveRecord::Migration
  def change
    change_column :distance_expense_configs, :rate_per_km, :decimal, precision: 10, scale: 4
    change_column :time_expense_configs, :rate_per_hour, :decimal, precision: 10, scale: 4
  end
end
