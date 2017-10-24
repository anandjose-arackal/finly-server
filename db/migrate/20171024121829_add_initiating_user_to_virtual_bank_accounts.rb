class AddInitiatingUserToVirtualBankAccounts < ActiveRecord::Migration
  def change
    add_column :virtual_bank_accounts, :initiating_user_id, :integer, references: "User", foreign_key: true, index: true
  end
end
