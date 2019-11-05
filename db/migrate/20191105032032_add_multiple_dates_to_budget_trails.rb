class AddMultipleDatesToBudgetTrails < ActiveRecord::Migration[5.2]
  def change
    add_column :budget_trails, :entity_created_at, :datetime
    add_column :budget_trails, :entity_submitted_at, :datetime
  end
end
