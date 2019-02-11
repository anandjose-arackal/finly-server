class AddReceiptAmountToBudgetRule < ActiveRecord::Migration[4.2]
  def change
    add_column :budget_rules, :with_receipt_amount_id, :integer, references: 'Amount', index: true, foreign_key: true
    add_column :budget_rules, :without_receipt_amount_id, :integer, references: 'Amount', index: true, foreign_key: true
  end
end
