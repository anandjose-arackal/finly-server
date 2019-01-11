class AddDefaultToVirtualBankAccounts < ActiveRecord::Migration[4.2]
  def change
    add_column :virtual_bank_accounts, :default_account, :boolean
  end
end
