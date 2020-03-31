class AddModeFieldsToBudget < ActiveRecord::Migration[5.2]
  def change
    add_column :budgets, :purchase_request, :boolean
    add_column :budgets, :invoice, :boolean
  end
end
