class RenameTableEnforceBudget < ActiveRecord::Migration[4.2]
  def change
    rename_table :enforce_budgets, :enforce_budget_configurations
  end
end