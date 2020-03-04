class AddPoItemTrailId < ActiveRecord::Migration[5.2]
  def change
    add_column :budget_trails, :po_trail_item_id, :integer, references: "BudgetTrail", foreign_key: true, index: true
    add_column :budget_trails, :billed_amount_before_tax_value, :decimal, precision: 20, scale: 10
    add_column :budget_trails, :billed_amount_after_tax_value, :decimal, precision: 20, scale: 10
    add_column :budget_trails, :remaining_amount_before_tax_value, :decimal, precision: 20, scale: 10
    add_column :budget_trails, :remaining_amount_after_tax_value, :decimal, precision: 20, scale: 10
    add_column :budget_trails, :billed_quantity, :integer
    add_column :budget_trails, :billed_rate, :decimal, precision: 20, scale: 10
    add_column :budget_trails, :remaining_quantity, :integer
    add_column :budget_trails, :revised, :boolean, default: false
  end
end
