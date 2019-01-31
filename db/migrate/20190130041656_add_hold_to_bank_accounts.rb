class AddHoldToBankAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :bank_accounts, :on_hold, :boolean, default: false
  end
end
