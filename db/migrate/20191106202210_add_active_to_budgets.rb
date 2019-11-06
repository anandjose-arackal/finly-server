class AddActiveToBudgets < ActiveRecord::Migration[5.2]
  def change
    add_column :budgets, :active, :boolean, default: false
  end
end
