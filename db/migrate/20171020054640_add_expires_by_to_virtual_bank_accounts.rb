class AddExpiresByToVirtualBankAccounts < ActiveRecord::Migration[4.2]
  def change
    add_column :virtual_bank_accounts, :expires_by, :date
  end
end
