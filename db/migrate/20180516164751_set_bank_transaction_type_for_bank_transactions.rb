class SetBankTransactionTypeForBankTransactions < ActiveRecord::Migration
  def change
    BankTransaction.update_all(bank_transaction_type_id: BankTransactionType.id_for(:yes_bank))
  end
end