class AddActiveToVirtualBankAccounts < ActiveRecord::Migration[4.2]
  def change
    add_column :virtual_bank_accounts, :active, :boolean, default: true
  end
end
