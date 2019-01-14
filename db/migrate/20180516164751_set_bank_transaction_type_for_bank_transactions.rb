class SetBankTransactionTypeForBankTransactions < ActiveRecord::Migration[4.2]
  def change
    BankTransaction.update_all(bank_transaction_type_id: BankTransactionType.id_for(:yes_bank))
  end
end