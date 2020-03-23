class AddNameToBudgetGroups < ActiveRecord::Migration[5.2]
  def change
    add_column :budget_groups, :name, :string
  end
end
