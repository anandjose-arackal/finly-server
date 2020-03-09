class RemoveUnnecessaryAttributesFromBudgetTrail < ActiveRecord::Migration[5.2]
  def change
    remove_column :budget_trails, :billed_rate, :integer
    remove_column :budget_trails, :payment_confirmed, :boolean
    # remove_column :budget_trails, :billed_count, :integer
  end
end
