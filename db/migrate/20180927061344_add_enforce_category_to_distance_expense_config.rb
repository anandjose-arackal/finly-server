class AddEnforceCategoryToDistanceExpenseConfig < ActiveRecord::Migration
  def change
    add_column :distance_expense_configs, :enforce_category, :boolean, default: false, index: true
  end
end