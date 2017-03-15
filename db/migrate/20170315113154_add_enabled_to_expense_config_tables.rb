class AddEnabledToExpenseConfigTables < ActiveRecord::Migration
  def change
    add_column :distance_expense_configs, :enabled, :boolean
    add_column :time_expense_configs, :enabled, :boolean
  end
end
