class AddDisabledToBankAccounts < ActiveRecord::Migration[4.2]
  def change
    add_column :bank_accounts, :disabled, :boolean, default: false
    add_column :yes_bank_vendors, :disabled, :boolean, default: false
  end
end
