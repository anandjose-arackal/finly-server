class AddInitiatingUserToVirtualBankAccounts < ActiveRecord::Migration[4.2]
  def change
    add_column :virtual_bank_accounts, :initiating_user_id, :integer, references: "User", foreign_key: true, index: true
  end
end
