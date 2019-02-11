class AddCustomerIdToVirtualBankAccounts < ActiveRecord::Migration[4.2]
  def change
    add_column :virtual_bank_accounts, :customer_id, :integer, references: "Customer", foreign_key: true, index: true
  end
end
