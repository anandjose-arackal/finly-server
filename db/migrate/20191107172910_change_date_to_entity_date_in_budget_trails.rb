class ChangeDateToEntityDateInBudgetTrails < ActiveRecord::Migration[5.2]
  def change
    rename_column :budget_trails, :date, :entity_date
  end
end
