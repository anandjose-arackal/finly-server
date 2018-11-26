class SeedBudgetableAction < ActiveRecord::Migration
  def change
    BudgetModificationAction.seed_data
  end
end
