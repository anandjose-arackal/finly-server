class AddColumnsToBudgetTrail < ActiveRecord::Migration[5.2]
  def change
    # add_column :budget_trails, :amount_before_tax_id, :integer, references: "Amount", foreign_key: true, index: true
    # add_column :budget_trails, :amount_after_tax_id, :integer, references: "Amount", foreign_key: true, index: true
  end
end
