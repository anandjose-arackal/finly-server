class AddAncestryToBudgets < ActiveRecord::Migration
  def change
    add_column :budgets, :ancestry, :string
  end
end