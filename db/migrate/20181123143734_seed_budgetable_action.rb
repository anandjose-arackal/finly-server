class SeedBudgetableAction < ActiveRecord::Migration[4.2]
  def change
    BudgetModificationAction.seed_data
  end
end
