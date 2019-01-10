class AddAncestryToBudgets < ActiveRecord::Migration[4.2]
  def change
    add_column :budgets, :ancestry, :string
  end
end