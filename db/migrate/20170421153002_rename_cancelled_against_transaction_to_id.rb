class RenameCancelledAgainstTransactionToId < ActiveRecord::Migration[4.2]
  def change
    rename_column :card_expenses, :cancelled_against_transaction, :cancelled_against_transaction_id
  end
end
