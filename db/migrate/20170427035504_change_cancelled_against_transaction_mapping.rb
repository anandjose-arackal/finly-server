class ChangeCancelledAgainstTransactionMapping < ActiveRecord::Migration[4.2]
  def change
    remove_column :card_expenses, :cancelled_against_transaction_id, :integer
    add_column :card_transactions, :cancelled_against_expense_id, :integer, references: "CardExpense", foreign_key: true, index: true
  end
end
