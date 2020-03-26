class AddTaxAmountFlagToBudgets < ActiveRecord::Migration[5.2]
  def change
    add_column :budgets, :calculated_before_tax_amount, :boolean, default: false
  end
end
