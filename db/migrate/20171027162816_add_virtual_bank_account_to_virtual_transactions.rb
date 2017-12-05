class AddVirtualBankAccountToVirtualTransactions < ActiveRecord::Migration
  def change
    add_column :virtual_account_transactions, :virtual_account_id, :integer, references: "VirtualAccount", foreign_key: true, index: true
  end
end
