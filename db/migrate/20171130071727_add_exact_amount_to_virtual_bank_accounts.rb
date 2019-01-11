class AddExactAmountToVirtualBankAccounts < ActiveRecord::Migration[4.2]
  def change
    add_column :virtual_bank_accounts, :exact_transaction_amount_id, :integer, references: "Amount", foreign_key: true, index: true
  end
end
