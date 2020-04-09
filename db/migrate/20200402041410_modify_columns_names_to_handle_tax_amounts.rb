class ModifyColumnsNamesToHandleTaxAmounts < ActiveRecord::Migration[5.2]
  def change
    rename_column :budget_trails, :paid_amount_before_tax_value, :effective_paid_amount_before_tax_value
    add_column :budget_trails, :net_paid_amount_before_tax_value, :decimal, precision: 20, scale: 10
  end
end
