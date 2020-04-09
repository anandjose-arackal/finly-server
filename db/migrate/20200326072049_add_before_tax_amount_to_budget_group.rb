class AddBeforeTaxAmountToBudgetGroup < ActiveRecord::Migration[5.2]
  def change
    add_column :budget_groups, :calculated_before_tax_amount, :boolean, default: false
  end
end
