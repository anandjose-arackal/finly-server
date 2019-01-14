class AddBankTransactionTypesToBt < ActiveRecord::Migration[4.2]
  def change
    add_column :bank_transactions, :bank_transaction_type_id, :integer, references: "BankTransactionType", foreign_key: true, index: true
  end
end
