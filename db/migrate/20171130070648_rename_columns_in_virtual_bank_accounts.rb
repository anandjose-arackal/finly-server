class RenameColumnsInVirtualBankAccounts < ActiveRecord::Migration[4.2]
  def change
    rename_column :virtual_bank_accounts, :maximum_amount_id, :maximum_transaction_amount_id
    rename_column :virtual_bank_accounts, :minimum_amount_id, :minimum_transaction_amount_id
    add_column :virtual_bank_accounts, :maximum_amount_id, :integer, references: "Amount", foreign_key: true, index: true
  end
end
