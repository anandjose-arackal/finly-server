class AddIndexesInYesBankVendorAndBankAccounts < ActiveRecord::Migration[5.2]
  def change
    add_index :payments, :payment_order_id
    add_index :bank_accounts, :account_number
    add_index :bank_accounts, :name
    add_index :bank_accounts, :ifsc
    add_index :bank_accounts, :company_id
    add_index :yes_bank_vendors, :name
  end
end
