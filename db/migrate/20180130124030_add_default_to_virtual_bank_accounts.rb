class AddDefaultToVirtualBankAccounts < ActiveRecord::Migration
  def change
    add_column :virtual_bank_accounts, :default_account, :boolean
  end
end
