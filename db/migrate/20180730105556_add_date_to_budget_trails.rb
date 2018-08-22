class AddDateToBudgetTrails < ActiveRecord::Migration
  def change
    add_column :budget_trails, :date, :date
  end
end
