class AddMoreFieldsToBudgetModificationTrails < ActiveRecord::Migration[4.2]
  def change
    add_column :budget_modification_trails, :previous_value, :string
    add_column :budget_modification_trails, :current_value, :string
    add_column :budget_modification_trails, :changed_column_name, :string
  end
end