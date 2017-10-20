class AddExpiresByToVirtualBankAccounts < ActiveRecord::Migration
  def change
    add_column :virtual_bank_accounts, :expires_by, :date
  end
end
