class AddActiveToVirtualBankAccounts < ActiveRecord::Migration
  def change
    add_column :virtual_bank_accounts, :active, :boolean, default: true
  end
end
