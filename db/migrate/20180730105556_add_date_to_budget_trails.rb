class AddDateToBudgetTrails < ActiveRecord::Migration[4.2]
  def change
    add_column :budget_trails, :date, :date
  end
end
